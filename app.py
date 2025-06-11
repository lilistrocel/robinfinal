from flask import Flask, render_template, request, jsonify, redirect, url_for
from models import init_db, get_orders, create_order, complete_order

app = Flask(__name__)

# Initialize database
init_db()

# Menu items
menu_items = {
    'Coffee & Espresso': {
        'single_espresso': {'id': 'single_espresso', 'name': 'Single Espresso', 'arabic': 'إسبريسو مفرد'},
        'double_espresso': {'id': 'double_espresso', 'name': 'Double Espresso', 'arabic': 'إسبريسو مزدوج'},
        'americano': {'id': 'americano', 'name': 'Americano', 'arabic': 'أمريكانو'},
        'cappuccino': {'id': 'cappuccino', 'name': 'Cappuccino', 'arabic': 'كابتشينو'},
        'flat_white': {'id': 'flat_white', 'name': 'Flat White', 'arabic': 'فلات وايت'},
        'spanish_latte': {'id': 'spanish_latte', 'name': 'Spanish Latte', 'arabic': 'سبانيش لاتيه'}
    },
    'Specialty Drinks': {
        'rubicon_coconut_water': {'id': 'rubicon_coconut_water', 'name': 'Rubicon Organic Coconut Water', 'arabic': 'ماء جوز الهند العضوي من روبيكون'},
        'vitamin_well_care': {'id': 'vitamin_well_care', 'name': 'Vitamin Well Care Drink', 'arabic': 'مشروب فيتامين ويل – كير'}
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

def get_item_display_name(item_id):
    """Helper function to get bilingual display name for items"""
    for category in menu_items.values():
        if item_id in category:
            item = category[item_id]
            return f"{item['name']} ({item['arabic']})"
    return item_id

app.jinja_env.globals.update(get_item_name=get_item_name, get_item_display_name=get_item_display_name)

if __name__ == '__main__':
    app.run(debug=True) 