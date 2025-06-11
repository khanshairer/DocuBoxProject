import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/user_selector_modal.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _expiryController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isDownloadable = true;
  bool _isScreenshotAllowed = true;
  bool _isPubliclyShared = false;
  List<String> _sharedWith = [];

  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _expiryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFileName = result.files.single.name;

          if (kIsWeb) {
            _selectedFileBytes = result.files.single.bytes;
            _selectedFile = null;
          } else {
            if (result.files.single.path != null) {
              _selectedFile = File(result.files.single.path!);
              _selectedFileBytes = null;
            }
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: ${e.toString()}');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _expiryController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _expiryController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedFile == null && _selectedFileBytes == null)) {
      _showErrorSnackBar('Please fill all fields and select a file.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('No authenticated user found. Please log in.');
        return;
      }

      DateTime parsedExpiryDate;
      try {
        final parts = _expiryController.text.trim().split('/');
        parsedExpiryDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        _showErrorSnackBar(
          'Invalid expiry date format. Please use DD/MM/YYYY.',
        );
        return;
      }

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '${timestamp}_$_selectedFileName';

      // Upload file to Firebase Storage
      late dynamic storageRef;
      storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');

      String safeFileName = _selectedFileName ?? 'unknown_file';
      String storageFileName = '${user.uid}_${timestamp}_$safeFileName';

      storageRef = FirebaseStorage.instance.ref().child(
        'user_documents/${user.uid}/$storageFileName',
      );

      parsedExpiryDate;
      try {
        final parts = _expiryController.text.trim().split('/');
        parsedExpiryDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        _showErrorSnackBar(
          'Invalid expiry date format. Please use DD/MM/YYYY.',
        );
        return;
      }

      timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      safeFileName = _selectedFileName ?? 'unknown_file';
      storageFileName = '${user.uid}_${timestamp}_$safeFileName';

      storageRef = FirebaseStorage.instance.ref().child(
        'user_documents/${user.uid}/$storageFileName',
      );

      UploadTask uploadTask;

      if (kIsWeb && _selectedFileBytes != null) {
        uploadTask = storageRef.putData(_selectedFileBytes!);
      } else if (_selectedFile != null) {
        uploadTask = storageRef.putFile(_selectedFile!);
      } else {
        throw Exception('No file data available for upload.');
      }

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      List<String> tagsList =
          _tagsController.text
              .trim()
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();

      tagsList =
          _tagsController.text
              .trim()
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();

      await FirebaseFirestore.instance.collection('documents').add({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'expiry': Timestamp.fromDate(parsedExpiryDate),
        'fileName': _selectedFileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'tags': tagsList,
        'isDownloadable': _isDownloadable,
        'isScreenshotAllowed': _isScreenshotAllowed,
        'isPubliclyShared': _isPubliclyShared,
        'shareId': null,
        'sharedWith': _sharedWith,
      });

      _showSuccessSnackBar('Document uploaded successfully!');
      _clearForm();
    } catch (e) {
      _showErrorSnackBar('Upload failed: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _expiryController.clear();
    _tagsController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileBytes = null;
      _selectedFileName = null;
      _isDownloadable = true;
      _isScreenshotAllowed = true;
      _isPubliclyShared = false;
      _sharedWith = [];
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document Information',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a name.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _typeController,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                  hintText:
                                      'e.g., Passport, License, Certificate',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter document type.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _expiryController,
                                decoration: const InputDecoration(
                                  labelText: 'Expiry Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  hintText: 'DD/MM/YYYY',
                                ),
                                readOnly: true,
                                onTap: _selectDate,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please select an expiry date.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _tagsController,
                                decoration: const InputDecoration(
                                  labelText: 'Tags (comma-separated)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.tag),
                                  hintText: 'e.g., important, finance, travel',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sharing & Security Options',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),

                              SwitchListTile(
                                title: const Text('Allow Download'),
                                subtitle: const Text(
                                  'Permit others to download this document',
                                ),
                                value: _isDownloadable,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isDownloadable = value;
                                  });
                                },
                                secondary: const Icon(Icons.download),
                              ),
                              const Divider(),

                              SwitchListTile(
                                title: const Text('Allow Screenshots'),
                                subtitle: const Text(
                                  'Allow screenshots/screen recording of this document',
                                ),
                                value: _isScreenshotAllowed,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isScreenshotAllowed = value;
                                  });
                                },
                                secondary: const Icon(Icons.screenshot),
                              ),
                              const Divider(),

                              SwitchListTile(
                                title: const Text(
                                  'Share Publicly (Experimental)',
                                ),
                                subtitle: const Text(
                                  'Make this document accessible via a unique link',
                                ),
                                value: _isPubliclyShared,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isPubliclyShared = value;
                                  });
                                },
                                secondary: const Icon(Icons.public),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                              const Divider(),

                              ListTile(
                                leading: const Icon(Icons.people),
                                title: const Text('Share with Users'),
                                subtitle: Text(
                                  _sharedWith.isEmpty
                                      ? 'No users selected'
                                      : '${_sharedWith.length} user${_sharedWith.length == 1 ? '' : 's'} selected',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => UserSelectorModal(
                                          initialSelectedUserIds: _sharedWith,
                                          onSelectionChanged: (
                                            selectedUserIds,
                                          ) {
                                            setState(() {
                                              _sharedWith = selectedUserIds;
                                            });
                                          },
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sharing & Security Options',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),

                              SwitchListTile(
                                title: const Text('Allow Download'),
                                subtitle: const Text(
                                  'Permit others to download this document',
                                ),
                                value: _isDownloadable,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isDownloadable = value;
                                  });
                                },
                                secondary: const Icon(Icons.download),
                              ),
                              const Divider(),

                              SwitchListTile(
                                title: const Text('Allow Screenshots'),
                                subtitle: const Text(
                                  'Allow screenshots/screen recording of this document',
                                ),
                                value: _isScreenshotAllowed,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isScreenshotAllowed = value;
                                  });
                                },
                                secondary: const Icon(Icons.screenshot),
                              ),
                              const Divider(),

                              SwitchListTile(
                                title: const Text(
                                  'Share Publicly (Experimental)',
                                ),
                                subtitle: const Text(
                                  'Make this document accessible via a unique link',
                                ),
                                value: _isPubliclyShared,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isPubliclyShared = value;
                                  });
                                },
                                secondary: const Icon(Icons.public),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Document File',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isUploading ? null : _pickFile,
                                  icon: const Icon(Icons.file_upload),
                                  label: Text(
                                    _selectedFileName ?? 'Choose File',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    side: BorderSide(
                                      color:
                                          (_selectedFile != null ||
                                                  _selectedFileBytes != null)
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),

                              if (_selectedFile != null ||
                                  _selectedFileBytes != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'File selected: $_selectedFileName',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),
                              Text(
                                'Supported formats: PDF, DOC, DOCX, TXT, JPG, PNG',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_isUploading) ...[
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Uploading... ${(_uploadProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadDocument,
                icon:
                    _isUploading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.cloud_upload),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload Document',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
