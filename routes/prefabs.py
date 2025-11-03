from flask import Blueprint, jsonify, request
from sqlalchemy import select, insert, update, delete, Table
from sqlalchemy.exc import SQLAlchemyError
from db import engine, metadata
from utils import get_or_create_lookup, rows_to_dicts

bp = Blueprint("prefabs", __name__, url_prefix="/api/prefab")

# Table references
TABLE = {
    "prefabs": metadata.tables.get("prefab"),
    "prefab names": metadata.tables.get("prefab_name"),
    "prefab specs": metadata.tables.get("prefab_specs"),
    "colors": metadata.tables.get("color"),
    "prefab materials": metadata.tables.get("prefab_material"),
    "prefab quantities": Table("prefab_quantity", metadata, autoload_with=engine)
}

LOOKUP_TABLE = {
    "name": TABLE["prefab names"],
    "specs": TABLE["prefab specs"],
    "color": TABLE["colors"]
}

@bp.route("/all", methods=["GET"])
def all_prefabs():
    query = (
        select(
            TABLE["prefabs"].c.id.label("id"),
            TABLE["prefab names"].c.prefab_name.label("name"),
            TABLE["prefab specs"].c.prefab_specs.label("specs"),
            TABLE["colors"].c.color.label("color"),
            TABLE["prefabs"].c.srp.label("srp"),
            TABLE["prefabs"].c.desc.label("desc"),
            TABLE["prefab quantities"].c.available_quantity.label("available_quantity")
        )
        .join(TABLE["prefab names"], TABLE["prefabs"].c.prefab_name_id == TABLE["prefab names"].c.id, isouter=True)
        .join(TABLE["prefab specs"], TABLE["prefabs"].c.prefab_specs_id == TABLE["prefab specs"].c.id, isouter=True)
        .join(TABLE["colors"], TABLE["prefabs"].c.color_id == TABLE["colors"].c.id, isouter=True)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/<int:prefab_id>", methods=["GET"])
def get_prefab(prefab_id):
    query = (
        select(
            TABLE["prefabs"].c.id.label("id"),
            TABLE["prefab names"].c.prefab_name.label("name"),
            TABLE["prefab specs"].c.prefab_specs.label("specs"),
            TABLE["colors"].c.color.label("color"),
            TABLE["prefabs"].c.srp.label("srp")
        )
        .join(TABLE["prefab names"], TABLE["prefabs"].c.prefab_name_id == TABLE["prefab names"].c.id, isouter=True)
        .join(TABLE["prefab specs"], TABLE["prefabs"].c.prefab_specs_id == TABLE["prefab specs"].c.id, isouter=True)
        .join(TABLE["colors"], TABLE["prefabs"].c.color_id == TABLE["colors"].c.id, isouter=True)
        .where(TABLE["prefabs"].c.id == prefab_id)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/add", methods=["POST"])
def add_prefab():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    # Extract fields
    lookup_fields = ["name", "specs", "color"]
    confirmed = data.get("confirmed", False)

    lookup_values = dict()
    for key in lookup_fields:
        value = data.get(key)
        if value and value != "": lookup_values[key] = value

    # Ensure required fields
    if not lookup_values.get("name"):
        return jsonify({"error": "Missing required field: name"}), 400

    missing = {}
    resolved_ids = {}

    # --- STEP 1: Detect missing lookups ---
    with engine.connect() as conn:
        for key, value in lookup_values.items():
            if not value:
                continue

            table = LOOKUP_TABLE.get(key)
            if table is None:
                continue

            if key == "color": column = key
            else: column = f"prefab_{key}"
            
            existing_id = conn.execute(
                select(table.c.id).where(table.c[column] == value)
            ).scalar_one_or_none()

            if existing_id:
                resolved_ids[key] = existing_id
            else:
                missing[key] = value

        if missing and not confirmed:
            return (
                jsonify({
                    "status": "confirm_required",
                    "message": "Some lookup values are missing. Confirm before adding the item.",
                    "missing": missing,
                }),
                409,
            )

    # --- STEP 2: Insert missing lookups + item ---
    try:
        with engine.begin() as conn:
            for key, value in lookup_values.items():
                if not value:
                    continue

                table = LOOKUP_TABLE.get(key)
                if table is None:
                    continue

                if key == "color": column = key
                else: column = f"prefab_{key}"

                # Automatically insert missing lookups if confirmed
                if confirmed:
                    resolved_ids[key] = get_or_create_lookup(conn, table, column, value)
                else:
                    resolved_ids[key] = conn.execute(
                        select(table.c.id).where(table.c[column] == value)
                    ).scalar_one_or_none()

            new_prefab = dict()
            for key in lookup_values.keys():
                if key == "color": new_prefab[f"{key}_id"] = resolved_ids.get(key)
                else: new_prefab[f"prefab_{key}_id"] = resolved_ids.get(key)

            for key in ("srp", "desc"):
                value = data.get(key)
                if value: new_prefab[key] = value

            # Insert into main item table
            conn.execute(insert(TABLE["prefabs"]).values(new_prefab))

        return jsonify({
            "status": "success",
            "message": f"Prefab '{lookup_values['name']}' added successfully."
        }), 201

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@bp.route("/<int:prefab_id>/update", methods=["PUT"])
def update_prefab(prefab_id):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    lookup_fields = ["name", "specs", "color"]
    updated_values = {}
    resolved_ids = {}

    # Extract and resolve lookups
    with engine.begin() as conn:
        for key in lookup_fields:
            value = data.get(key)
            if not value or value == "":
                continue

            table = LOOKUP_TABLE.get(key)
            if table is None:
                continue

            column = "color" if key == "color" else f"prefab_{key}"

            # Reuse your helper
            resolved_id = get_or_create_lookup(conn, table, column, value)
            resolved_ids[key] = resolved_id

        # Prepare update dictionary
        for key, id_value in resolved_ids.items():
            if key == "color":
                updated_values[f"{key}_id"] = id_value
            else:
                updated_values[f"prefab_{key}_id"] = id_value

        # Add direct editable fields (if present)
        for key in ("srp", "desc"):
            if key in data:
                updated_values[key] = data[key]

        if not updated_values:
            return jsonify({"error": "No valid fields provided for update."}), 400

        # Perform the update
        stmt = (
            update(TABLE["prefabs"])
            .where(TABLE["prefabs"].c.id == prefab_id)
            .values(**updated_values)
        )
        result = conn.execute(stmt)

        if result.rowcount == 0:
            return jsonify({"error": f"Prefab with ID {prefab_id} not found."}), 404

    return jsonify({
        "status": "success",
        "message": f"Prefab {prefab_id} updated successfully.",
        "updated_fields": updated_values
    }), 200

@bp.route("/<int:prefab_id>/delete", methods=["DELETE"])
def delete_prefab(prefab_id):
    try:
        with engine.begin() as conn:
            stmt = delete(TABLE["prefabs"]).where(TABLE["prefabs"].c.id == prefab_id)
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Prefab with ID {prefab_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"Prefab {prefab_id} deleted successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500


# --- Prefab materials ---

@bp.route("/<int:prefab_id>/materials", methods=["GET"])
def get_prefab_materials(prefab_id):
    query = (
        select(
            TABLE["prefab materials"].c.prefab_id.label("prefab id"),
            TABLE["prefab materials"].c.material_id.label("material id"),
            TABLE["prefab materials"].c.quantity_per_prefab.label("quantity per prefab"),
        )
        .where(TABLE["prefab materials"].c.prefab_id == prefab_id)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/<int:prefab_id>/add-material", methods=["POST"])
def add_prefab_material(prefab_id):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    materials = data.get("materials", [])

    try:
        with engine.begin() as conn:
            qtys = [
                {
                    "prefab_id": prefab_id,
                    "material_id": m["material_id"],
                    "quantity_per_prefab": m["quantity_per_prefab"]
                }
                for m in materials
            ]

            conn.execute(insert(TABLE["prefab materials"]), qtys)
        
        return jsonify({"message": "Materials added to prefab successfully."}), 201
    
    except Exception as e: return jsonify({"error": str(e)}), 500

@bp.route("/<int:prefab_id>/update-material/<int:material_id>", methods=["PUT"])
def update_prefab_material(prefab_id, material_id):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    quantity_per_prefab = data.get("quantity_per_prefab")
    if not quantity_per_prefab:
        return jsonify({"error": "No valid fields provided for update."}), 400

    try:
        with engine.begin() as conn:
            stmt = (
                update(TABLE["prefab materials"])
                .where(TABLE["prefab materials"].c.prefab_id == prefab_id)
                .where(TABLE["prefab materials"].c.material_id == material_id)
                .values(data)
            )
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Material with ID {material_id} in Prefab {prefab_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"Material {material_id} in Prefab {prefab_id} updated successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@bp.route("/<int:prefab_id>/delete-material/<int:material_id>", methods=["DELETE"])
def delete_prefab_material(prefab_id, material_id):
    try:
        with engine.begin() as conn:
            stmt = delete(TABLE["prefab materials"]).where(TABLE["prefab materials"].c.prefab_id == prefab_id).where(TABLE["prefab materials"].c.material_id == material_id)
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Material with ID {material_id} in Prefab {prefab_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"Material {material_id} in Prefab {prefab_id} deleted successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@bp.route("/<int:prefab_id>/delete-all-materials", methods=["DELETE"])
def delete_all_materials(prefab_id):
    try:
        with engine.begin() as conn:
            stmt = delete(TABLE["prefab materials"]).where(TABLE["prefab materials"].c.prefab_id == prefab_id)
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Prefab with ID {prefab_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"All materials in Prefab {prefab_id} deleted successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500
