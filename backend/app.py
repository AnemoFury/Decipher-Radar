from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import time
from ml_engine import detect_fraud
from database import log_transaction

app = FastAPI(title="Decipher ML API", version="1.0.0")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TransactionRequest(BaseModel):
    transaction_id: str
    amount: float
    user_id: str
    location: str
    device_id: str
    ip_address: str
    timestamp: float

@app.get("/")
def read_root():
    return {"status": "active", "model_version": "v1.2.4-stable"}

@app.post("/predict")
async def predict_fraud(txn: TransactionRequest):
    # Simulate processing delay (network/ml inference)
    time.sleep(random.uniform(0.05, 0.2)) 
    
    # Run detection logic (Rules + ML)
    result = detect_fraud({
        "transaction_id": txn.transaction_id,
        "amount": txn.amount,
        "location": txn.location,
        "device_id": txn.device_id,
        "ip": txn.ip_address
    })
    
    # Log to database (Supabase stub)
    log_transaction(txn.dict(), result)

    return result
