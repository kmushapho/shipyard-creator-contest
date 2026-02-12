from flask import Flask, request, jsonify
import os
import requests

app = Flask(__name__)

# Ensure GEMINI_API_KEY is set in Render Environment Variables
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    """
    Expects JSON: { "ingredients": ["tomato", "egg"] }
    """
    data = request.get_json()
    ingredients = data.get("ingredients", [])

    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    # Correct Google Gemini API Endpoint (using v1beta for newest features)
    url = f"https://generativelanguage.googleapis.com{GEMINI_API_KEY}"

    headers = {"Content-Type": "application/json"}

    # Correct payload structure for Gemini API
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

        # Extract the text response from Gemini's nested structure
        recipe_text = result['candidates'][0]['content']['parts'][0]['text']
        return jsonify({"recipes": recipe_text})

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "API Request Failed", "details": str(e)}), 500
    except (KeyError, Index_Error):
        return jsonify({"error": "Unexpected API response format"}), 500

if __name__ == "__main__":
    # Render requires binding to 0.0.0.0 and using the dynamic $PORT
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
