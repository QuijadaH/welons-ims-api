from .materials import bp as materials_bp
from .prefabs import bp as prefabs_bp
from .lookups import bp as lookups_bp

def register_routes(app):
    """
    Registers all Blueprints (modular route groups) with the Flask app.
    Add new ones here as your project grows.
    """
    app.register_blueprint(materials_bp)
    app.register_blueprint(prefabs_bp)
    app.register_blueprint(lookups_bp)
