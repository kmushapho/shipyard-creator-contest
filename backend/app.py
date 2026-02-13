from flask import Flask, request, jsonify
import os
import requests
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

app = Flask(__name__)

# -------------------------
# Config
# -------------------------
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID")  # Set this in Render env

# -------------------------
# Routes
# -------------------------

# 1️⃣ Root route
@app.route("/", methods=["GET"])
def home():
    return "Recipe API + Auth is Live", 200

# 2️⃣ Ping route
@app.route("/ping", methods=["GET"])
def ping():
    return "OK", 200

# 3️⃣ Google Login route
@app.route("/login", methods=["POST"])
def login():
    """
    Expects JSON: { "idToken": "..." }
    Verifies with Google and returns user info.
    """
    data = request.get_json()
    if not data or "idToken" not in data:
        return jsonify({"error": "Missing idToken"}), 400

    token = data["idToken"]

    try:
        idinfo = id_token.verify_oauth2_token(token, google_requests.Request(), GOOGLE_CLIENT_ID)
        # idinfo contains user info like 'sub', 'email', 'name'
        return jsonify({
            "user_id": idinfo["sub"],
            "email": idinfo.get("email"),
            "name": idinfo.get("name")
        })
    except ValueError:
        return jsonify({"error": "Invalid token"}), 400

# 4️⃣ Recipe route
@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    if not GEMINI_API_KEY:
        return jsonify({"error": "API Key not configured on server"}), 500

    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON body"}), 400

    ingredients = data.get("ingredients", [])
    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    url = f"https://generativelanguage.googleapis.com{GEMINI_API_KEY}"

    headers = {"Content-Type": "application/json"}
    prompt_text = f"Give me 3 recipe ideas using these ingredients: {', '.join(ingredients)}"
    payload = {"contents": [{"parts": [{"text": prompt_text}]}]}

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()
        recipe_text = result['candidates'][0]['content']['parts'][0]['text']
        return jsonify({"recipes": recipe_text})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Gemini API Request Failed", "details": str(e)}), 500
    except (KeyError, IndexError):
        return jsonify({"error": "Unexpected API response format"}), 500

# -------------------------
# Run
# -------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
