from flask import Blueprint, jsonify, request
from sqlalchemy import select, insert, update, delete
from sqlalchemy.exc import SQLAlchemyError
from db import engine, metadata
from utils import get_or_create_lookup, rows_to_dicts

bp = Blueprint("materials", __name__, url_prefix="/api/material")

# Table references
TABLE = {
    "materials": metadata.tables.get("material"),
    "material names": metadata.tables.get("material_name"),
    "material specs": metadata.tables.get("material_specs"),
    "material categories": metadata.tables.get("material_category"),
    "material units": metadata.tables.get("material_unit"),
    "material remarks": metadata.tables.get("material_remarks"),
    "colors": metadata.tables.get("color")
}

LOOKUP_TABLE = {
    "name": TABLE["material names"],
    "specs": TABLE["material specs"],
    "category": TABLE["material categories"],
    "unit": TABLE["material units"],
    "remarks": TABLE["material remarks"],
    "color": TABLE["colors"]
}

@bp.route("/all", methods=["GET"])
def all_materials():
    query = (
        select(
            TABLE["materials"].c.id.label("id"),
            TABLE["material names"].c.material_name.label("name"),
            TABLE["material specs"].c.material_specs.label("specs"),
            TABLE["material categories"].c.material_category.label("category"),
            TABLE["material units"].c.material_unit.label("unit"),
            TABLE["material remarks"].c.material_remarks.label("remarks"),
            TABLE["colors"].c.color.label("color"),
            TABLE["materials"].c.qty.label("quantity"),
            TABLE["materials"].c.srp.label("srp"),
            TABLE["materials"].c.desc.label("desc")
        )
        .join(TABLE["material names"], TABLE["materials"].c.material_name_id == TABLE["material names"].c.id, isouter=True)
        .join(TABLE["material specs"], TABLE["materials"].c.material_specs_id == TABLE["material specs"].c.id, isouter=True)
        .join(TABLE["material categories"], TABLE["materials"].c.material_category_id == TABLE["material categories"].c.id, isouter=True)
        .join(TABLE["material units"], TABLE["materials"].c.material_unit_id == TABLE["material units"].c.id, isouter=True)
        .join(TABLE["material remarks"], TABLE["materials"].c.material_remarks_id == TABLE["material remarks"].c.id, isouter=True)
        .join(TABLE["colors"], TABLE["materials"].c.color_id == TABLE["colors"].c.id, isouter=True)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/<int:material_id>", methods=["GET"])
def get_material(material_id):
    query = (
        select(
            TABLE["materials"].c.id.label("id"),
            TABLE["material names"].c.material_name.label("name"),
            TABLE["material specs"].c.material_specs.label("specs"),
            TABLE["material categories"].c.material_category.label("category"),
            TABLE["material units"].c.material_unit.label("unit"),
            TABLE["material remarks"].c.material_remarks.label("remarks"),
            TABLE["colors"].c.color.label("color"),
            TABLE["materials"].c.qty.label("quantity"),
            TABLE["materials"].c.srp.label("srp")
        )
        .join(TABLE["material names"], TABLE["materials"].c.material_name_id == TABLE["material names"].c.id, isouter=True)
        .join(TABLE["material specs"], TABLE["materials"].c.material_specs_id == TABLE["material specs"].c.id, isouter=True)
        .join(TABLE["material categories"], TABLE["materials"].c.material_category_id == TABLE["material categories"].c.id, isouter=True)
        .join(TABLE["material units"], TABLE["materials"].c.material_unit_id == TABLE["material units"].c.id, isouter=True)
        .join(TABLE["material remarks"], TABLE["materials"].c.material_remarks_id == TABLE["material remarks"].c.id, isouter=True)
        .join(TABLE["colors"], TABLE["materials"].c.color_id == TABLE["colors"].c.id, isouter=True)
        .where(TABLE["materials"].c.id == material_id)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    if not data:
        return jsonify({"error": f"Material with ID {material_id} not found."}), 404

    return jsonify(data)

@bp.route("/add", methods=["POST"])
def add_material():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    # Extract fields
    lookup_fields = ["name", "specs", "category", "unit", "remarks", "color"]
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
            else: column = f"material_{key}"
            
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
                else: column = f"material_{key}"

                # Automatically insert missing lookups if confirmed
                if confirmed:
                    resolved_ids[key] = get_or_create_lookup(conn, table, column, value)
                else:
                    resolved_ids[key] = conn.execute(
                        select(table.c.id).where(table.c[column] == value)
                    ).scalar_one_or_none()

            new_material = dict()
            for key in lookup_values.keys():
                if key == "color": new_material[f"{key}_id"] = resolved_ids.get(key)
                else: new_material[f"material_{key}_id"] = resolved_ids.get(key)

            for key in ("qty", "srp", "desc"):
                value = data.get(key)
                if value: new_material[key] = value

            # Insert into main item table
            conn.execute(insert(TABLE["materials"]).values(new_material))

        return jsonify({
            "status": "success",
            "message": f"Material '{lookup_values['name']}' added successfully."
        }), 201

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@bp.route("/<int:material_id>/update", methods=["PUT"])
def update_material(material_id):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    lookup_fields = ["name", "specs", "category", "unit", "remarks", "color"]
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

            column = "color" if key == "color" else f"material_{key}"

            # Reuse your helper
            resolved_id = get_or_create_lookup(conn, table, column, value)
            resolved_ids[key] = resolved_id

        # Prepare update dictionary
        for key, id_value in resolved_ids.items():
            if key == "color":
                updated_values[f"{key}_id"] = id_value
            else:
                updated_values[f"material_{key}_id"] = id_value

        # Add direct editable fields (if present)
        for key in ("qty", "srp", "desc"):
            if key in data:
                updated_values[key] = data[key]

        if not updated_values:
            return jsonify({"error": "No valid fields provided for update."}), 400

        # Perform the update
        stmt = (
            update(TABLE["materials"])
            .where(TABLE["materials"].c.id == material_id)
            .values(**updated_values)
        )
        result = conn.execute(stmt)

        if result.rowcount == 0:
            return jsonify({"error": f"Material with ID {material_id} not found."}), 404

    return jsonify({
        "status": "success",
        "message": f"Material {material_id} updated successfully.",
        "updated_fields": updated_values
    }), 200

@bp.route("/<int:material_id>/delete", methods=["DELETE"])
def delete_material(material_id):
    try:
        with engine.begin() as conn:
            stmt = delete(TABLE["materials"]).where(TABLE["materials"].c.id == material_id)
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Material with ID {material_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"Material {material_id} deleted successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500
