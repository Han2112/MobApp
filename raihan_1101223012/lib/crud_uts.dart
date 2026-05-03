import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrudUtsPage extends StatefulWidget {
  const CrudUtsPage({super.key});

  @override
  State<CrudUtsPage> createState() => _CrudUtsPageState();
}

class _CrudUtsPageState extends State<CrudUtsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Controller untuk Form
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _pertanyaanController = TextEditingController();
  final TextEditingController _pilihanAController = TextEditingController();
  final TextEditingController _pilihanBController = TextEditingController();
  final TextEditingController _pilihanCController = TextEditingController();
  final TextEditingController _pilihanDController = TextEditingController();
  final TextEditingController _jawabanController = TextEditingController();

  // 1. CREATE & UPDATE (Upsert)
  Future<void> _upsertSoal([int? id]) async {
    if (_nomorController.text.isEmpty || _pertanyaanController.text.isEmpty) {
      _showSnackBar("Harap isi Nomor dan Pertanyaan", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'nomor': int.parse(_nomorController.text),
        'pertanyaan': _pertanyaanController.text,
        'pilihan_a': _pilihanAController.text,
        'pilihan_b': _pilihanBController.text,
        'pilihan_c': _pilihanCController.text,
        'pilihan_d': _pilihanDController.text,
        'jawaban': _jawabanController.text.toUpperCase(),
      };

      if (id == null) {
        // Create
        await supabase.from('crud_uts').insert(data);
        _showSnackBar("Soal berhasil ditambahkan!", Colors.green);
      } else {
        // Update
        await supabase.from('crud_uts').update(data).eq('id', id);
        _showSnackBar("Soal berhasil diperbarui!", Colors.blue);
      }

      Navigator.pop(context);
      _clearForm();
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. DELETE
  Future<void> _deleteSoal(int id) async {
    try {
      await supabase.from('crud_uts').delete().eq('id', id);
      _showSnackBar("Soal berhasil dihapus", Colors.orange);
    } catch (e) {
      _showSnackBar("Gagal menghapus: $e", Colors.red);
    }
  }

  // Fungsi Helper
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _clearForm() {
    _nomorController.clear();
    _pertanyaanController.clear();
    _pilihanAController.clear();
    _pilihanBController.clear();
    _pilihanCController.clear();
    _pilihanDController.clear();
    _jawabanController.clear();
  }

  // PENAMBAHAN: Fungsi untuk menampilkan detail pilihan ganda
  void _showDetailDialog(Map<String, dynamic> soal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Detail Soal No. ${soal['nomor']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  soal['pertanyaan'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text("A. ${soal['pilihan_a']}"),
                const SizedBox(height: 5),
                Text("B. ${soal['pilihan_b']}"),
                const SizedBox(height: 5),
                Text("C. ${soal['pilihan_c']}"),
                const SizedBox(height: 5),
                Text("D. ${soal['pilihan_d']}"),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Jawaban Benar: ${soal['jawaban']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan Modal Input (Create/Edit)
  void _showFormModal([Map<String, dynamic>? item]) {
    if (item != null) {
      _nomorController.text = item['nomor'].toString();
      _pertanyaanController.text = item['pertanyaan'];
      _pilihanAController.text = item['pilihan_a'];
      _pilihanBController.text = item['pilihan_b'];
      _pilihanCController.text = item['pilihan_c'];
      _pilihanDController.text = item['pilihan_d'];
      _jawabanController.text = item['jawaban'];
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? "Tambah Soal Baru" : "Edit Soal",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nomorController,
                decoration: const InputDecoration(labelText: "Nomor"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _pertanyaanController,
                decoration: const InputDecoration(labelText: "Pertanyaan"),
              ),
              TextField(
                controller: _pilihanAController,
                decoration: const InputDecoration(labelText: "Pilihan A"),
              ),
              TextField(
                controller: _pilihanBController,
                decoration: const InputDecoration(labelText: "Pilihan B"),
              ),
              TextField(
                controller: _pilihanCController,
                decoration: const InputDecoration(labelText: "Pilihan C"),
              ),
              TextField(
                controller: _pilihanDController,
                decoration: const InputDecoration(labelText: "Pilihan D"),
              ),
              TextField(
                controller: _jawabanController,
                decoration: const InputDecoration(
                  labelText: "Jawaban (A/B/C/D)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                ),
                onPressed: () => _upsertSoal(item?['id']),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Data",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // 3. READ (Real-time Stream)
        stream: supabase
            .from('crud_uts')
            .stream(primaryKey: ['id'])
            .order('nomor'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final listSoal = snapshot.data!;

          if (listSoal.isEmpty) {
            return const Center(
              child: Text("Belum ada data. Klik + untuk menambah."),
            );
          }

          return ListView.builder(
            itemCount: listSoal.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final soal = listSoal[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  // PENAMBAHAN: Agar bisa diklik dan memunculkan pop-up detail pilihan ganda
                  onTap: () => _showDetailDialog(soal),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Text(
                      soal['nomor'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    soal['pertanyaan'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Jawaban: ${soal['jawaban']} (Ketuk untuk detail)",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormModal(soal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSoal(soal['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => _showFormModal(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
