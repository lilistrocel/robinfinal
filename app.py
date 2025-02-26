from flask import Flask, render_template, request, jsonify, redirect, url_for
from models import init_db, get_orders, create_order, complete_order

app = Flask(__name__)

# Initialize database
init_db()

# Menu items
menu_items = {
    'Coffee': {
        'americano': {'id': 'americano', 'name': 'Americano'},
        'latte': {'id': 'latte', 'name': 'Latte'},
        'espresso': {'id': 'espresso', 'name': 'Espresso'},
        'cappuccino': {'id': 'cappuccino', 'name': 'Cappuccino'}
    },
    'Tea': {
        'green': {'id': 'green', 'name': 'Green Tea'},
        'black': {'id': 'black', 'name': 'Black Tea'},
        'earl_grey': {'id': 'earl_grey', 'name': 'Earl Grey'},
        'chamomile': {'id': 'chamomile', 'name': 'Chamomile'}
    },
    'Fresh Juice': {
        'orange': {'id': 'orange', 'name': 'Orange Juice'},
        'apple': {'id': 'apple', 'name': 'Apple Juice'},
        'carrot': {'id': 'carrot', 'name': 'Carrot Juice'},
        'mixed': {'id': 'mixed', 'name': 'Mixed Fruit Juice'}
    },
    'Cold Drinks': {
        'cola': {'id': 'cola', 'name': 'Cola'},
        'sprite': {'id': 'sprite', 'name': 'Sprite'},
        'fanta': {'id': 'fanta', 'name': 'Fanta'},
        'water': {'id': 'water', 'name': 'Mineral Water'}
    }
}

@app.route('/')
def index():
    return redirect(url_for('requestor', num=1))

@app.route('/requestor')
@app.route('/requestor/<int:num>')
def requestor(num=1):
    return render_template('index.html', menu_items=menu_items, table_number=num)

@app.route('/supplier')
def supplier():
    orders = get_orders()
    return render_template('supplier.html', orders=orders)

@app.route('/api/orders')
def api_orders():
    return jsonify(get_orders())

@app.route('/api/place-order', methods=['POST'])
def place_order():
    try:
        data = request.json
        table_number = data.get('table_number', 1)  # Default to table 1 if not specified
        extra_request = data.get('extra_request')  # Get extra request if provided
        items = data.get('items', {})  # Get items, default to empty dict if not provided
        
        # Only allow empty orders if there's an extra request
        if not items and not extra_request:
            return jsonify({'success': False, 'error': 'Order must contain items or a special request'})
            
        order_id = create_order(items, table_number, extra_request)
        return jsonify({'success': True, 'order_id': order_id})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/complete-order/<int:order_id>', methods=['POST'])
def api_complete_order(order_id):
    try:
        if complete_order(order_id):
            return jsonify({'success': True})
        return jsonify({'success': False, 'error': 'Order not found'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

def get_item_name(item_id):
    """Helper function to get item name from menu items"""
    for category in menu_items.values():
        if item_id in category:
            return category[item_id]['name']
    return item_id

app.jinja_env.globals.update(get_item_name=get_item_name)

if __name__ == '__main__':
    app.run(debug=True) 