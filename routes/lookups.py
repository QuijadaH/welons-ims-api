from flask import Blueprint, jsonify, request
from sqlalchemy import select, insert, update, delete
from sqlalchemy.exc import SQLAlchemyError
from db import engine, metadata
from utils import get_or_create_lookup, rows_to_dicts

bp = Blueprint("lookups", __name__, url_prefix="/api/lookup")

# Table references
TABLE = {
    "materials": metadata.tables.get("material"),
    "material names": metadata.tables.get("material_name"),
    "material specs": metadata.tables.get("material_specs"),
    "material categories": metadata.tables.get("material_category"),
    "material units": metadata.tables.get("material_unit"),
    "material remarks": metadata.tables.get("material_remarks"),
    "colors": metadata.tables.get("color"),
    "prefabs": metadata.tables.get("prefab"),
    "prefab names": metadata.tables.get("prefab_name"),
    "prefab specs": metadata.tables.get("prefab_specs")
}

@bp.route("/material-names", methods=["GET"])
def material_names():
    query = (
        select(
            TABLE["material names"].c.id.label("id"),
            TABLE["material names"].c.material_name.label("material name")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/material-specs", methods=["GET"])
def material_specs():
    query = (
        select(
            TABLE["material specs"].c.id.label("id"),
            TABLE["material specs"].c.material_specs.label("material specs")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/material-categories", methods=["GET"])
def material_categories():
    query = (
        select(
            TABLE["material categories"].c.id.label("id"),
            TABLE["material categories"].c.material_category.label("material categories")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/material-units", methods=["GET"])
def material_units():
    query = (
        select(
            TABLE["material units"].c.id.label("id"),
            TABLE["material units"].c.material_unit.label("material units")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/material-remarks", methods=["GET"])
def material_remarks():
    query = (
        select(
            TABLE["material remarks"].c.id.label("id"),
            TABLE["material remarks"].c.material_remarks.label("material remarks")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/colors", methods=["GET"])
def colors():
    query = (
        select(
            TABLE["colors"].c.id.label("id"),
            TABLE["colors"].c.color.label("colors")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/prefab-names", methods=["GET"])
def prefab_names():
    query = (
        select(
            TABLE["prefab names"].c.id.label("id"),
            TABLE["prefab names"].c.prefab_name.label("prefab name")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)

@bp.route("/prefab-specs", methods=["GET"])
def prefab_specs():
    query = (
        select(
            TABLE["prefab specs"].c.id.label("id"),
            TABLE["prefab specs"].c.prefab_specs.label("prefab specs")
        )
    )

    with engine.connect() as conn:
        result = conn.execute(query)
        data = rows_to_dicts(result)

    return jsonify(data)