from flask import Flask, request, jsonify
import os
import requests  # or google API client if using official SDK

app = Flask(__name__)

# Read Gemini API key from Render environment
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    """
    Expects JSON: { "ingredients": ["tomato", "egg"] }
    Returns JSON: recipe suggestions from Google Gemini
    """
    ingredients = request.json.get("ingredients", [])
    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    # Example Google Gemini API request
    url = "https://gemini.googleapis.com/v1/recipes:generate"  # Replace with actual endpoint if needed
    headers = {
        "Authorization": f"Bearer {GEMINI_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "ingredients": ingredients,
        "max_results": 5
    }

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        data = response.json()
        return jsonify(data)
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    # Use Render's PORT environment variable; default to 5000 for local testing
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
