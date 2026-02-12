from flask import Flask, request, jsonify
import os
import requests

app = Flask(__name__)

# Fetch key from environment
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    # 1. Check if API Key exists
    if not GEMINI_API_KEY:
        return jsonify({"error": "Server configuration error: Missing API Key"}), 500

    data = request.get_json()
    ingredients = data.get("ingredients", [])

    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    # 2. FIXED URL: Includes model path and the ?key= parameter
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
        response.raise_for_status() # This catches 400/500 errors

        result = response.json()

        # 3. Safe extraction of the text response
        recipe_text = result['candidates'][0]['content']['parts'][0]['text']
        return jsonify({"recipes": recipe_text})

    except requests.exceptions.RequestException as e:
        # Returns specific error if the Google API call fails
        return jsonify({"error": "Gemini API Request Failed", "details": str(e)}), 500
    except (KeyError, IndexError) as e:
        return jsonify({"error": "Unexpected API response format", "details": str(e)}), 500

@app.route("/ping", methods=["GET"])
def ping():
    return "OK", 200

if __name__ == "__main__":
    # Render uses the PORT environment variable
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
