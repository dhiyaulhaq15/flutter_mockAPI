// Mengimpor package Material Design dari Flutter SDK untuk membangun UI.
import 'package:flutter/material.dart';

// Mengimpor halaman utama untuk admin setelah login berhasil.
// import 'package:flutter_api/screens/admin/admin_page.dart';
import 'package:flutter_api/screens/admin/list_warga.dart';

// Mengimpor halaman login sebagai halaman awal aplikasi.
import 'package:flutter_api/screens/login_page.dart';

// Mengimpor halaman utama untuk operator setelah login berhasil.
import 'package:flutter_api/screens/operator/operator_page.dart';

// Mengimpor halaman utama untuk warga setelah login berhasil.
import 'package:flutter_api/screens/warga/warga_page.dart';

// Fungsi utama yang dijalankan pertama kali saat aplikasi dimulai.
void main() {
  runApp(const MyApp()); // Menjalankan aplikasi Flutter dengan widget MyApp sebagai root.
}

// Widget utama aplikasi, bertipe StatelessWidget karena tidak memiliki state yang berubah.
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktor dengan key opsional.

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // MaterialApp adalah root dari aplikasi Flutter berbasis Material Design.
      debugShowCheckedModeBanner: false, // Menyembunyikan banner "debug" di pojok kanan atas.
      title: 'Iuran Warga', // Judul aplikasi (tidak tampil di UI, tapi digunakan oleh sistem).
      initialRoute: '/', // Menentukan rute awal saat aplikasi dibuka, yaitu halaman login.
      routes: {
        '/': (context) => const LoginPage(), // Rute untuk halaman login.
        '/admin': (context) => const ListWargaPage(), // Rute untuk halaman admin.
        '/operator': (context) => const OperatorPage(), // Rute untuk halaman operator.
        '/warga': (context) => const WargaPage(), // Rute untuk halaman warga.
      },
    );
  }
}
