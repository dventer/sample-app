from flask import Flask
import distro
app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True

@app.route("/")
def index():
    return distro.info()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
