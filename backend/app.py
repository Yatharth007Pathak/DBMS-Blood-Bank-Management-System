from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from db import get_conn

app = Flask(__name__)
CORS(app)

# Root route - test connection
@app.route('/')
def home():
    return jsonify({"message": "✅ Blood Bank Management System Flask Backend is Running"})

# Fetch all donors
@app.route('/api/donors', methods=['GET'])
def get_donors():
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        # Return donors ordered by id ascending so the ID column appears in increasing order
        cursor.execute('SELECT * FROM donors ORDER BY donor_id ASC')
        donors = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(donors)
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Add new donor
@app.route('/api/donors', methods=['POST'])
def add_donor():
    try:
        data = request.get_json()
        name = data.get('name')
        gender = data.get('gender')
        age = data.get('age')
        blood_group = data.get('blood_group')
        phone = data.get('phone')
        email = data.get('email')
        city = data.get('city')
        last_donation = data.get('last_donation')
        # MySQL in strict mode rejects empty string for DATE columns.
        # Normalize empty/blank values to None so they insert as NULL.
        if last_donation is not None and str(last_donation).strip() == '':
            last_donation = None

        conn = get_conn()
        cursor = conn.cursor()
        query = '''
            INSERT INTO donors (name, gender, age, blood_group, phone, email, city, last_donation)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        '''
        cursor.execute(query, (name, gender, age, blood_group, phone, email, city, last_donation))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'Donor added successfully!'}), 201
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Fetch inventory
@app.route('/api/inventory', methods=['GET'])
def get_inventory():
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM inventory')
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Update blood inventory (add/remove units)
@app.route('/api/inventory/update', methods=['POST'])
def update_inventory():
    try:
        data = request.get_json()
        blood_group = data.get('blood_group')
        delta = int(data.get('delta', 0))

        conn = get_conn()
        cursor = conn.cursor(dictionary=True)

        # Fetch current stock
        cursor.execute('SELECT units FROM inventory WHERE blood_group = %s', (blood_group,))
        result = cursor.fetchone()

        if not result:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid blood group'}), 400

        current_units = result['units']
        new_units = current_units + delta

        # Prevent negative inventory
        if new_units < 0:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Insufficient stock to reduce'}), 400

        # Update table safely
        cursor.execute('UPDATE inventory SET units = %s WHERE blood_group = %s', (new_units, blood_group))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'success': True, 'blood_group': blood_group, 'updated_units': new_units})
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Fetch all blood requests
@app.route('/api/requests', methods=['GET'])
def get_requests():
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM requests ORDER BY requested_at DESC')
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Add a new blood request
@app.route('/api/requests', methods=['POST'])
def add_request():
    try:
        data = request.get_json()
        patient_name = data.get('patient_name')
        hospital = data.get('hospital')
        blood_group = data.get('blood_group')
        units_requested = int(data.get('units_requested'))

        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO requests (patient_name, hospital, blood_group, units_requested)
            VALUES (%s, %s, %s, %s)
        ''', (patient_name, hospital, blood_group, units_requested))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': 'Blood request added successfully!'}), 201
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Fulfill a blood request (reduce inventory)
@app.route('/api/requests/<int:request_id>/fulfill', methods=['POST'])
def fulfill_request(request_id):
    try:
        conn = get_conn()
        cursor = conn.cursor(dictionary=True)

        # Get request details
        cursor.execute('SELECT * FROM requests WHERE id = %s', (request_id,))
        req = cursor.fetchone()

        if not req:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Request not found'}), 404

        if req['status'] != 'PENDING':
            cursor.close()
            conn.close()
            return jsonify({'error': 'Request already processed'}), 400

        # Check inventory
        cursor.execute('SELECT units FROM inventory WHERE blood_group = %s', (req['blood_group'],))
        inv = cursor.fetchone()

        if not inv or inv['units'] < req['units_requested']:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Insufficient stock'}), 400

        # Update inventory and mark request fulfilled
        cursor.execute('UPDATE inventory SET units = units - %s WHERE blood_group = %s',
                       (req['units_requested'], req['blood_group']))
        cursor.execute('UPDATE requests SET status = "FULFILLED", fulfilled_at = NOW() WHERE id = %s', (request_id,))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'success': True, 'message': 'Request fulfilled successfully'})
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500


# Update a donor's last_donation date
@app.route('/api/donors/<int:donor_id>/last_donation', methods=['PUT'])
def update_last_donation(donor_id):
    try:
        data = request.get_json() or {}
        last_donation = data.get('last_donation')  # expected 'YYYY-MM-DD' or None

        # Normalize empty string to None
        if last_donation is not None and str(last_donation).strip() == '':
            last_donation = None

        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute('UPDATE donors SET last_donation = %s WHERE id = %s', (last_donation, donor_id))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True, 'donor_id': donor_id, 'last_donation': last_donation})
    except Exception as e:
        print("Error:", e)
        return jsonify({'error': str(e)}), 500

# Run Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
