import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  List<Map<String, dynamic>> _mahasiswa = [];
  List<Map<String, dynamic>> _filteredMahasiswa = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableHobbies = [
    'Vokalis',
    'Pemain Alat Musik',
    'Menggambar',
    'Membuat Konten Video',
    'Travelling',
    'Bercocok tanam',
    'Olahraga',
  ];

  // Fungsi format tanggal manual
  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('data_mahasiswa')
          .select()
          .order('nama');

      _mahasiswa = List<Map<String, dynamic>>.from(response);
      _filteredMahasiswa = List.from(_mahasiswa);
    } catch (e) {
      _showSnackBar('Error loading data: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMahasiswa = List.from(_mahasiswa);
      } else {
        _filteredMahasiswa = _mahasiswa.where((item) {
          return item['nama'].toLowerCase().contains(query.toLowerCase()) ||
              item['nim'].toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _addMahasiswa() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MahasiswaFormPage(availableHobbies: _availableHobbies),
      ),
    );

    if (result == true) {
      _loadData();
      _showSnackBar('Data berhasil ditambahkan', Colors.green);
    }
  }

  Future<void> _editMahasiswa(Map<String, dynamic> mahasiswa) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MahasiswaFormPage(
          mahasiswa: mahasiswa,
          availableHobbies: _availableHobbies,
        ),
      ),
    );

    if (result == true) {
      _loadData();
      _showSnackBar('Data berhasil diupdate', Colors.green);
    }
  }

  Future<void> _deleteMahasiswa(Map<String, dynamic> mahasiswa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${mahasiswa['nama']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client
            .from('data_mahasiswa')
            .delete()
            .eq('id', mahasiswa['id']);

        _loadData();
        _showSnackBar('Data berhasil dihapus', Colors.green);
      } catch (e) {
        _showSnackBar('Error: $e', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewDetail(Map<String, dynamic> mahasiswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama', mahasiswa['nama']),
            _buildDetailRow('NIM', mahasiswa['nim'].toString()),
            _buildDetailRow(
              'Jenis Kelamin',
              mahasiswa['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            _buildDetailRow('Tempat Lahir', mahasiswa['tempat_lahir']),
            _buildDetailRow(
              'Tanggal Lahir',
              _formatDate(DateTime.parse(mahasiswa['tgl_lahir'])),
            ),
            _buildDetailRow('Hobby', (mahasiswa['hobbies'] as List).join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau NIM...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchData('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchData,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMahasiswa.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada data',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + untuk menambah data',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMahasiswa.length,
                    itemBuilder: (context, index) {
                      final mahasiswa = _filteredMahasiswa[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Text(
                              mahasiswa['nama'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            mahasiswa['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('NIM: ${mahasiswa['nim']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _viewDetail(mahasiswa),
                                tooltip: 'Detail',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _editMahasiswa(mahasiswa),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteMahasiswa(mahasiswa),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMahasiswa,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Data',
      ),
    );
  }
}

// ================= FORM TAMBAH/EDIT MAHASISWA =================
class MahasiswaFormPage extends StatefulWidget {
  final Map<String, dynamic>? mahasiswa;
  final List<String> availableHobbies;

  const MahasiswaFormPage({
    super.key,
    this.mahasiswa,
    required this.availableHobbies,
  });

  @override
  State<MahasiswaFormPage> createState() => _MahasiswaFormPageState();
}

class _MahasiswaFormPageState extends State<MahasiswaFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _nimController;
  late String _jenisKelamin;
  late TextEditingController _tempatLahirController;
  late DateTime _tglLahir;
  late List<String> _selectedHobbies;
  late List<String> _customHobbies;
  final TextEditingController _newHobbyController = TextEditingController();

  bool _isLoading = false;

  // Fungsi format tanggal manual
  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: widget.mahasiswa?['nama'] ?? '',
    );
    _nimController = TextEditingController(
      text: widget.mahasiswa?['nim']?.toString() ?? '',
    );
    _jenisKelamin = widget.mahasiswa?['jenis_kelamin'] ?? 'L';
    _tempatLahirController = TextEditingController(
      text: widget.mahasiswa?['tempat_lahir'] ?? '',
    );
    _tglLahir = widget.mahasiswa?['tgl_lahir'] != null
        ? DateTime.parse(widget.mahasiswa?['tgl_lahir'])
        : DateTime.now();
    _selectedHobbies = widget.mahasiswa?['hobbies'] != null
        ? List<String>.from(widget.mahasiswa?['hobbies'])
        : [];
    _customHobbies = List.from(widget.availableHobbies);
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nama': _namaController.text.trim(),
        'nim': int.parse(_nimController.text.trim()),
        'jenis_kelamin': _jenisKelamin,
        'tempat_lahir': _tempatLahirController.text.trim(),
        'tgl_lahir': _tglLahir.toIso8601String().split('T')[0],
        'hobbies': _selectedHobbies,
      };

      if (widget.mahasiswa == null) {
        await Supabase.instance.client.from('data_mahasiswa').insert(data);
      } else {
        await Supabase.instance.client
            .from('data_mahasiswa')
            .update(data)
            .eq('id', widget.mahasiswa!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCustomHobby() {
    if (_newHobbyController.text.isNotEmpty) {
      setState(() {
        _customHobbies.add(_newHobbyController.text);
        _selectedHobbies.add(_newHobbyController.text);
        _newHobbyController.clear();
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tglLahir) {
      setState(() {
        _tglLahir = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIM harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'NIM harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Jenis Kelamin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Laki-laki'),
                      value: 'L',
                      groupValue: _jenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Perempuan'),
                      value: 'P',
                      groupValue: _jenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tempatLahirController,
                decoration: const InputDecoration(
                  labelText: 'Tempat Lahir',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tempat lahir harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formatDate(_tglLahir),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Hobby (pilih salah satu atau lebih)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: _customHobbies.map((hobby) {
                  final isSelected = _selectedHobbies.contains(hobby);
                  return FilterChip(
                    label: Text(hobby),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedHobbies.add(hobby);
                        } else {
                          _selectedHobbies.remove(hobby);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.indigo[100],
                    checkmarkColor: Colors.indigo,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newHobbyController,
                      decoration: const InputDecoration(
                        hintText: 'Tambah hobby baru',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCustomHobby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              if (_selectedHobbies.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: _selectedHobbies.map((hobby) {
                    return Chip(
                      label: Text(hobby),
                      backgroundColor: Colors.indigo[100],
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedHobbies.remove(hobby);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveData,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Simpan',
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
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _tempatLahirController.dispose();
    _newHobbyController.dispose();
    super.dispose();
  }
}
