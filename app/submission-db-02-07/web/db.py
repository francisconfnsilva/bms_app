#!/usr/bin/python3
import psycopg2

IST_ID = 'ist1113250'
HOST = 'db.tecnico.ulisboa.pt'
PORT = 5432
PASSWORD = 'Mestradoist2024'
DB_NAME = IST_ID

def get_connection():
    dsn = f"host={HOST} port={PORT} user={IST_ID} password={PASSWORD} dbname={DB_NAME}"
    return psycopg2.connect(dsn)
