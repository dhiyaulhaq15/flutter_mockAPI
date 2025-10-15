// Mengimpor library 'dart:convert' untuk mengubah data JSON menjadi objek Dart dan sebaliknya.
import 'dart:convert';

// Mengimpor package 'http' untuk melakukan permintaan HTTP seperti GET, POST, PUT, DELETE.
import 'package:http/http.dart' as http;

// Membuat class WargaService untuk mengelola data warga melalui API.
class WargaService {
  // URL endpoint dari mock API yang digunakan untuk operasi CRUD data warga.
  final String baseUrl =
      'https://68eb1b1376b3362414ccd959.mockapi.io/api/v1/wargas';

  // ============================
  // Fungsi: Mengambil semua data warga dari API
  // Return: List (berisi data warga dalam bentuk Map)
  // ============================
  Future<List> getAllWarga() async {
    final res = await http.get(Uri.parse(baseUrl)); // Kirim permintaan GET ke endpoint
    if (res.statusCode == 200) {
      return jsonDecode(res.body); // Jika berhasil, decode JSON dan kembalikan sebagai List
    } else {
      throw Exception('Gagal memuat data warga'); // Jika gagal, lempar exception
    }
  }

  // ============================
  // Fungsi: Menambahkan data warga baru ke server
  // Parameter: data (Map<String, dynamic>) berisi informasi warga
  // Return: void (tidak mengembalikan nilai)
  // ============================
  Future<void> tambahWarga(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(baseUrl), // Endpoint POST
      headers: {'Content-Type': 'application/json'}, // Header wajib untuk JSON
      body: jsonEncode(data), // Encode data ke format JSON
    );

    if (res.statusCode != 201) {
      // Status 201 artinya berhasil membuat data baru
      throw Exception('Gagal menambah data warga');
    }
  }

  // ============================
  // Fungsi: Memperbarui data warga berdasarkan ID
  // Parameter: id (String), data (Map<String, dynamic>)
  // Return: void
  // ============================
  Future<void> updateWarga(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'), // Endpoint PUT ke /wargas/{id}
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      // Status 200 artinya update berhasil
      throw Exception('Gagal memperbarui data warga');
    }
  }

  // ============================
  // Fungsi: Menghapus data warga berdasarkan ID
  // Parameter: id (String)
  // Return: void
  // ============================
  Future<void> hapusWarga(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id')); // Kirim DELETE ke endpoint
    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus data warga');
    }
  }
}
