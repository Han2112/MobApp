import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  // Daftar URL gambar sampel (bisa diganti dengan asset lokal atau URL dari API/database)
  final List<String> imageUrls = [
    'https://picsum.photos/id/10/500/500',
    'https://picsum.photos/id/11/500/500',
    'https://picsum.photos/id/12/500/500',
    'https://picsum.photos/id/13/500/500',
    'https://picsum.photos/id/14/500/500',
    'https://picsum.photos/id/15/500/500',
    'https://picsum.photos/id/16/500/500',
    'https://picsum.photos/id/17/500/500',
    'https://picsum.photos/id/18/500/500',
    'https://picsum.photos/id/19/500/500',
  ];

  ImageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Foto'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Jumlah kolom
            crossAxisSpacing: 8.0, // Jarak antar kolom
            mainAxisSpacing: 8.0, // Jarak antar baris
            childAspectRatio: 1.0, // Rasio aspek gambar (1:1 agar kotak)
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigasi ke halaman detail saat gambar diklik
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImage(imageUrl: imageUrls[index]),
                  ),
                );
              },
              child: Hero(
                tag: imageUrls[index], // Animasi transisi mulus
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Halaman untuk menampilkan gambar ukuran penuh (Full Screen)
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Memungkinkan geser gambar saat di-zoom
          minScale: 0.5,
          maxScale: 4.0, // Batas maksimal zoom
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
