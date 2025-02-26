import sqlite3
from datetime import datetime
import json
import os
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Get the absolute path to the instance directory
DB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), 'instance'))
DB_PATH = os.path.join(DB_DIR, 'cafe_orders.db')

logger.debug(f"Database directory: {DB_DIR}")
logger.debug(f"Database path: {DB_PATH}")

# Create instance directory if it doesn't exist
os.makedirs(DB_DIR, exist_ok=True)

def init_db():
    """Initialize the database and create tables if they don't exist."""
    logger.debug("Initializing database...")
    # Ensure we have a fresh connection when creating tables
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        
        # Enable foreign keys
        cursor.execute('PRAGMA foreign_keys = ON')
        logger.debug("Foreign keys enabled")
        
        # Create orders table if it doesn't exist
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME NOT NULL,
                status TEXT NOT NULL DEFAULT 'pending',
                table_number INTEGER NOT NULL,
                extra_request TEXT
            )
        ''')
        logger.debug("Orders table created or already exists")
        
        # Create order_items table if it doesn't exist
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                item_id TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
            )
        ''')
        logger.debug("Order items table created or already exists")
        
        # Verify tables exist
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        logger.debug(f"Existing tables: {tables}")
        
        # Commit the changes
        conn.commit()
        logger.debug("Database initialization completed")

def get_db():
    """Get a database connection with row factory enabled."""
    logger.debug(f"Opening database connection to {DB_PATH}")
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    # Enable foreign keys for each connection
    conn.execute('PRAGMA foreign_keys = ON')
    return conn

def create_order(items, table_number, extra_request=None):
    """Create a new order with the given items, table number, and optional extra request."""
    logger.debug(f"Creating new order with items: {items} for table {table_number}, extra request: {extra_request}")
    with get_db() as conn:
        cursor = conn.cursor()
        try:
            # Create order
            cursor.execute(
                'INSERT INTO orders (timestamp, status, table_number, extra_request) VALUES (?, ?, ?, ?)',
                (datetime.utcnow(), 'pending', table_number, extra_request)
            )
            order_id = cursor.lastrowid
            logger.debug(f"Created order with ID: {order_id}")
            
            # Add order items
            for item_id, quantity in items.items():
                cursor.execute(
                    'INSERT INTO order_items (order_id, item_id, quantity) VALUES (?, ?, ?)',
                    (order_id, item_id, quantity)
                )
                logger.debug(f"Added item {item_id} with quantity {quantity} to order {order_id}")
            
            conn.commit()
            return order_id
        except sqlite3.Error as e:
            conn.rollback()
            logger.error(f"Error creating order: {str(e)}")
            raise Exception(f"Failed to create order: {str(e)}")

def get_orders():
    """Get all orders with their items, sorted by timestamp descending."""
    logger.debug("Fetching all orders")
    with get_db() as conn:
        cursor = conn.cursor()
        try:
            orders = []
            # Get all orders, both pending and completed
            cursor.execute('SELECT * FROM orders ORDER BY timestamp DESC')
            all_orders = cursor.fetchall()
            
            for order in all_orders:
                # Get items for this order
                cursor.execute('SELECT item_id, quantity FROM order_items WHERE order_id = ?', (order['id'],))
                items = {row['item_id']: row['quantity'] for row in cursor.fetchall()}
                
                orders.append({
                    'id': order['id'],
                    'timestamp': order['timestamp'],
                    'status': order['status'],
                    'table_number': order['table_number'],
                    'extra_request': order['extra_request'],
                    'items': items
                })
            logger.debug(f"Found {len(orders)} orders")
            return orders
        except sqlite3.Error as e:
            logger.error(f"Error fetching orders: {str(e)}")
            raise Exception(f"Failed to get orders: {str(e)}")

def complete_order(order_id):
    """Mark an order as completed."""
    logger.debug(f"Marking order {order_id} as completed")
    with get_db() as conn:
        cursor = conn.cursor()
        try:
            cursor.execute(
                'UPDATE orders SET status = ? WHERE id = ?',
                ('completed', order_id)
            )
            conn.commit()
            success = cursor.rowcount > 0
            logger.debug(f"Order {order_id} completion {'successful' if success else 'failed'}")
            return success
        except sqlite3.Error as e:
            conn.rollback()
            logger.error(f"Error completing order: {str(e)}")
            raise Exception(f"Failed to complete order: {str(e)}")

# Initialize the database when this module is imported
init_db() 