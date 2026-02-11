import random
import time

# --- Mock ML Model ---
# In a real scenario, you would load:
# import joblib
# model = joblib.load('fraud_model.pkl')

class FraudDetector:
    def __init__(self):
        self.rules = [
            self.rule_amount_anomaly,
            self.rule_velocity_check,
            self.rule_ip_geo_mismatch
        ]

    def rule_amount_anomaly(self, txn):
        # Rule: Amount > $1000 is suspicious if random
        if txn['amount'] > 1000:
            return {"triggered": True, "risk": 0.4, "reason": "High Amount Transaction"}
        return {"triggered": False, "risk": 0.0, "reason": None}

    def rule_velocity_check(self, txn):
        # Fake velocity check
        if random.random() < 0.15: # 15% chance of velocity warning
            return {"triggered": True, "risk": 0.6, "reason": "High Velocity user"}
        return {"triggered": False, "risk": 0.0, "reason": None}

    def rule_ip_geo_mismatch(self, txn):
        # Fake geo check
        if random.random() < 0.05: # 5% chance of geo mismatch
            return {"triggered": True, "risk": 0.8, "reason": "IP vs Billing Geo Mismatch"}
        return {"triggered": False, "risk": 0.0, "reason": None}

    def predict(self, txn):
        total_risk = 0.0
        details = []

        # Run Rules
        for rule in self.rules:
            res = rule(txn)
            if res['triggered']:
                total_risk += res['risk']
                details.append(res['reason'])

        # Add ML Score (simulated)
        # ml_score = model.predict_proba([features])[0][1]
        ml_score = random.random()
        
        # Weighted decision
        final_score = (total_risk * 0.4) + (ml_score * 0.6)
        final_score = min(max(final_score, 0.0), 1.0) # Clamp 0-1

        action = "approved"
        if final_score > 0.8:
            action = "block"
        elif final_score > 0.5:
            action = "review"
        
        return {
            "transaction_id": txn.get('transaction_id'),
            "risk_score": round(final_score * 100, 2),
            "action": action.upper(), # APPROVED, REVIEW, BLOCK
            "factors": details
        }

detector = FraudDetector()

def detect_fraud(data):
    return detector.predict(data)
