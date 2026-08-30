from flask import Flask, request, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "nimbuscart")
DB_USER = os.getenv("DB_USER", "nimbus")
DB_PASSWORD = os.getenv("DB_PASSWORD", "nimbuspass")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )


def init_db():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            stock INTEGER NOT NULL
        )
    """)

    conn.commit()
    cur.close()
    conn.close()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/items", methods=["GET"])
def get_items():
    conn = get_connection()

    cur = conn.cursor(cursor_factory=RealDictCursor)

    cur.execute("""
        SELECT id, name, price, stock
        FROM products
        ORDER BY id
    """)

    products = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify(products), 200


@app.route("/items", methods=["POST"])
def add_item():
    data = request.get_json()

    if not data:
        return jsonify({"error": "JSON body is required"}), 400

    name = data.get("name")
    price = data.get("price")
    stock = data.get("stock")

    if name is None or price is None or stock is None:
        return jsonify({
            "error": "name, price and stock are required"
        }), 400

    conn = get_connection()

    cur = conn.cursor(cursor_factory=RealDictCursor)

    cur.execute("""
        INSERT INTO products (name, price, stock)
        VALUES (%s, %s, %s)
        RETURNING id, name, price, stock
    """, (name, price, stock))

    product = cur.fetchone()

    conn.commit()

    cur.close()
    conn.close()

    return jsonify(product), 201


if __name__ == "__main__":
    init_db()

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False
    )
