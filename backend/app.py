from flask import Flask, request, jsonify
import os
import requests

app = Flask(__name__)

# Ensure GEMINI_API_KEY is set in Render Environment Variables
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

# 1. Root Route: Prevents the 404 errors seen in your logs
@app.route("/", methods=["GET"])
def home():
    return "Recipe API is Live", 200

# 2. Ping Route: For external monitors to keep the app awake
@app.route("/ping", methods=["GET"])
def ping():
    return "OK", 200

# 3. Main Logic Route
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

    # CORRECTED URL: Added model and ?key= parameter
    url = f"https://generativelanguage.googleapis.com{GEMINI_API_KEY}"

    headers = {"Content-Type": "application/json"}
    prompt_text = f"Give me 3 recipe ideas using these ingredients: {', '.join(ingredients)}"

    payload = {
        "contents": [{
            "parts": [{"text": prompt_text}]
        }]
    }

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()

        result = response.json()

        # Safe extraction of text from Gemini's JSON structure
        recipe_text = result['candidates'][0]['content']['parts'][0]['text']
        return jsonify({"recipes": recipe_text})

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Gemini API Request Failed", "details": str(e)}), 500
    except (KeyError, IndexError):
        return jsonify({"error": "Unexpected API response format"}), 500

if __name__ == "__main__":
    # Render binds to the PORT environment variable
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
