// Mengimpor package Material Design dari Flutter SDK untuk membangun UI.
import 'package:flutter/material.dart';

// Mengimpor service yang berisi fungsi-fungsi untuk mengelola data warga (CRUD).
import '../../services/warga_service.dart';

// Widget utama bertipe StatefulWidget untuk menampilkan dan mengelola daftar warga.
class ListWargaPage extends StatefulWidget {
  const ListWargaPage({super.key}); // Konstruktor dengan key opsional

  @override
  State<ListWargaPage> createState() => _ListWargaPageState(); // Membuat state dari widget ini
}

// State dari ListWargaPage yang menangani logika dan tampilan UI
class _ListWargaPageState extends State<ListWargaPage> {
  final WargaService service =
      WargaService(); // Membuat instance dari service untuk akses API
  List wargaList = []; // List untuk menyimpan data warga yang diambil dari API
  bool isLoading = true; // Status loading, true saat data sedang dimuat

  // initState dipanggil pertama kali saat widget dibuat
  @override
  void initState() {
    super.initState(); // Panggil init bawaan
    loadData(); // Memuat data warga dari API saat halaman dibuka
  }

  // Fungsi untuk mengambil data warga dari API
  Future<void> loadData() async {
    setState(() => isLoading = true); // Tampilkan loading spinner
    try {
      final data = await service
          .getAllWarga(); // Ambil data dari API melalui service
      setState(() {
        wargaList = data; // Simpan data ke dalam list wargaList
      });
    } catch (e) {
      // Jika terjadi error saat ambil data, tampilkan pesan kesalahan
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    } finally {
      setState(
        () => isLoading = false,
      ); // Sembunyikan loading spinner setelah selesai
    }
  }

  // Fungsi untuk menampilkan form tambah atau edit data warga
  Future<void> showForm({Map<String, dynamic>? warga}) async {
    // Controller untuk input nama, alamat, dan iuran
    final namaCtrl = TextEditingController(text: warga?['nama'] ?? '');
    final alamatCtrl = TextEditingController(text: warga?['alamat'] ?? '');
    final iuranCtrl = TextEditingController(
      text: warga?['iuran']?.toString() ?? '',
    ); // Konversi iuran ke string jika ada
    String status =
        warga?['status'] ?? 'Belum Lunas'; // Status default jika tidak ada

    // Menampilkan dialog input menggunakan AlertDialog
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          warga == null ? 'Tambah Warga' : 'Edit Warga',
        ), // Judul dialog
        content: SingleChildScrollView(
          // Supaya konten bisa discroll jika terlalu panjang
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Supaya dialog tidak terlalu tinggi
            children: [
              TextField(
                controller: namaCtrl, // Input nama
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: alamatCtrl, // Input alamat
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: iuranCtrl, // Input iuran
                keyboardType: TextInputType.number, // Hanya angka
                decoration: const InputDecoration(labelText: 'Iuran (Rp)'),
              ),
              DropdownButtonFormField(
                value: status, // Nilai awal dropdown
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Lunas', 'Belum Lunas']
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text(e.toString())),
                    )
                    .toList(), // Buat item dropdown dari list
                onChanged: (v) =>
                    status = v.toString(), // Update status saat dipilih
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // Tutup dialog tanpa menyimpan
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Konversi input iuran ke integer, default 0 jika gagal
              final iuranValue = int.tryParse(iuranCtrl.text.trim()) ?? 0;

              // Buat map data warga dari input form
              final data = {
                'nama': namaCtrl.text.trim(),
                'alamat': alamatCtrl.text.trim(),
                'iuran': iuranValue,
                'status': status,
              };

              // Jika warga null, berarti tambah baru. Jika tidak, update data lama
              if (warga == null) {
                await service.tambahWarga(data); // Tambah data warga baru
              } else {
                await service.updateWarga(
                  warga['id'],
                  data,
                ); // Update data warga lama
              }

              if (context.mounted)
                Navigator.pop(context); // Tutup dialog setelah simpan
              loadData(); // Refresh data di halaman utama
            },
            child: const Text('Simpan'), // Tombol simpan
          ),
        ],
      ),
    );
  }

  // Fungsi utama untuk membangun tampilan halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Iuran Warga'), // Judul halaman di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Ikon refresh
            onPressed: loadData, // Panggil ulang fungsi loadData saat ditekan
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Tampilkan loading spinner jika sedang memuat
          : RefreshIndicator(
              // Widget untuk swipe-to-refresh
              onRefresh: loadData, // Fungsi yang dipanggil saat swipe
              child: wargaList.isEmpty
                  ? const Center(
                      child: Text('Belum ada data'),
                    ) // Tampilkan teks jika data kosong
                  : ListView.builder(
                      // Tampilkan list data warga
                      itemCount: wargaList.length, // Jumlah item dalam list
                      itemBuilder: (context, index) {
                        final w =
                            wargaList[index]; // Ambil data warga per index
                        final warnaStatus = (w['status'] == 'Lunas')
                            ? Colors.green
                            : Colors
                                  .redAccent; // Warna status berdasarkan nilai

                        // Tampilkan data warga dalam bentuk Card
                        return Card(
                          margin: const EdgeInsets.all(8), // Jarak antar kartu
                          child: ListTile(
                            title: Text(w['nama'] ?? '-'), // Nama warga
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w['alamat'] ?? '-'), // Alamat warga
                                Text(
                                  'Iuran: Rp${w['iuran']}', // Jumlah iuran
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  w['status'] ?? '', // Status iuran
                                  style: TextStyle(
                                    color: warnaStatus,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Supaya trailing tidak terlalu lebar
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ), // Tombol edit
                                  onPressed: () =>
                                      showForm(warga: w), // Buka form edit
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ), // Tombol hapus
                                  onPressed: () async {
                                    await service.hapusWarga(
                                      w['id'],
                                    ); // Hapus data warga
                                    loadData(); // Refresh data setelah hapus
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(), // Buka form tambah warga
        child: const Icon(Icons.add), // Ikon tambah
      ),
    );
  }
}
