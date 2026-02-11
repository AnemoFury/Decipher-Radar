-- ============================================================
-- DECIPHER RADAR — SUPABASE DATABASE SCHEMA
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- ============================================================

-- 1. TRANSACTIONS TABLE — Core fraud detection events
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_id TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now(),
    amount NUMERIC(12,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    risk_score NUMERIC(5,4) NOT NULL DEFAULT 0,
    risk_level TEXT NOT NULL DEFAULT 'SAFE' CHECK (risk_level IN ('SAFE', 'SUSPICIOUS', 'CRITICAL')),
    decision TEXT NOT NULL DEFAULT 'APPROVED' CHECK (decision IN ('APPROVED', 'REVIEW', 'BLOCKED')),
    rule_triggered TEXT DEFAULT 'NONE',
    ip_address INET,
    device_fingerprint TEXT,
    card_bin TEXT,
    merchant_id TEXT,
    user_id UUID
);

-- 2. THREAT_EVENTS TABLE — Radar map threat detections
CREATE TABLE IF NOT EXISTS threat_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    city TEXT NOT NULL,
    country_code TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    risk_score INTEGER NOT NULL DEFAULT 60,
    vector TEXT NOT NULL,
    source_ip INET,
    fingerprint TEXT,
    resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ
);

-- 3. METRICS TABLE — Rolling KPI snapshots
CREATE TABLE IF NOT EXISTS metrics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recorded_at TIMESTAMPTZ DEFAULT now(),
    fraud_blocked_24h NUMERIC(14,2) DEFAULT 0,
    model_accuracy NUMERIC(6,4) DEFAULT 0.9998,
    avg_processing_ms NUMERIC(6,2) DEFAULT 3.2,
    active_sessions INTEGER DEFAULT 0,
    total_throughput BIGINT DEFAULT 0,
    transactions_24h INTEGER DEFAULT 0,
    blocked_24h INTEGER DEFAULT 0
);

-- 4. AUDIT_LOG TABLE — System events for Intelligence Feed
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    level TEXT NOT NULL DEFAULT 'INFO' CHECK (level IN ('INFO', 'WARN', 'ERROR', 'ALERT')),
    message TEXT NOT NULL,
    source TEXT DEFAULT 'SYSTEM',
    metadata JSONB DEFAULT '{}'
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX idx_transactions_risk_level ON transactions(risk_level);
CREATE INDEX idx_transactions_city ON transactions(city);
CREATE INDEX idx_threat_events_created_at ON threat_events(created_at DESC);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);

-- ============================================================
-- ENABLE REALTIME — for live dashboard updates
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE threat_events;
ALTER PUBLICATION supabase_realtime ADD TABLE audit_log;
ALTER PUBLICATION supabase_realtime ADD TABLE metrics;

-- ============================================================
-- ROW LEVEL SECURITY — Allow read for anon (public dashboard)
-- ============================================================
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE threat_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Public read access (anon key can read)
CREATE POLICY "Public read transactions" ON transactions FOR SELECT USING (true);
CREATE POLICY "Public read threat_events" ON threat_events FOR SELECT USING (true);
CREATE POLICY "Public read metrics" ON metrics FOR SELECT USING (true);
CREATE POLICY "Public read audit_log" ON audit_log FOR SELECT USING (true);

-- Allow inserts from service role (and authenticated users)
CREATE POLICY "Service insert transactions" ON transactions FOR INSERT WITH CHECK (true);
CREATE POLICY "Service insert threat_events" ON threat_events FOR INSERT WITH CHECK (true);
CREATE POLICY "Service insert metrics" ON metrics FOR INSERT WITH CHECK (true);
CREATE POLICY "Service insert audit_log" ON audit_log FOR INSERT WITH CHECK (true);

-- ============================================================
-- SEED: Insert initial metrics row
-- ============================================================
INSERT INTO metrics (fraud_blocked_24h, model_accuracy, avg_processing_ms, active_sessions, total_throughput, transactions_24h, blocked_24h)
VALUES (1240000.00, 0.9998, 3.2, 12402, 42800000, 84210, 1247);

