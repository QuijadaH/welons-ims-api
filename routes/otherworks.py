from flask import Blueprint, jsonify, request
from sqlalchemy import select, insert, update, delete
from sqlalchemy.exc import SQLAlchemyError
from db import engine, metadata
from utils import get_or_create_lookup, rows_to_dicts

bp = Blueprint("otherworks", __name__, url_prefix="/api/otherworks")

# Table references
TABLE = {
    "otherworks": metadata.tables.get("otherworks"),
    "otherworks names": metadata.tables.get("otherworks_name"),
    "otherworks categories": metadata.tables.get("otherworks_category"),
    "otherworks units": metadata.tables.get("otherworks_unit"),
}

LOOKUP_TABLE = {
    "name": TABLE["otherworks names"],
    "category": TABLE["otherworks categories"],
    "unit": TABLE["otherworks units"],
}

@bp.route("/all", methods=["GET"])
def all_otherworks():
    query = (
        select(
            TABLE["otherworks"].c.id.label("id"),
            TABLE["otherworks names"].c.otherworks_name.label("name"),
            TABLE["otherworks categories"].c.otherworks_category.label("category"),
            TABLE["otherworks units"].c.otherworks_unit.label("unit"),
            TABLE["otherworks"].c.unit_cost.label("unit cost"),
            TABLE["otherworks"].c.desc.label("desc")
        )
        .join(TABLE["otherworks names"], TABLE["otherworks"].c.otherworks_name_id == TABLE["otherworks names"].c.id, isouter=True)
        .join(TABLE["otherworks categories"], TABLE["otherworks"].c.otherworks_category_id == TABLE["otherworks categories"].c.id, isouter=True)
        .join(TABLE["otherworks units"], TABLE["otherworks"].c.otherworks_unit_id == TABLE["otherworks units"].c.id, isouter=True)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/<int:otherworks_id>", methods=["GET"])
def get_otherworks(otherworks_id):
    query = (
        select(
            TABLE["otherworks"].c.id.label("id"),
            TABLE["otherworks names"].c.otherworks_name.label("name"),
            TABLE["otherworks categories"].c.otherworks_category.label("category"),
            TABLE["otherworks units"].c.otherworks_unit.label("unit"),
            TABLE["otherworks"].c.unit_cost.label("unit cost"),
            TABLE["otherworks"].c.desc.label("desc")
        )
        .join(TABLE["otherworks names"], TABLE["otherworks"].c.otherworks_name_id == TABLE["otherworks names"].c.id, isouter=True)
        .join(TABLE["otherworks categories"], TABLE["otherworks"].c.otherworks_category_id == TABLE["otherworks categories"].c.id, isouter=True)
        .join(TABLE["otherworks units"], TABLE["otherworks"].c.otherworks_unit_id == TABLE["otherworks units"].c.id, isouter=True)
        .where(TABLE["otherworks"].c.id == otherworks_id)
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    if not data:
        return jsonify({"error": f"Other works with ID {otherworks_id} not found."}), 404

    return jsonify(data)

@bp.route("/add", methods=["POST"])
def add_otherworks():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    # Extract fields
    lookup_fields = ["name", "category", "unit"]
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

            column = f"otherworks_{key}"
            
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

                column = f"otherworks_{key}"

                # Automatically insert missing lookups if confirmed
                if confirmed:
                    resolved_ids[key] = get_or_create_lookup(conn, table, column, value)
                else:
                    resolved_ids[key] = conn.execute(
                        select(table.c.id).where(table.c[column] == value)
                    ).scalar_one_or_none()

            new_otherworks = dict()
            for key in lookup_values.keys():
                new_otherworks[f"otherworks_{key}_id"] = resolved_ids.get(key)

            for key in ("unit_cost", "desc"):
                value = data.get(key)
                if value: new_otherworks[key] = value

            # Insert into main item table
            conn.execute(insert(TABLE["otherworks"]).values(new_otherworks))

        return jsonify({
            "status": "success",
            "message": f"Other works '{lookup_values['name']}' added successfully."
        }), 201

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@bp.route("/<int:otherworks_id>/update", methods=["PUT"])
def update_otherworks(otherworks_id):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON data"}), 400

    lookup_fields = ["name", "category", "unit"]
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

            column = f"otherworks_{key}"

            # Reuse your helper
            resolved_id = get_or_create_lookup(conn, table, column, value)
            resolved_ids[key] = resolved_id

        # Prepare update dictionary
        for key, id_value in resolved_ids.items():
            updated_values[f"otherworks_{key}_id"] = id_value

        # Add direct editable fields (if present)
        for key in ("unit_cost", "desc"):
            if key in data:
                updated_values[key] = data[key]

        if not updated_values:
            return jsonify({"error": "No valid fields provided for update."}), 400

        # Perform the update
        stmt = (
            update(TABLE["otherworks"])
            .where(TABLE["otherworks"].c.id == otherworks_id)
            .values(**updated_values)
        )
        result = conn.execute(stmt)

        if result.rowcount == 0:
            return jsonify({"error": f"Other works with ID {otherworks_id} not found."}), 404

    return jsonify({
        "status": "success",
        "message": f"Other works {otherworks_id} updated successfully.",
        "updated_fields": updated_values
    }), 200

@bp.route("/<int:otherworks_id>/delete", methods=["DELETE"])
def delete_otherworks(otherworks_id):
    try:
        with engine.begin() as conn:
            stmt = delete(TABLE["otherworks"]).where(TABLE["otherworks"].c.id == otherworks_id)
            result = conn.execute(stmt)

            if result.rowcount == 0:
                return jsonify({"error": f"Other works with ID {otherworks_id} not found."}), 404

        return jsonify({
            "status": "success",
            "message": f"Other works {otherworks_id} deleted successfully."
        }), 200

    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500
