from flask import Flask, render_template, request, jsonify, redirect, url_for
from models import init_db, get_orders, create_order, complete_order
from datetime import datetime
import pytz

app = Flask(__name__)

# Initialize database
init_db()

@app.template_filter('dubai_time')
def dubai_time_filter(timestamp):
    """Convert UTC timestamp to Dubai time."""
    if isinstance(timestamp, str):
        try:
            # Try parsing with microseconds
            timestamp = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S.%f')
        except ValueError:
            # If no microseconds, try without them
            timestamp = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
    utc = pytz.UTC.localize(timestamp)
    dubai_tz = pytz.timezone('Asia/Dubai')
    dubai_time = utc.astimezone(dubai_tz)
    return dubai_time.strftime('%Y-%m-%d %H:%M:%S')

# Menu items
menu_items = {
    'Refreshers': {
        'lemon_mint_juice': {'id': 'lemon_mint_juice', 'name': 'Lemon and Mint Juice', 'arabic': 'عصير الليمون والنعناع'},
        'orange_juice': {'id': 'orange_juice', 'name': 'Orange Juice', 'arabic': 'عصير البرتقال'},
        'sparkling_water': {'id': 'sparkling_water', 'name': 'Sparkling Water', 'arabic': 'المياه الغازية'},
        'still_water': {'id': 'still_water', 'name': 'Still Water', 'arabic': 'المياه العادية'}
    },
    'Tea': {
        'assam': {'id': 'assam', 'name': 'Assam', 'arabic': 'آسام', 'options': ['sugar', 'milk']},
        'earl_gray': {'id': 'earl_gray', 'name': 'Earl Gray', 'arabic': 'إيرل جراي', 'options': ['sugar', 'milk']},
        'english_breakfast': {'id': 'english_breakfast', 'name': 'English Breakfast', 'arabic': 'الإفطار الإنجليزي', 'options': ['sugar', 'milk']},
        'green_sencha': {'id': 'green_sencha', 'name': 'Green Sencha', 'arabic': 'الشاي الأخضر سينشا', 'options': ['sugar', 'milk']},
        'jasmin_blossom': {'id': 'jasmin_blossom', 'name': 'Jasmin Blossom', 'arabic': 'زهر الياسمين', 'options': ['sugar', 'milk']},
        'masala_chai': {'id': 'masala_chai', 'name': 'Masala Chai', 'arabic': 'تشاي ماسالا', 'options': ['sugar', 'milk']},
        'moroccan_nights': {'id': 'moroccan_nights', 'name': 'Moroccan Nights', 'arabic': 'الليالي المغربية', 'options': ['sugar', 'milk']},
        'rosehip_hibiscus': {'id': 'rosehip_hibiscus', 'name': 'Rosehip & Hibiscus', 'arabic': 'ورد البري والكركديه', 'options': ['sugar', 'milk']}
    },
    'Coffee': {
        'americano': {'id': 'americano', 'name': 'Americano', 'arabic': 'أمريكانو', 'options': ['sugar']},
        'latte': {'id': 'latte', 'name': 'Latte', 'arabic': 'لاتيه', 'options': ['sugar']},
        'cappuccino': {'id': 'cappuccino', 'name': 'Cappuccino', 'arabic': 'كابتشينو', 'options': ['sugar']},
        'espresso': {'id': 'espresso', 'name': 'Espresso', 'arabic': 'إسبريسو', 'options': ['sugar']}
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