import 'package:flutter/material.dart';
import 'package:raihan_1101223012/dashboardpage.dart';
import 'package:raihan_1101223012/loginpage.dart';
import 'package:raihan_1101223012/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'splash_screen.dart'; // Import splash screen

// import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize date formatting untuk bahasa Indonesia (wajib untuk intl ^0.18.1)
  // await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      // Tampilkan splash screen dulu, lalu setelah selesai tampilkan halaman auth
      home: _showSplash
          ? SplashScreen(
              onFinish: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : StreamBuilder<AuthState>(
              stream: Supabase.instance.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                final user = snapshot.data?.session?.user;
                if (user != null) {
                  return DashboardPage();
                }
                return LoginPage();
              },
            ),
    );
  }
}
