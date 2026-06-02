import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _screenIndex = 0;

  @override
  void initState() {
    super.initState();
    // Screen 1: 3 detik -> Screen 2: 3 detik -> Screen 3: 5 detik -> finish
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _screenIndex = 1);
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => _screenIndex = 2);
        Future.delayed(const Duration(seconds: 5), widget.onFinish);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _screenIndex == 0
          ? _buildFirstScreen(context)
          : _screenIndex == 1
          ? _buildSecondScreen(context)
          : _buildThirdScreen(context),
    );
  }

  Widget _buildFirstScreen(BuildContext context) {
    return Container(
      key: const ValueKey(0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.12),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Image.asset(
            'lib/images/profile.png',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondScreen(BuildContext context) {
    return Container(
      key: const ValueKey(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F4F8), Color.fromARGB(255, 101, 28, 1)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 63,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('lib/assets/foto4x6_ABU.jpg'),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Text(
                  'MOBILE APPLICATIONS PROJECT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                    shadows: [
                      Shadow(
                        color: Colors.black87.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'RAIHAN SETIAWAN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade600,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '1101223012',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                // Kalau ingin garis bawah, bisa tambah row Container di sini
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Screen 3: animasi GIF
  Widget _buildThirdScreen(BuildContext context) {
    return Container(
      key: const ValueKey(2),
      color: Colors.black,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurpleAccent, width: 6),
            ),
            child: Image.asset(
              'lib/images/becek.gif',
              width: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