-- ============================================================
-- SEED: Insert some realistic recent transactions
-- ============================================================
INSERT INTO transactions (event_id, amount, currency, city, country, lat, lon, risk_score, risk_level, decision, rule_triggered, ip_address) VALUES
    ('evt_' || extract(epoch from now())::bigint || '_001', 2499.99, 'USD', 'New York', 'US', 40.7128, -74.0060, 0.12, 'SAFE', 'APPROVED', 'NONE', '72.14.201.48'),
    ('evt_' || extract(epoch from now())::bigint || '_002', 899.50, 'EUR', 'Berlin', 'DE', 52.5200, 13.4050, 0.08, 'SAFE', 'APPROVED', 'NONE', '88.130.52.11'),
    ('evt_' || extract(epoch from now())::bigint || '_003', 15000.00, 'INR', 'Mumbai', 'IN', 19.0760, 72.8777, 0.92, 'CRITICAL', 'BLOCKED', 'IMPOSSIBLE_TRAVEL', '103.22.41.9'),
    ('evt_' || extract(epoch from now())::bigint || '_004', 4200.00, 'EUR', 'Brussels', 'BE', 50.8503, 4.3517, 0.65, 'SUSPICIOUS', 'REVIEW', 'NEW_DEVICE', '91.182.4.22'),
    ('evt_' || extract(epoch from now())::bigint || '_005', 750.00, 'GBP', 'London', 'GB', 51.5074, -0.1278, 0.05, 'SAFE', 'APPROVED', 'NONE', '86.150.22.91'),
    ('evt_' || extract(epoch from now())::bigint || '_006', 3200.00, 'JPY', 'Tokyo', 'JP', 35.6762, 139.6503, 0.88, 'CRITICAL', 'BLOCKED', 'VELOCITY_ABUSE', '210.152.18.44'),
    ('evt_' || extract(epoch from now())::bigint || '_007', 560.00, 'AUD', 'Sydney', 'AU', -33.8688, 151.2093, 0.15, 'SAFE', 'APPROVED', 'NONE', '203.8.183.1'),
    ('evt_' || extract(epoch from now())::bigint || '_008', 8900.00, 'BRL', 'Sao Paulo', 'BR', -23.5505, -46.6333, 0.71, 'SUSPICIOUS', 'REVIEW', 'GEO_ANOMALY', '177.54.11.2');

-- ============================================================
-- SEED: Insert threat events
-- ============================================================
INSERT INTO threat_events (city, country_code, lat, lon, risk_score, vector, source_ip, fingerprint) VALUES
    ('Berlin', 'DE', 52.52, 13.40, 87, 'Credential Stuffing', '185.12.3.94', 'SHA-256: A8F2..3C'),
    ('Mumbai', 'IN', 19.07, 72.87, 94, 'SIM Swap Fraud', '103.22.41.9', 'SHA-256: 7B1E..D4'),
    ('New York', 'US', 40.71, -74.00, 76, 'Sequential Card Attempt', '72.14.201.48', 'SHA-256: 3F9A..B1'),
    ('Tokyo', 'JP', 35.68, 139.69, 91, 'Device Fingerprint Mismatch', '210.152.18.44', 'SHA-256: C2D8..E7');

