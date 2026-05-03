import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  final String initialDisplay; // Menampung password yang dikirim

  // Default value "0" jika tidak ada data yang dikirim
  const MyWidget({super.key, this.initialDisplay = "0"});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Variable untuk menyimpan input dan hasil
  late String _output;
  late String _currentInput;
  String _operator = "";
  double _firstNumber = 0;
  double _secondNumber = 0;
  late bool _isNewOperation;

  @override
  void initState() {
    super.initState();
    // Mengatur nilai awal kalkulator menggunakan parameter yang diterima
    _output = widget.initialDisplay;
    _currentInput = widget.initialDisplay == "0" ? "" : widget.initialDisplay;
    _isNewOperation = widget.initialDisplay == "0" ? true : false;
  }

  // Fungsi untuk menangani input angka
  void _handleNumber(String number) {
    setState(() {
      if (_isNewOperation) {
        _currentInput = number;
        _isNewOperation = false;
      } else {
        _currentInput += number;
      }
      _output = _currentInput;
    });
  }

  // Fungsi untuk menangani operator
  void _handleOperator(String operator) {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _firstNumber = double.parse(_currentInput);
        _operator = operator;
        _currentInput = "";
        _isNewOperation = false;
      }
    });
  }

  // Fungsi untuk menghitung hasil
  void _calculate() {
    if (_currentInput.isNotEmpty && _operator.isNotEmpty) {
      setState(() {
        _secondNumber = double.parse(_currentInput);

        switch (_operator) {
          case "+":
            _output = (_firstNumber + _secondNumber).toString();
            break;
          case "-":
            _output = (_firstNumber - _secondNumber).toString();
            break;
          case "×":
            _output = (_firstNumber * _secondNumber).toString();
            break;
          case "÷":
            if (_secondNumber != 0) {
              _output = (_firstNumber / _secondNumber).toString();
            } else {
              _output = "Error";
            }
            break;
        }

        // Hapus desimal jika angka bulat
        if (_output.endsWith(".0")) {
          _output = _output.substring(0, _output.length - 2);
        }

        _currentInput = _output;
        _operator = "";
        _isNewOperation = true;
      });
    }
  }

  // Fungsi untuk membersihkan semua
  void _clear() {
    setState(() {
      _output = "0";
      _currentInput = "";
      _operator = "";
      _firstNumber = 0;
      _secondNumber = 0;
      _isNewOperation = true;
    });
  }

  // Fungsi untuk menghapus satu karakter
  void _delete() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _output = _currentInput.isEmpty ? "0" : _currentInput;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kalkulator Sederhana',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Kembali ke halaman utama (mainnew.dart)
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display hasil
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              color: Colors.grey[900],
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Tombol-tombol kalkulator
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.grey[800],
              child: Column(
                children: [
                  // Baris 1: Clear, Delete
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton("C", Colors.red, () => _clear()),
                        _buildButton("⌫", Colors.orange, () => _delete()),
                        _buildButton(
                          "÷",
                          Colors.green,
                          () => _handleOperator("÷"),
                        ),
                        _buildButton(
                          "×",
                          Colors.green,
                          () => _handleOperator("×"),
                        ),
                      ],
                    ),
                  ),

                  // Baris 2: 7,8,9,-
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          "7",
                          Colors.grey[700]!,
                          () => _handleNumber("7"),
                        ),
                        _buildButton(
                          "8",
                          Colors.grey[700]!,
                          () => _handleNumber("8"),
                        ),
                        _buildButton(
                          "9",
                          Colors.grey[700]!,
                          () => _handleNumber("9"),
                        ),
                        _buildButton(
                          "-",
                          Colors.green,
                          () => _handleOperator("-"),
                        ),
                      ],
                    ),
                  ),

                  // Baris 3: 4,5,6,+
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          "4",
                          Colors.grey[700]!,
                          () => _handleNumber("4"),
                        ),
                        _buildButton(
                          "5",
                          Colors.grey[700]!,
                          () => _handleNumber("5"),
                        ),
                        _buildButton(
                          "6",
                          Colors.grey[700]!,
                          () => _handleNumber("6"),
                        ),
                        _buildButton(
                          "+",
                          Colors.green,
                          () => _handleOperator("+"),
                        ),
                      ],
                    ),
                  ),

                  // Baris 4: 1,2,3,=
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          "1",
                          Colors.cyan[700]!,
                          () => _handleNumber("1"),
                        ),
                        _buildButton(
                          "2",
                          Colors.cyan[700]!,
                          () => _handleNumber("2"),
                        ),
                        _buildButton(
                          "3",
                          Colors.cyan[700]!,
                          () => _handleNumber("3"),
                        ),
                        _buildButton("=", Colors.blue, () => _calculate()),
                      ],
                    ),
                  ),

                  // Baris 5: 0, .
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton(
                          "0",
                          Colors.cyan[700]!,
                          () => _handleNumber("0"),
                          flex: 2,
                        ),
                        _buildButton(
                          ".",
                          Colors.grey[700]!,
                          () => _handleNumber("."),
                        ),
                        const Expanded(child: SizedBox()), // Spacer
                        const Expanded(child: SizedBox()), // Spacer
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol kembali ke halaman utama
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.greenAccent,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Kembali ke Halaman Utama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol kalkulator
  Widget _buildButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
