// Import library Flutter untuk membangun UI
import 'package:flutter/material.dart';

// Import halaman login untuk navigasi jika belum login
import 'package:flutter_api/screens/login_page.dart';

// Import SharedPreferences untuk menyimpan data lokal seperti status login
import 'package:shared_preferences/shared_preferences.dart';

// Widget utama untuk halaman warga, menggunakan StatefulWidget karena ada perubahan state (navigasi tab)
class WargaPage extends StatefulWidget {
  const WargaPage({super.key}); // Konstruktor dengan key opsional

  @override
  State<WargaPage> createState() => _WargaPageState(); // Membuat state dari WargaPage
}

// State dari WargaPage
class _WargaPageState extends State<WargaPage> {
  int _selectedIndex =
      0; // Menyimpan index tab yang sedang aktif (0 = Beranda, 1 = Profil)

  // List halaman yang akan ditampilkan berdasarkan index tab
  final List<Widget> _pages = const [WargaHomeSection(), WargaProfileSection()];

  @override
  void initState() {
    super.initState(); // Memanggil init bawaan Flutter
    _checkLogin(); // Mengecek status login saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengecek apakah user sudah login dan memiliki role 'warga'
  Future<void> _checkLogin() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses penyimpanan lokal
    final isLoggedIn =
        prefs.getBool('isLoggedIn') ??
        false; // Ambil status login, default false
    final role = prefs.getString('role'); // Ambil role user

    // Jika belum login atau bukan role 'warga', arahkan ke halaman login
    if (!isLoggedIn || role != 'warga') {
      if (mounted) {
        // Pastikan widget masih aktif di tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ), // Ganti halaman ke LoginPage
        );
      }
    }
  }

  // Fungsi untuk mengubah tab aktif saat bottom navigation ditekan
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update index tab aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold adalah struktur dasar halaman
      appBar: AppBar(
        // AppBar di atas halaman
        title: Text(_selectedIndex == 0 ? 'Halaman Warga' : 'Profil Saya'),
      ), // Judul berubah sesuai tab
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai tab aktif
      bottomNavigationBar: BottomNavigationBar(
        // Navigasi bawah untuk berpindah tab
        currentIndex: _selectedIndex, // Index tab aktif
        onTap: _onNavTapped, // Fungsi saat tab ditekan
        items: const [
          // Item tab navigasi
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Bagian halaman Beranda warga
class WargaHomeSection extends StatelessWidget {
  const WargaHomeSection({super.key}); // Konstruktor StatelessWidget

  @override
  Widget build(BuildContext context) {
    return ListView(
      // ListView untuk scroll konten secara vertikal
      padding: const EdgeInsets.all(16), // Padding di sekeliling konten
      children: const [
        // Daftar widget yang ditampilkan
        Text(
          'Selamat datang di aplikasi Iuran Warga 👋', // Teks sambutan
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ), // Gaya teks
        ),
        SizedBox(height: 16), // Spasi vertikal
        ListTile(
          // Item menu: Lihat Tagihan
          leading: Icon(Icons.receipt_long), // Ikon di kiri
          title: Text('Lihat Tagihan Iuran'), // Judul menu
          subtitle: Text('Cek iuran bulanan kamu'), // Deskripsi menu
        ),
        ListTile(
          // Item menu: Riwayat Pembayaran
          leading: Icon(Icons.history),
          title: Text('Riwayat Pembayaran'),
          subtitle: Text('Lihat daftar iuran yang sudah dibayar'),
        ),
        ListTile(
          // Item menu: Pengumuman
          leading: Icon(Icons.campaign),
          title: Text('Pengumuman'),
          subtitle: Text('Lihat informasi terbaru dari pengurus'),
        ),
      ],
    );
  }
}

// Bagian halaman Profil warga
class WargaProfileSection extends StatefulWidget {
  const WargaProfileSection({super.key}); // Konstruktor StatefulWidget

  @override
  State<WargaProfileSection> createState() => _WargaProfileSectionState(); // Membuat state
}

// State dari halaman profil
class _WargaProfileSectionState extends State<WargaProfileSection> {
  final emailCtrl = TextEditingController(); // Controller untuk input email
  final passCtrl = TextEditingController(); // Controller untuk input password
  bool _isEditing = false; // Status apakah sedang mode edit

  @override
  void initState() {
    super.initState(); // Panggil init bawaan
    _loadUserData(); // Load data user dari SharedPreferences
  }

  // Fungsi untuk mengambil data email dan password dari penyimpanan lokal
  Future<void> _loadUserData() async {
    final prefs =
        await SharedPreferences.getInstance(); // Akses penyimpanan lokal
    setState(() {
      emailCtrl.text =
          prefs.getString('email') ?? 'warga@mail.com'; // Isi email
      passCtrl.text = prefs.getString('password') ?? '******'; // Isi password
    });
  }

  // Fungsi untuk menyimpan perubahan email dan password ke penyimpanan lokal
  Future<void> _saveChanges() async {
    final prefs =
        await SharedPreferences.getInstance(); // Akses penyimpanan lokal
    await prefs.setString('email', emailCtrl.text); // Simpan email baru
    await prefs.setString('password', passCtrl.text); // Simpan password baru

    setState(() {
      _isEditing = false; // Keluar dari mode edit
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        // Tampilkan notifikasi berhasil
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  // Fungsi untuk logout dan hapus semua data dari penyimpanan lokal
  Future<void> _logout() async {
    final prefs =
        await SharedPreferences.getInstance(); // Akses penyimpanan lokal
    await prefs.clear(); // Hapus semua data

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        // Navigasi ke halaman login dan hapus semua halaman sebelumnya
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding di sekeliling konten
      padding: const EdgeInsets.all(24),
      child: ListView(
        // ListView untuk scroll konten
        children: [
          const SizedBox(height: 24), // Spasi vertikal
          Center(
            child: CircleAvatar(
              // Avatar profil dummy
              radius: 50,
              backgroundImage: AssetImage('assets/profile_dummy.png'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              // Menampilkan email user
              emailCtrl.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            // Input email
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            enabled: _isEditing, // Aktif hanya saat mode edit
          ),
          const SizedBox(height: 16),
          TextField(
            // Input password
            controller: passCtrl,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // Menyembunyikan teks (karakter password)
            enabled: _isEditing,
          ),
          const SizedBox(height: 24),

          // Tombol untuk menyimpan perubahan atau masuk ke mode edit
          if (_isEditing)
            ElevatedButton.icon(
              // Tombol simpan
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan'),
            )
          else
            ElevatedButton.icon(
              // Tombol edit
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil'),
            ),

          const SizedBox(height: 16),

          // 🔴 Tombol Logout di bawah profil
          OutlinedButton.icon(
            // Tombol dengan ikon dan border
            onPressed: _logout, // Ketika ditekan, jalankan fungsi logout
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ), // Ikon logout berwarna merah
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ), // Label teks berwarna merah
            style: OutlinedButton.styleFrom(
              // Gaya tombol dengan border merah
              side: const BorderSide(
                color: Colors.red,
              ), // Warna garis tepi merah
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ), // Padding vertikal agar tombol lebih tinggi
            ),
          ),
        ],
      ),
    );
  }
}
