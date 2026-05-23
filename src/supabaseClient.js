import { createClient } from '@supabase/supabase-js';

const supabaseUrl     = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabaseSvcKey  = import.meta.env.VITE_SUPABASE_SERVICE_KEY;

// Normal client — kullanıcılar için (okuma işlemleri)
export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Admin client — yazma işlemleri için (RLS bypass)
// VITE_SUPABASE_SERVICE_KEY tanımlı değilse normal client'a düşer
export const supabaseAdmin = supabaseSvcKey
  ? createClient(supabaseUrl, supabaseSvcKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    })
  : supabase;
