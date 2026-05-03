import 'package:flutter/material.dart';
import 'package:raihan_1101223012/kalkulator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 124, 46, 101),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: Text("Raihan Setiawan", style: TextStyle(fontSize: 100)),
              ),
              Text("1101223012", style: TextStyle(fontSize: 60)),
              CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage("lib/images/profile.png"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 150,
                      backgroundImage: NetworkImage(
                        "https://raihansetiawanportolio.vercel.app/assets/profile-DWKda1II.png",
                      ),
                    ),
                    CircleAvatar(
                      radius: 150,
                      backgroundImage: NetworkImage(
                        "https://raihansetiawanportolio.vercel.app/assets/profile-DWKda1II.png",
                      ),
                    ),
                    CircleAvatar(
                      radius: 150,
                      backgroundImage: NetworkImage(
                        "https://raihansetiawanportolio.vercel.app/assets/profile-DWKda1II.png",
                      ),
                    ),
                    CircleAvatar(
                      radius: 150,
                      backgroundImage: NetworkImage(
                        "https://raihansetiawanportolio.vercel.app/assets/profile-DWKda1II.png",
                      ),
                    ),
                  ],
                ),
              ),
              KalkulatorButton(),

              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => MyWidget()),
              //     );
              //   },
              //   child: Text("Kalkulator"),
              // ),
              FlutterLogo(size: 150),
              FlutterLogo(size: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class KalkulatorButton extends StatelessWidget {
  const KalkulatorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyWidget()),
        );
      },
      child: Text("Kalkulator"),
    );
  }
}
