import mysql.connector
from mysql.connector import pooling
import os

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', 'gp944cawm66'),
    'database': os.environ.get('DB_NAME', 'blood_bank'),
    'auth_plugin': 'mysql_native_password'
}

pool = pooling.MySQLConnectionPool(pool_name='blood_pool', pool_size=5, **DB_CONFIG)

def get_conn():
    return pool.get_connection()
