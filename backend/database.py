import os
# from supabase import create_client, Client

# --- SUPABASE CONFIGURATION ---
# To disable simulation mode and use real Supabase:
# 1. pip install supabase
# 2. Set SUPABASE_URL and SUPABASE_KEY in environment variables
# 3. Create a 'transactions' table in your Supabase project

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

# if SUPABASE_URL and SUPABASE_KEY:
#     supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
# else:
#     supabase = None

def log_transaction(txn_data, result):
    """
    Logs transaction data and fraud engine result to the database.
    If Supabase is not configured, logs to stdout.
    """
    record = {
        "transaction_id": txn_data.get("transaction_id"),
        "user_id": txn_data.get("user_id"),
        "amount": txn_data.get("amount"),
        "risk_score": result.get("risk_score"),
        "action": result.get("action"),
        "timestamp": txn_data.get("timestamp")
        # Add other fields as needed
    }

    # if supabase:
    #     try:
    #         response = supabase.table("transactions").insert(record).execute()
    #         # print("Logged to Supabase:", response)
    #     except Exception as e:
    #         print(f"Failed to log to Supabase: {e}")
    # else:
    print(f"[DB-LOG] Transaction Logged: {record}")
    print(f"[DB-LOG] Action: {result.get('action')}")
