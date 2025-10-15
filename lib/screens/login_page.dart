// Mengimpor package Material Design dari Flutter SDK untuk membangun UI.
import 'package:flutter/material.dart';

// Mengimpor SharedPreferences untuk menyimpan data login secara lokal.
import 'package:shared_preferences/shared_preferences.dart';

// Mengimpor halaman ListWargaPage (komentar ini bisa dihapus jika tidak digunakan).

// Mengimpor service untuk autentikasi pengguna (login).
import '../services/auth_service.dart';
// import 'list_warga.dart'; // Komentar ini bisa dihapus jika tidak digunakan.

// Widget LoginPage menggunakan StatefulWidget karena ada perubahan state (loading, error, input).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Constructor dengan key opsional.

  @override
  State<LoginPage> createState() => _LoginPageState(); // Membuat state untuk LoginPage.
}

// State dari LoginPage yang berisi logika dan tampilan login.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form.
  final emailCtrl = TextEditingController(); // Controller untuk input email.
  final passCtrl = TextEditingController(); // Controller untuk input password.
  final AuthService auth = AuthService(); // Instance dari AuthService untuk login.

  bool isLoading = false; // Menandakan apakah sedang proses login.
  String? errorMsg; // Menyimpan pesan error jika login gagal.

  // Fungsi untuk menangani proses login.
  Future<void> handleLogin() async {
    // Validasi form, jika tidak valid maka hentikan proses.
    if (!_formKey.currentState!.validate()) return;

    // Set state menjadi loading dan hapus pesan error sebelumnya.
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // Panggil fungsi login dari AuthService dengan email dan password yang diinput.
      final user = await auth.login(emailCtrl.text, passCtrl.text);

      // Debug log untuk melihat hasil login dan input.
      print('User dari API: $user');
      print('Email input: ${emailCtrl.text}');
      print('Password input: ${passCtrl.text}');

      // Jika login berhasil dan user tidak null
      if (user != null) {
        final role = user['role']; // Ambil peran (role) dari data user

        // Simpan status login dan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // Tandai bahwa user sudah login
        await prefs.setString('role', role); // Simpan role user
        await prefs.setString('email', user['email']); // Simpan email user

        // Pastikan widget masih aktif sebelum navigasi
        if (!mounted) return;

        // Navigasi ke halaman sesuai role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin'); // Halaman admin
        } else if (role == 'operator') {
          Navigator.pushReplacementNamed(context, '/operator'); // Halaman operator
        } else {
          Navigator.pushReplacementNamed(context, '/warga'); // Halaman warga
        }
      } else {
        // Jika user null, berarti login gagal
        setState(() => errorMsg = 'Email atau password salah');
      }
    } catch (e) {
      // Tangkap error dan tampilkan pesan
      setState(() => errorMsg = 'Gagal login: ${e.toString()}');
    }

    // Setelah proses selesai, set loading menjadi false.
    setState(() => isLoading = false);
  }

  // Method build untuk membangun tampilan UI login.
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Struktur dasar halaman
      body: Center( // Menempatkan konten di tengah layar
        child: Padding(
          padding: const EdgeInsets.all(24), // Memberikan padding di semua sisi
          child: Form(
            key: _formKey, // Menghubungkan form dengan key untuk validasi
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Posisikan konten di tengah vertikal
              children: [
                const Text(
                  'Login Iuran Warga', // Judul halaman login
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // Spasi vertikal

                // Input email
                TextFormField(
                  controller: emailCtrl, // Menghubungkan input dengan controller
                  decoration: const InputDecoration(
                    labelText: 'Email', // Label input
                  ),
                  validator: (v) => v!.isEmpty
                      ? 'Email wajib diisi'
                      : null, // Validasi wajib isi
                ),

                // Input password
                TextFormField(
                  controller: passCtrl, // Controller untuk password
                  decoration: const InputDecoration(labelText: 'Password'), // Label input
                  obscureText: true, // Menyembunyikan teks password
                  validator: (v) => v!.isEmpty
                      ? 'Password wajib diisi'
                      : null, // Validasi wajib isi
                ),

                const SizedBox(height: 20), // Spasi vertikal

                // Menampilkan pesan error jika ada
                if (errorMsg != null)
                  Text(
                    errorMsg!, // Tampilkan pesan error
                    style: const TextStyle(
                      color: Colors.red, // Warna merah untuk error
                    ),
                  ),

                const SizedBox(height: 10), // Spasi vertikal

                // Tombol login
                ElevatedButton(
                  onPressed: isLoading
                      ? null // Disable tombol jika sedang loading
                      : handleLogin, // Jalankan fungsi login
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Tampilkan loading spinner saat proses login
                      : const Text('Login'), // Tampilkan teks tombol
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
