from flask import Flask, request, jsonify
import os
import requests
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID")

# In-memory users (replace with real DB later)
users = {}

@app.route("/", methods=["GET"])
def home():
    return "Recipe & Auth API is running", 200

@app.route("/ping", methods=["GET"])
def ping():
    return "OK", 200

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}

    if "idToken" in data:
        token = data["idToken"]
        try:
            idinfo = id_token.verify_oauth2_token(
                token, google_requests.Request(), GOOGLE_CLIENT_ID
            )
            email = idinfo.get("email")
            name = idinfo.get("name", email.split("@")[0] if email else "User")

            if not email:
                return jsonify({"error": "No email in token"}), 400

            email_key = email.lower()
            if email_key not in users:
                users[email_key] = {
                    "password_hash": None,
                    "name": name,
                    "verified": True
                }

            return jsonify({
                "message": "Google login successful",
                "email": email,
                "name": name,
                "user_id": idinfo["sub"]
            }), 200
        except ValueError as e:
            return jsonify({"error": f"Invalid token: {str(e)}"}), 400

    # Email/password login
    if "email" in data and "password" in data:
        email = data["email"].strip().lower()
        password = data["password"]

        if email not in users:
            return jsonify({"error": "Something is idk u (user not found)"}), 404

        user = users[email]
        if user["password_hash"] is None:
            return jsonify({"error": "This account uses Google Sign-In"}), 403

        if not check_password_hash(user["password_hash"], password):
            return jsonify({"error": "Invalid password"}), 401

        if not user.get("verified", False):
            return jsonify({"error": "Please verify your email first"}), 403

        return jsonify({
            "message": "Logged in successfully",
            "email": email,
            "name": user["name"]
        }), 200

    return jsonify({"error": "Missing idToken or email+password"}), 400

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    if "email" not in data or "password" not in data:
        return jsonify({"error": "Missing email or password"}), 400

    email = data["email"].strip().lower()
    password = data["password"]

    if email in users:
        return jsonify({"error": "Email already registered"}), 409

    if len(password) < 6:
        return jsonify({"error": "Password must be at least 6 characters"}), 400

    users[email] = {
        "password_hash": generate_password_hash(password),
        "name": email.split("@")[0].title(),
        "verified": True  # Change to False + add verification later
    }

    return jsonify({
        "message": "Account created – check your email for verification link",
        "email": email
    }), 201

# Your recipe endpoint (unchanged)
@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    if not GEMINI_API_KEY:
        return jsonify({"error": "Gemini API key not configured"}), 500

    data = request.get_json(silent=True) or {}
    ingredients = data.get("ingredients", [])

    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
        prompt = f"Give me 3 creative recipe ideas using: {', '.join(ingredients)}. Include time & servings."
        payload = {"contents": [{"parts": [{"text": prompt}]}]}

        resp = requests.post(url, json=payload)
        resp.raise_for_status()

        text = resp.json()['candidates'][0]['content']['parts'][0]['text']
        return jsonify({"recipes": text})
    except Exception as e:
        return jsonify({"error": "Failed to get recipes", "details": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)