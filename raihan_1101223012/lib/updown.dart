import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpDownPage extends StatefulWidget {
  @override
  _UpDownPageState createState() => _UpDownPageState();
}

class _UpDownPageState extends State<UpDownPage> {
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _filteredFiles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final String _bucketName = 'user_files';

  String _currentPath = '';
  List<String> _pathHistory = [];

  // Fungsi untuk membersihkan nama file dari karakter tidak valid (lebih agresif)
  String _sanitizeFileName(String fileName) {
    // Pisahkan nama file dan ekstensi
    final lastDot = fileName.lastIndexOf('.');
    String nameWithoutExt = fileName;
    String extension = '';

    if (lastDot != -1) {
      nameWithoutExt = fileName.substring(0, lastDot);
      extension = fileName.substring(lastDot);
    }

    // Hanya izinkan: huruf (a-z, A-Z), angka (0-9), underscore (_), dan titik (.)
    // Hapus semua karakter lain
    String cleanName = nameWithoutExt
        .replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '_',
        ) // Ganti semua non-alphanumeric dengan underscore
        .replaceAll(RegExp(r'_+'), '_') // Ganti multiple underscore dengan satu
        .replaceAll(RegExp(r'^_|_$'), ''); // Hapus underscore di awal/akhir

    // Batasi panjang maksimal nama file (misal 100 karakter)
    if (cleanName.length > 100) {
      cleanName = cleanName.substring(0, 100);
    }

    // Gabungkan dengan ekstensi
    String result = cleanName + extension;

    // Pastikan tidak kosong
    if (result.isEmpty || result == extension) {
      result = 'file_${DateTime.now().millisecondsSinceEpoch}$extension';
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    await _checkAndCreateBucket();
    await _loadFiles();
  }

  Future<void> _checkAndCreateBucket() async {
    try {
      final buckets = await Supabase.instance.client.storage.listBuckets();
      final bucketExists = buckets.any((b) => b.name == _bucketName);

      if (!bucketExists) {
        await Supabase.instance.client.storage.createBucket(_bucketName);
        print('Bucket $_bucketName created successfully');
      }
    } catch (e) {
      print('Error checking/creating bucket: $e');
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String path = _currentPath.isEmpty ? '' : _currentPath;
      final List<FileObject> files = await Supabase.instance.client.storage
          .from(_bucketName)
          .list(path: path);

      _files = files.map((file) {
        return {
          'name': file.name,
          'id': file.id,
          'size': file.metadata?['size'] ?? 0,
          'updated_at': file.updatedAt,
          'is_folder': file.name.endsWith('/'),
          'full_path': path.isEmpty ? file.name : '$path/${file.name}',
        };
      }).toList();

      _filteredFiles = List.from(_files);
    } catch (e) {
      _showSnackBar('Error loading files: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFiles = List.from(_files);
      } else {
        _filteredFiles = _files.where((file) {
          return file['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _uploadFile() async {
    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.multiple = false;
      uploadInput.accept = '*/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        html.File selectedFile = files[0];
        String originalFileName = selectedFile.name;
        String cleanFileName = _sanitizeFileName(originalFileName);

        if (originalFileName != cleanFileName) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Nama File Akan Diubah'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama asli: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(originalFileName, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text(
                    'Nama baru: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cleanFileName,
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Karakter tidak valid telah diganti dengan underscore (_)',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Lanjutkan'),
                ),
              ],
            ),
          );

          if (confirm != true) return;
        }

        String filePath = _currentPath.isEmpty
            ? cleanFileName
            : '$_currentPath/$cleanFileName';

        setState(() {
          _isLoading = true;
        });

        try {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(selectedFile);

          await reader.onLoadEnd.first;
          final bytes = reader.result as dynamic;

          await Supabase.instance.client.storage
              .from(_bucketName)
              .uploadBinary(filePath, bytes);

          _showSnackBar('File uploaded successfully!', Colors.green);
          await _loadFiles();
        } catch (e) {
          _showSnackBar('Upload failed: ${e.toString()}', Colors.red);
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _uploadMultipleFiles() async {
    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.multiple = true;
      uploadInput.accept = '*/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        setState(() {
          _isLoading = true;
        });

