from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2 import pool
import os
from typing import List, Dict
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=[os.getenv("FRONT_ORIGIN", "*")],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

pg_pool: pool.SimpleConnectionPool | None = None

REQUEST_COUNT = Counter('api_request_count', 'Total HTTP requests', ['path'])


def get_db_conn():
    
    global pg_pool
    if pg_pool is None:
        raise RuntimeError("Le pool de bases de données n'est pas initialisé.")
    return pg_pool.getconn()


@app.on_event("startup")
def startup():
    """Initialiser la pool à l démarrage."""
    global pg_pool
    try:
        pg_pool = psycopg2.pool.SimpleConnectionPool(
            1,
            int(os.getenv("DB_POOL_MAX", "10")),
            host=os.getenv("DB_HOST", "db"),
            port=int(os.getenv("DB_PORT", "5432")),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", "postgres"),
            database=os.getenv("DB_NAME", "postgres"),
        )
        print("Postgres pool crée")
    except Exception as e:
        print("Error de la DB pool:", e)
        raise


@app.on_event("shutdown")
def shutdown():
    """Fermer la pool à l'arrêt."""
    global pg_pool
    if pg_pool:
        pg_pool.closeall()
        pg_pool = None


@app.get("/status")
def status():
    REQUEST_COUNT.labels(path='/status').inc()
    return {"message": "OK"}


@app.get("/items")
def items():
    
    conn = None
    try:
        REQUEST_COUNT.labels(path='/items').inc()
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute("SELECT id, name FROM items;")
        rows = cur.fetchall()
        cur.close()
        # return connection to pool
        pg_pool.putconn(conn)
        conn = None
        return [{"id": r[0], "name": r[1]} for r in rows]
    except Exception as e:
        # ensure conn is returned to pool or closed
        if conn:
            try:
                pg_pool.putconn(conn)
            except Exception:
                try:
                    conn.close()
                except Exception:
                    pass
        raise HTTPException(status_code=500, detail=str(e))


@app.get('/metrics')
def metrics():
    
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

