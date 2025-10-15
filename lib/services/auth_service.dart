// Mengimpor package dart:convert untuk mengubah data JSON menjadi objek Dart.
import 'dart:convert';

// Mengimpor package http untuk melakukan request ke API.
import 'package:http/http.dart' as http;

// Kelas AuthService berfungsi untuk menangani proses autentikasi (login).
class AuthService {
  // URL endpoint dari mock API untuk login.
  final String baseUrl =
      'https://68eb1b1376b3362414ccd959.mockapi.io/api/v1/logins';

  // Fungsi login yang menerima email dan password, lalu mengembalikan data user jika cocok.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    // Membuat URL dengan query parameter email dan password.
    final url = Uri.parse('$baseUrl?email=$email&password=$password');

    // Melakukan request GET ke API menggunakan http package.
    final response = await http.get(url);

    // Jika status response 200 (OK), berarti request berhasil.
    if (response.statusCode == 200) {
      // Mengubah response body dari JSON menjadi List objek Dart.
      final List data = jsonDecode(response.body);

      // Jika data tidak kosong, ambil user pertama yang cocok.
      if (data.isNotEmpty) {
        return data.first; // Mengembalikan data user pertama.
      } else {
        return null; // Jika data kosong, berarti tidak ada user yang cocok.
      }
    } else {
      // Jika status bukan 200, lempar exception sebagai error.
      throw Exception('Gagal menghubungi server');
    }
  }
}
