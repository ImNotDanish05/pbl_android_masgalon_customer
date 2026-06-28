// // 1. Dapatkan ID user yang sedang login saat ini
// final userId = Supabase.instance.client.auth.currentUser!.id;

// // 2. Tembak tabel 'customers' untuk mengambil data user tersebut
// final userData = await Supabase.instance.client
//     .from('customers')
//     .select('*') // Ambil semua kolom (username, saldo_abunemen, dll)
//     .eq('user_id', userId) // WAJIB ADA: Filter agar hanya mengambil saldo milik user ini saja!
//     .single(); // Gunakan .single() karena 1 user pasti hanya punya 1 baris data
    
// // 3. Masukkan 'userData' ke dalam struktur model Customer-mu (Riverpod authCustomerProvider)