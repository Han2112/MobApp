import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:raihan_1101223012/crud.dart';
import 'package:raihan_1101223012/imagegallery.dart';
import 'package:raihan_1101223012/kalkulator.dart';
import 'package:raihan_1101223012/loginpage.dart';
//import 'package:raihan_1101223012/maps_page.dart';
import 'package:raihan_1101223012/updown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  final List<Widget> pages = [
    _buildHomeContent(),
    MyWidget(),
    ImageGallery(),
    UpDownPage(),
    CrudPage(),
    ProfilePage(),
  ];

  static Widget _buildHomeContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'Welcome to Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Select menu from bottom navigation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserProfile();
  }

  void _getCurrentUser() {
    setState(() {
      _currentUser = Supabase.instance.client.auth.currentUser;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _userProfile = response;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          content: Text("Are you sure you want to logout from your account?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Logging out..."),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);

        if (mounted) {
          // Gunakan rootNavigator untuk memastikan dialog loading tertutup dengan aman
          Navigator.of(context, rootNavigator: true).pop();

          // Hapus semua stack dan kembali ke login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.indigo,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userProfile?['full_name'] ??
                        _currentUser?.email?.split('@').first ??
                        'User Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser?.email ?? 'user@email.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              tileColor: currentIndex == 0 ? Colors.indigo[50] : null,
              onTap: () {
                setState(() {
                  currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Kalkulator'),
              tileColor: currentIndex == 1 ? Colors.indigo[50] : null,
              onTap: () {
                setState(() {
                  currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              tileColor: currentIndex == 2 ? Colors.indigo[50] : null,
              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              tileColor: currentIndex == 3 ? Colors.indigo[50] : null,
              onTap: () {
                setState(() {
                  currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Kalkulator",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Gallery"),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: "Storage"),
          BottomNavigationBarItem(icon: Icon(Icons.data_array), label: "CRUD"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Maps"),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ================= PAGE PROFIL =================
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _currentUser = Supabase.instance.client.auth.currentUser;

      if (_currentUser != null) {
        final response = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('user_id', _currentUser!.id)
            .maybeSingle();

        if (response != null && mounted) {
          setState(() {
            _userProfile = response;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // FUNGSI BARU: Mendaftarkan sidik jari
  void _registerFingerprint() {
    final TextEditingController _dialogPasswordController =
        TextEditingController();
    bool _obscureText = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Daftarkan Sidik Jari'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masukkan password Anda saat ini untuk mengaktifkan fitur login dengan sidik jari di perangkat ini.',
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _dialogPasswordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_dialogPasswordController.text.isNotEmpty) {
                    final secureStorage = const FlutterSecureStorage();
                    // Simpan email dan password ke secure storage
                    await secureStorage.write(
                      key: 'saved_email',
                      value: _currentUser?.email ?? '',
                    );
                    await secureStorage.write(
                      key: 'saved_password',
                      value: _dialogPasswordController.text,
                    );

                    Navigator.pop(context); // Tutup dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sidik Jari berhasil didaftarkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Header Profile
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.indigo),
                  ),
                  SizedBox(height: 15),
                  Text(
                    _userProfile?['full_name'] ??
                        _currentUser?.email?.split('@').first ??
                        'User Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _currentUser?.email ?? 'user@email.com',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (_userProfile?['username'] != null) ...[
                    SizedBox(height: 5),
                    Text(
                      '@${_userProfile?['username']}',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Menu Options
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Column(
              children: [
                // MENU BARU: Sidik Jari
                ListTile(
                  leading: Icon(Icons.fingerprint, color: Colors.indigo),
                  title: Text('Daftarkan Sidik Jari'),
                  subtitle: Text('Aktifkan login cepat dengan sidik jari'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _registerFingerprint,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_reset, color: Colors.indigo),
                  title: Text('Ubah Password'),
                  subtitle: Text('Ganti password akun Anda'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordPage(),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.indigo),
                  title: Text('Edit Profile'),
                  subtitle: Text('Ubah nama atau username'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur akan segera hadir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.indigo),
                  title: Text('Informasi Akun'),
                  subtitle: Text('Detail akun dan keamanan'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showAccountInfo();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Statistik Akun
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow('ID Akun', _currentUser?.id ?? '-'),
                  _buildInfoRow('Email', _currentUser?.email ?? '-'),
                  _buildInfoRow(
                    'Terdaftar',
                    _currentUser?.createdAt.toString().split(' ')[0] ?? '-',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  void _showAccountInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informasi Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: ${_currentUser?.email}'),
            SizedBox(height: 5),
            Text('🆔 User ID: ${_currentUser?.id}'),
            SizedBox(height: 5),
            Text(
              '📅 Bergabung: ${_currentUser?.createdAt.toString().split(' ')[0]}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// Class ChangePasswordPage dan VerifyOtpPage tetap sama persis seperti sebelumnya...
// (Anda dapat memasukkan kode asli dari ChangePasswordPage dan VerifyOtpPage milik Anda di sini tanpa perubahan)
// ================= PAGE UBAH PASSWORD =================
class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _sendResetEmail() async {
    // Validasi password
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a new password', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('User not found', Colors.red);
        return;
      }

      // Kirim email reset password dengan OTP
      await Supabase.instance.client.auth.resetPasswordForEmail(
        currentUser.email!,
      );

      _showSnackBar(
        'OTP has been sent to your email! Please check your inbox.',
        Colors.green,
      );

      // Navigasi ke halaman verifikasi OTP
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpPage(
              email: currentUser.email!,
              newPassword: _passwordController.text,
            ),
          ),
        );
      });
    } catch (e) {
      String errorMessage = 'Failed to send OTP';
      if (e.toString().contains('rate limit')) {
        errorMessage = 'Too many requests. Please try again later';
      }
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubah Password"),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_reset, size: 60, color: Colors.indigo),
                    SizedBox(height: 20),
                    Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Masukkan password baru Anda. OTP akan dikirim ke email Anda.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),

                    // Field Password Baru
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        labelText: "Password Baru",
                        hintText: "Minimal 6 karakter",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Field Konfirmasi Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.indigo,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        labelText: "Konfirmasi Password",
                        hintText: "Masukkan ulang password baru",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Tombol Kirim OTP
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _sendResetEmail,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "Kirim OTP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= PAGE VERIFIKASI OTP =================
class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String newPassword;

  const VerifyOtpPage({
    Key? key,
    required this.email,
    required this.newPassword,
  }) : super(key: key);

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtpAndUpdatePassword() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter the OTP from your email', Colors.red);
      return;
    }

    if (_otpController.text.length < 6) {
      _showSnackBar('OTP must be 6 digits', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Langkah 1: Verifikasi OTP dengan verifyOtp
      final verifyResponse = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        email: widget.email,
        token: _otpController.text.trim(),
      );

      if (verifyResponse.user != null) {
        // Langkah 2: OTP valid, update password
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: widget.newPassword),
        );

        // Langkah 3: Logout setelah update password
        await Supabase.instance.client.auth.signOut();

        _showSnackBar(
          'Password successfully changed! Please login with your new password.',
          Colors.green,
        );

        // Kembali ke halaman login setelah 2 detik
        Future.delayed(Duration(seconds: 2), () {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        _showSnackBar('Invalid OTP. Please try again.', Colors.red);
      }
    } catch (e) {
      String errorMessage = 'Failed to verify OTP';
      if (e.toString().contains('Invalid OTP')) {
        errorMessage = 'Invalid or expired OTP. Please request a new one.';
      }
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(widget.email);

      _showSnackBar('New OTP has been sent to your email', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to resend OTP. Please try again.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verifikasi OTP"),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.verified, size: 60, color: Colors.indigo),
                    SizedBox(height: 20),
                    Text(
                      'Verifikasi OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Kode OTP telah dikirim ke:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Masukkan kode OTP 6 digit untuk melanjutkan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // Field OTP
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, letterSpacing: 8),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.pin, color: Colors.indigo),
                        counterText: '',
                        labelText: "Kode OTP",
                        hintText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tombol Verifikasi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading
                            ? null
                            : _verifyOtpAndUpdatePassword,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "Verifikasi & Ubah Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Tombol Kirim Ulang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tidak menerima kode? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _resendOtp,
                          child: Text(
                            'Kirim Ulang',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
