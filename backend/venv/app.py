from flask import Flask, request, jsonify
import os, requests

app = Flask(__name__)
API_KEY = os.environ.get("RECIPE_API_KEY")

@app.route("/get_recipe", methods=["POST"])
def get_recipe():
    ingredients = request.json.get("ingredients", [])
    response = requests.get(
        "https://example-recipe-api.com/search",
        params={"ingredients": ",".join(ingredients), "api_key": API_KEY}
    )
    return jsonify(response.json())

if __name__ == "__main__":
    app.run(debug=True)
