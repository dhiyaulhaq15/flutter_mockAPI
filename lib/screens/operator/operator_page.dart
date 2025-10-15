// Import library Flutter untuk membangun UI
import 'package:flutter/material.dart';

// Import halaman login untuk navigasi jika belum login
import 'package:flutter_api/screens/login_page.dart';

// Import SharedPreferences untuk menyimpan data lokal seperti status login
import 'package:shared_preferences/shared_preferences.dart';

// Widget utama untuk halaman Operator, menggunakan StatefulWidget karena ada proses login dan logout
class OperatorPage extends StatefulWidget {
  const OperatorPage({super.key}); // Konstruktor dengan key opsional

  @override
  State<OperatorPage> createState() => _OperatorPageState(); // Membuat state dari OperatorPage
}

// State dari halaman Operator
class _OperatorPageState extends State<OperatorPage> {
  @override
  void initState() {
    super.initState(); // Memanggil init bawaan Flutter
    _checkLogin(); // Mengecek status login saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengecek apakah user sudah login dan memiliki role 'operator'
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance(); // Mengakses penyimpanan lokal
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Ambil status login, default false jika null
    final role = prefs.getString('role'); // Ambil role user dari penyimpanan

    // Kalau belum login atau bukan role 'operator', arahkan ke halaman login
    if (!isLoggedIn || role != 'operator') {
      if (mounted) { // Pastikan widget masih aktif di tree sebelum navigasi
        Navigator.pushReplacement( // Ganti halaman ke LoginPage dan hapus halaman ini dari stack
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()), // Navigasi ke LoginPage
        );
      }
    }
  }

  // Fungsi untuk logout dan hapus semua data dari penyimpanan lokal
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance(); // Akses penyimpanan lokal
    await prefs.clear(); // Hapus semua data login dan user

    if (mounted) { // Pastikan widget masih aktif sebelum navigasi
      Navigator.pushAndRemoveUntil( // Navigasi ke LoginPage dan hapus semua halaman sebelumnya
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()), // Tujuan navigasi: LoginPage
        (route) => false, // Hapus semua route agar tidak bisa kembali ke halaman sebelumnya
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold adalah struktur dasar halaman Flutter
      appBar: AppBar( // AppBar di bagian atas halaman
        title: const Text('Halaman Operator'), // Judul halaman
        actions: [ // Widget tambahan di kanan AppBar
          IconButton( // Tombol ikon untuk logout
            onPressed: _logout, // Ketika ditekan, jalankan fungsi logout
            icon: const Icon(Icons.logout), // Ikon logout
            tooltip: 'Logout', // Tooltip saat hover (di web atau desktop)
          ),
        ],
      ),
      body: const Center( // Bagian isi halaman
        child: Text('Selamat datang, Operator!'), // Teks sambutan untuk operator
      ),
    );
  }
}
