import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _picker = ImagePicker();

  String _sanitizeFileName(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    String nameWithoutExt = fileName;
    String extension = '';

    if (lastDot != -1) {
      nameWithoutExt = fileName.substring(0, lastDot);
      extension = fileName.substring(lastDot);
    }

    String cleanName = nameWithoutExt
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (cleanName.length > 100) {
      cleanName = cleanName.substring(0, 100);
    }

    String result = cleanName + extension;
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

  // Upload gambar dari galeri
  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      Uint8List fileBytes = await image.readAsBytes();
      String originalFileName = image.name;
      String cleanFileName = _sanitizeFileName(originalFileName);

      String filePath = _currentPath.isEmpty
          ? cleanFileName
          : '$_currentPath/$cleanFileName';

      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.storage
            .from(_bucketName)
            .uploadBinary(filePath, fileBytes);

        _showSnackBar('Image uploaded successfully!', Colors.green);
        await _loadFiles();
      } catch (e) {
        _showSnackBar('Upload failed: ${e.toString()}', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  // Upload gambar dari kamera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo == null) return;

      Uint8List fileBytes = await photo.readAsBytes();
      String originalFileName = photo.name;
      String cleanFileName = _sanitizeFileName(originalFileName);

      String filePath = _currentPath.isEmpty
          ? cleanFileName
          : '$_currentPath/$cleanFileName';

      setState(() {
        _isLoading = true;
      });

      try {
        await Supabase.instance.client.storage
            .from(_bucketName)
            .uploadBinary(filePath, fileBytes);

        _showSnackBar('Photo uploaded successfully!', Colors.green);
        await _loadFiles();
      } catch (e) {
        _showSnackBar('Upload failed: ${e.toString()}', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
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
              ),
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
          fileItem['name'].toLowerCase().endsWith('.webp');

      if (isImage) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        try {
          String imageUrl;
          try {
            imageUrl = await Supabase.instance.client.storage
                .from(_bucketName)
                .createSignedUrl(fileItem['full_path'], 3600);
          } catch (e) {
            imageUrl = Supabase.instance.client.storage
                .from(_bucketName)
                .getPublicUrl(fileItem['full_path']);
          }

          Navigator.pop(context);

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
                          child: Text('Gambar tidak dapat ditampilkan'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          _showSnackBar('Error: ${e.toString()}', Colors.red);
        }
      } else {
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

        _showSnackBar('File URL: $url', Colors.blue);
      }
    } catch (e) {
      _showSnackBar('Cannot view file: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> fileItem) async {
    try {
      final String url = Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl(fileItem['full_path']);

      _showSnackBar('Download URL: $url', Colors.blue);
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

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.indigo),
              title: Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _uploadImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.indigo),
              title: Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Manager'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: _showUploadOptions,
            tooltip: 'Upload',
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
                        Text('No files found'),
                        SizedBox(height: 8),
                        Text('Tap + button to upload files'),
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
        onPressed: _showUploadOptions,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        tooltip: 'Upload',
      ),
    );
  }
}