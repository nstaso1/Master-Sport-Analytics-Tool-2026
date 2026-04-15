from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
import numpy as np
from sklearn.ensemble import RandomForestRegressor

app = Flask(__name__)
CORS(app)

DB_FILE = 'mystics_db.json'

# ==========================================
# MACHINE LEARNING SETUP
# ==========================================
# Initialize the global Scikit-Learn model
rf_model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42)

def train_initial_model():
    """
    Since we don't have historical CSV data yet, we generate synthetic 
    prospect data to train the model on startup. This teaches the model 
    the "Scouting Logic".
    """
    print("⚙️ Generating synthetic training data and training Random Forest...")
    np.random.seed(42)
    
    # Generate 5,000 fake prospects with normalized stats (0 to 100) for S1-S5
    X_train = np.random.randint(0, 100, size=(5000, 5))
    
    # Calculate a "True" target score based on your weighted heuristic
    # S1 (25%), S2 (25%), S3 (20%), S4 (15%), S5 (15%)
    base_scores = (X_train[:, 0]*0.25 + X_train[:, 1]*0.25 + 
                   X_train[:, 2]*0.20 + X_train[:, 3]*0.15 + X_train[:, 4]*0.15)
    
    # Introduce NON-LINEAR REALITY (This is why we use Random Forest!)
    # E.g., If a player has ELITE primary stats (S1 > 85 and S2 > 85), give them a superstar boost.
    synergy_boost = np.where((X_train[:, 0] > 85) & (X_train[:, 1] > 85), 8, 0)
    
    # E.g., If a player has terrible fundamental stats (S1 < 40), tank their score (bust risk).
    bust_penalty = np.where(X_train[:, 0] < 40, -10, 0)
    
    y_train = np.clip(base_scores + synergy_boost + bust_penalty, 0, 100)
    
    # Train the model
    rf_model.fit(X_train, y_train)
    print("✅ Scikit-Learn Random Forest Model Online & Ready!")

# Train the model right before the server starts accepting requests
train_initial_model()


# ==========================================
# DATABASE ROUTES
# ==========================================
def init_db():
    if not os.path.exists(DB_FILE):
        with open(DB_FILE, 'w') as f:
            json.dump({"masterDB": {}, "boards": {}}, f)

@app.route('/api/database', methods=['GET'])
def get_database():
    init_db()
    with open(DB_FILE, 'r') as f:
        return jsonify(json.load(f))

@app.route('/api/database', methods=['POST'])
def save_database():
    data = request.get_json()
    with open(DB_FILE, 'w') as f:
        json.dump(data, f)
    return jsonify({"status": "success", "message": "Database saved."}), 200


# ==========================================
# PREDICTION ROUTE
# ==========================================
@app.route('/api/predict', methods=['POST'])
def predict_readiness():
    try:
        data = request.get_json()
        
        # Extract the normalized stats sent from the frontend
        s1 = data.get('s1', 50)
        s2 = data.get('s2', 50)
        s3 = data.get('s3', 50)
        s4 = data.get('s4', 50)
        s5 = data.get('s5', 50)
        
        # Format for scikit-learn (2D array: [[s1, s2, s3, s4, s5]])
        features = np.array([[s1, s2, s3, s4, s5]])
        
        # Run the prediction through the Random Forest
        prediction = rf_model.predict(features)[0]
        
        return jsonify({
            "status": "success", 
            "predicted_score": round(prediction, 1)
        }), 200
        
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5000)