        int successCount = 0;

        for (var i = 0; i < files.length; i++) {
          try {
            html.File selectedFile = files[i];
            String originalFileName = selectedFile.name;
            String cleanFileName = _sanitizeFileName(originalFileName);
            String filePath = _currentPath.isEmpty
                ? cleanFileName
                : '$_currentPath/$cleanFileName';

            final reader = html.FileReader();
            reader.readAsArrayBuffer(selectedFile);
            await reader.onLoadEnd.first;
            final bytes = reader.result as dynamic;

            await Supabase.instance.client.storage
                .from(_bucketName)
                .uploadBinary(filePath, bytes);

            successCount++;
          } catch (e) {
            print('Error uploading file: $e');
          }
        }

        _showSnackBar(
          '$successCount/${files.length} files uploaded successfully!',
          Colors.green,
        );
        await _loadFiles();

        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _renameFile(Map<String, dynamic> fileItem) async {
    String oldName = fileItem['name'];
    String nameWithoutExt = oldName;
    String extension = '';

    final lastDot = oldName.lastIndexOf('.');
    if (lastDot != -1 && !fileItem['is_folder']) {
      nameWithoutExt = oldName.substring(0, lastDot);
      extension = oldName.substring(lastDot);
    }

    TextEditingController renameController = TextEditingController(
      text: nameWithoutExt,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Rename ${fileItem['is_folder'] ? 'Folder' : 'File'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: renameController,
              decoration: InputDecoration(
                labelText:
                    'New name${fileItem['is_folder'] ? '' : ' (without extension)'}',
                border: OutlineInputBorder(),
                helperText: fileItem['is_folder']
                    ? 'Spaces and special characters will be replaced with underscore'
                    : 'Extension .${extension.replaceFirst('.', '')} will be preserved',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Note: Spaces and special characters will be replaced with underscore',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String newName = renameController.text.trim();
              if (newName.isNotEmpty) {
                String finalName;
                if (fileItem['is_folder']) {
                  finalName = _sanitizeFileName(newName);
                } else {
                  finalName = _sanitizeFileName(newName + extension);
                }
                Navigator.pop(context, finalName);
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != fileItem['name']) {
      setState(() {
        _isLoading = true;
      });

      try {
        final oldPath = fileItem['full_path'];
        final newPath = _currentPath.isEmpty ? result : '$_currentPath/$result';

        await Supabase.instance.client.storage
            .from(_bucketName)
            .move(oldPath, newPath);

        _showSnackBar('Renamed successfully!', Colors.green);
        await _loadFiles();
      } catch (e) {
        _showSnackBar('Rename failed: $e', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> fileItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete ${fileItem['is_folder'] ? 'Folder' : 'File'}'),
        content: Text('Are you sure you want to delete "${fileItem['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.storage.from(_bucketName).remove([
          fileItem['full_path'],
        ]);

        _showSnackBar('Deleted successfully!', Colors.green);
        await _loadFiles();
      } catch (e) {
        _showSnackBar('Delete failed: $e', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _viewFile(Map<String, dynamic> fileItem) async {
    try {
      final isImage =
          fileItem['name'].toLowerCase().endsWith('.jpg') ||
          fileItem['name'].toLowerCase().endsWith('.jpeg') ||
          fileItem['name'].toLowerCase().endsWith('.png') ||
          fileItem['name'].toLowerCase().endsWith('.gif') ||
          fileItem['name'].toLowerCase().endsWith('.webp') ||
          fileItem['name'].toLowerCase().endsWith('.bmp');

      if (isImage) {
        // Tampilkan loading terlebih dahulu
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        try {
          // Dapatkan URL
          String imageUrl;
          try {
            // Coba dengan signed URL
            imageUrl = await Supabase.instance.client.storage
                .from(_bucketName)
                .createSignedUrl(fileItem['full_path'], 3600); // 1 jam expired
          } catch (e) {
            // Fallback ke public URL
            imageUrl = Supabase.instance.client.storage
                .from(_bucketName)
                .getPublicUrl(fileItem['full_path']);
          }

          debugPrint('Image URL: $imageUrl'); // Cek URL di console

          // Tutup loading
          Navigator.pop(context);

          // Tampilkan dialog dengan gambar
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(fileItem['name']),
                    backgroundColor: Colors.indigo,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 50, color: Colors.red),
                              SizedBox(height: 10),
                              Text('Gambar tidak dapat ditampilkan'),
                              Text('Pastikan bucket sudah public'),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          Navigator.pop(context); // Tutup loading
          _showSnackBar('Error: ${e.toString()}', Colors.red);
        }
      } else {
        // Untuk non-gambar, buka di tab baru
        String url;
        try {
          url = await Supabase.instance.client.storage
              .from(_bucketName)
              .createSignedUrl(fileItem['full_path'], 60);
        } catch (e) {
          url = Supabase.instance.client.storage
              .from(_bucketName)
              .getPublicUrl(fileItem['full_path']);
        }
        html.window.open(url, '_blank');
      }
    } catch (e) {
      _showSnackBar('Cannot view file: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> fileItem) async {
    try {
      final String publicUrl = Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl(fileItem['full_path']);

      html.window.open(publicUrl, '_blank');
      _showSnackBar('Download started in new tab', Colors.green);
    } catch (e) {
      _showSnackBar('Download failed: $e', Colors.red);
    }
  }

  void _openFolder(Map<String, dynamic> folder) {
    setState(() {
      _pathHistory.add(_currentPath);
      _currentPath = _currentPath.isEmpty
          ? folder['name'].replaceAll('/', '')
          : '$_currentPath/${folder['name'].replaceAll('/', '')}';
      _loadFiles();
    });
  }

  void _goBack() {
    if (_pathHistory.isNotEmpty) {
      setState(() {
        _currentPath = _pathHistory.removeLast();
        _loadFiles();
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

  String _formatSize(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    final sizes = ['B', 'KB', 'MB', 'GB'];
    int i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(1)} ${sizes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Manager'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadFile,
            tooltip: 'Upload File',
          ),
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: _uploadMultipleFiles,
            tooltip: 'Upload Multiple',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentPath.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: _goBack),
                  Expanded(
                    child: Text(
                      'Current: /$_currentPath',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search files or folders...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchFiles('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchFiles,
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No files found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + button to upload files',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFiles.length,
                    itemBuilder: (context, index) {
                      final fileItem = _filteredFiles[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            fileItem['is_folder']
                                ? Icons.folder
                                : Icons.insert_drive_file,
                            color: fileItem['is_folder']
                                ? Colors.amber
                                : Colors.indigo,
                            size: 32,
                          ),
                          title: Text(
                            fileItem['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: fileItem['is_folder']
                              ? Text('Folder')
                              : Text(_formatSize(fileItem['size'])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20),
                                onPressed: () => _renameFile(fileItem),
                                tooltip: 'Rename',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteFile(fileItem),
                                tooltip: 'Delete',
                              ),
                              if (!fileItem['is_folder'])
                                IconButton(
                                  icon: Icon(Icons.visibility, size: 20),
                                  onPressed: () => _viewFile(fileItem),
                                  tooltip: 'View',
                                ),
                              IconButton(
                                icon: Icon(Icons.download, size: 20),
                                onPressed: () => _downloadFile(fileItem),
                                tooltip: 'Download',
                              ),
                            ],
                          ),
                          onTap: fileItem['is_folder']
                              ? () => _openFolder(fileItem)
                              : () => _viewFile(fileItem),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        tooltip: 'Upload File',
      ),
    );
  }
}