-- ============================================================
-- FUNCTION: Generate a simulated transaction (for demo)
-- Call this via: SELECT generate_demo_transaction();
-- ============================================================
CREATE OR REPLACE FUNCTION generate_demo_transaction()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    cities TEXT[] := ARRAY['New York', 'Berlin', 'Mumbai', 'Brussels', 'London', 'Tokyo', 'Sydney', 'Sao Paulo', 'Moscow', 'Shanghai', 'Lagos', 'Dubai', 'Singapore', 'Toronto', 'Seoul', 'Istanbul', 'Nairobi', 'Mexico City'];
    countries TEXT[] := ARRAY['US', 'DE', 'IN', 'BE', 'GB', 'JP', 'AU', 'BR', 'RU', 'CN', 'NG', 'AE', 'SG', 'CA', 'KR', 'TR', 'KE', 'MX'];
    currencies TEXT[] := ARRAY['USD', 'EUR', 'INR', 'EUR', 'GBP', 'JPY', 'AUD', 'BRL', 'RUB', 'CNY', 'NGN', 'AED', 'SGD', 'CAD', 'KRW', 'TRY', 'KES', 'MXN'];
    lats DOUBLE PRECISION[] := ARRAY[40.71, 52.52, 19.07, 50.85, 51.50, 35.68, -33.86, -23.55, 55.75, 31.23, 6.52, 25.20, 1.35, 43.65, 37.56, 41.00, -1.28, 19.43];
    lons DOUBLE PRECISION[] := ARRAY[-74.00, 13.40, 72.87, 4.35, -0.12, 139.69, 151.20, -46.63, 37.61, 121.47, 3.37, 55.27, 103.81, -79.38, 126.97, 28.97, 36.81, -99.13];
    vectors TEXT[] := ARRAY['Sequential Card Attempt', 'Credential Stuffing', 'SIM Swap Fraud', 'Velocity Abuse', 'Device Fingerprint Mismatch', 'Geo-Anomaly', 'ATO - Account Takeover', 'Card Not Present', 'Bot Attack Detected', 'Synthetic Identity', 'Chargeback Pattern'];
    
    idx INTEGER;
    score NUMERIC(5,4);
    rlevel TEXT;
    rdecision TEXT;
    rrule TEXT;
BEGIN
    idx := floor(random() * array_length(cities, 1)) + 1;
    score := random();
    
    IF score > 0.85 THEN
        rlevel := 'CRITICAL';
        rdecision := 'BLOCKED';
        rrule := vectors[floor(random() * array_length(vectors, 1)) + 1];
    ELSIF score > 0.6 THEN
        rlevel := 'SUSPICIOUS';
        rdecision := 'REVIEW';
        rrule := 'NEW_DEVICE';
    ELSE
        rlevel := 'SAFE';
        rdecision := 'APPROVED';
        rrule := 'NONE';
    END IF;
    
    INSERT INTO transactions (event_id, amount, currency, city, country, lat, lon, risk_score, risk_level, decision, rule_triggered, ip_address)
    VALUES (
        'evt_' || extract(epoch from now())::bigint || '_' || floor(random() * 9999)::text,
        (random() * 9900 + 100)::numeric(12,2),
        currencies[idx],
        cities[idx],
        countries[idx],
        lats[idx],
        lons[idx],
        score,
        rlevel,
        rdecision,
        rrule,
        (floor(random() * 223 + 1)::text || '.' || floor(random() * 255)::text || '.' || floor(random() * 255)::text || '.' || floor(random() * 255)::text)::inet
    );
    
    -- Also create threat event if critical
    IF rlevel = 'CRITICAL' THEN
        INSERT INTO threat_events (city, country_code, lat, lon, risk_score, vector, source_ip)
        VALUES (cities[idx], countries[idx], lats[idx], lons[idx], (score * 100)::integer, rrule,
            (floor(random() * 223 + 1)::text || '.' || floor(random() * 255)::text || '.' || floor(random() * 255)::text || '.' || floor(random() * 255)::text)::inet);
    END IF;
    
    -- Log it
    INSERT INTO audit_log (level, message, source)
    VALUES (
        CASE WHEN rlevel = 'CRITICAL' THEN 'ALERT' WHEN rlevel = 'SUSPICIOUS' THEN 'WARN' ELSE 'INFO' END,
        'Transaction ' || rlevel || ' from ' || cities[idx] || ' (' || countries[idx] || ') — $' || (random() * 9900 + 100)::numeric(8,2),
        'FRAUD_ENGINE'
    );
END;
$$;

-- ============================================================
-- CRON: Use pg_cron (if available) or call generate_demo_transaction()
-- from an Edge Function on a schedule for continuous demo data
-- ============================================================
-- To test manually: SELECT generate_demo_transaction();
