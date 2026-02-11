// ============================================================
// DECIPHER RADAR — SUPABASE CLIENT
// ============================================================

const SUPABASE_URL = 'https://ixczsqwjnexwhvzxlnnv.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_wAE0KKceH7z4UnR_Gw5o1g_pUkq6k-';

// Initialize Supabase client
let supabase;
if (SUPABASE_URL && SUPABASE_ANON_KEY) {
    supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
} else {
    console.warn("Supabase credentials missing. Data persistence will be local-only.");
}

// ============================================================
// DATA ACCESS LAYER
// ============================================================

const DecipherDB = {
    isLive() {
        return !!supabase;
    },
    // --- TRANSACTIONS ---
    async getRecentTransactions(limit = 10) {
        if (!supabase) return [];
        const { data, error } = await supabase
            .from('transactions')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(limit);
        if (error) console.error('Failed to fetch transactions:', error);
        return data || [];
    },

    async getTransactionsByRisk(riskLevel, limit = 10) {
        if (!supabase) return [];
        const { data, error } = await supabase
            .from('transactions')
            .select('*')
            .eq('risk_level', riskLevel)
            .order('created_at', { ascending: false })
            .limit(limit);
        if (error) console.error('Failed to fetch filtered transactions:', error);
        return data || [];
    },

    // --- METRICS ---
    async getLatestMetrics() {
        if (!supabase) return null;
        const { data, error } = await supabase
            .from('metrics')
            .select('*')
            .order('recorded_at', { ascending: false })
            .limit(1)
            .single();
        if (error) console.error('Failed to fetch metrics:', error);
        return data;
    },

    // --- THREAT EVENTS ---
    async getRecentThreats(limit = 20) {
        if (!supabase) return [];
        const { data, error } = await supabase
            .from('threat_events')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(limit);
        if (error) console.error('Failed to fetch threats:', error);
        return data || [];
    },

    // --- AUDIT LOG ---
    async getRecentLogs(limit = 20) {
        if (!supabase) return [];
        const { data, error } = await supabase
            .from('audit_log')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(limit);
        if (error) console.error('Failed to fetch logs:', error);
        return data || [];
    },

    // --- LIVE STATS (computed) ---
    async getLiveStats() {
        if (!supabase) return null;
        const now = new Date();
        const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

        const [totalRes, blockedRes, criticalRes] = await Promise.all([
            supabase.from('transactions').select('amount', { count: 'exact' }).gte('created_at', yesterday),
            supabase.from('transactions').select('amount', { count: 'exact' }).eq('decision', 'BLOCKED').gte('created_at', yesterday),
            supabase.from('threat_events').select('id', { count: 'exact' }).gte('created_at', yesterday)
        ]);

        const totalCount = totalRes.count || 0;
        const blockedCount = blockedRes.count || 0;
        const blockedAmount = (blockedRes.data || []).reduce((sum, t) => sum + parseFloat(t.amount), 0);

        return {
            transactions_24h: totalCount,
            blocked_24h: blockedCount,
            fraud_blocked_amount: blockedAmount,
            threats_24h: criticalRes.count || 0
        };
    },

    // --- INSERT (for demo simulation) ---
    async insertTransaction(txn) {
        if (!supabase) return txn;
        const { data, error } = await supabase
            .from('transactions')
            .insert(txn)
            .select()
            .single();
        if (error) console.error('Failed to insert transaction:', error);
        return data;
    },

    async insertThreatEvent(threat) {
        if (!supabase) return threat;
        const { data, error } = await supabase
            .from('threat_events')
            .insert(threat)
            .select()
            .single();
        if (error) console.error('Failed to insert threat:', error);
        return data;
    },

    async insertAuditLog(level, message, source = 'SYSTEM') {
        if (!supabase) return;
        const { error } = await supabase
            .from('audit_log')
            .insert({ level, message, source });
        if (error) console.error('Failed to insert log:', error);
    },

    // --- REALTIME SUBSCRIPTIONS ---
    subscribeToTransactions(callback) {
        if (!supabase) return { unsubscribe: () => { } };
        return supabase
            .channel('transactions-realtime')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'transactions'
            }, (payload) => callback(payload.new))
            .subscribe();
    },

    subscribeToThreats(callback) {
        if (!supabase) return { unsubscribe: () => { } };
        return supabase
            .channel('threats-realtime')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'threat_events'
            }, (payload) => callback(payload.new))
            .subscribe();
    },

    subscribeToLogs(callback) {
        if (!supabase) return { unsubscribe: () => { } };
        return supabase
            .channel('logs-realtime')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'audit_log'
            }, (payload) => callback(payload.new))
            .subscribe();
    },

    // --- DEMO: Generate transaction via DB function ---
    async generateDemoTransaction() {
        if (!supabase) return;
        const { error } = await supabase.rpc('generate_demo_transaction');
        if (error) console.error('Failed to generate demo transaction:', error);
    }
};
