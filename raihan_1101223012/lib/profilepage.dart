import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String username; // Menambahkan variabel penerima username

  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Menggunakan DefaultTabController untuk membuat sistem Tab
    return DefaultTabController(
      length: 2, // Jumlah tab yang tersedia
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(icon: Icon(Icons.person), text: 'Profile (Tab 1)')],
          ),
        ),
        body: TabBarView(
          children: [
            // Isi dari Tab 1: Halaman Profil
            _buildProfileTab(),
            // Isi dari Tab 2: Halaman Placeholder lainnya
            const Center(
              child: Text(
                'Halaman Tab 2\n(Belum ada konten)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget khusus untuk merender isi Tab 1
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Circle Avatar (Your Picture)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 3),
            ),
            child: const CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                "https://raihansetiawanportolio.vercel.app/assets/profile-DWKda1II.png",
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Your Name
          const Text(
            'Raihan Ramadhan Setiawan',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // 3. Username
          Text(
            '@$username', // Memanggil variabel username yang dikirim dari form login
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),

          // 4. NIM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NIM: 1101223012', // Ganti dengan NIM Anda
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Hobby
          const Card(
            elevation: 0,
            color: Color(0xFFF5F5F5),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Hobby',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ngoding (Flutter & Laravel), Eksperimen IoT (ESP32)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 6. Favorite Pics in Circle Avatar
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Favorite Pics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Deretan gambar favorit dalam bentuk lingkaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/id/28/200/200',
                ),
              ),
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/id/36/200/200',
                ),
              ),
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/id/43/200/200',
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
