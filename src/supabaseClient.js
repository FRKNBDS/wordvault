import { createClient } from '@supabase/supabase-js';

const supabaseUrl     = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Tek client — okuma işlemleri için (RLS korumalı)
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
