from flask import Flask
from datetime import date
app = Flask(__name__)

@app.route("/")
def index():
    start = '25/10/2021'
    today = date.today()
    return f'Xendit - Trial - Jefri Adventer - {start} - {today.strftime("%d/%m/%Y")}'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
