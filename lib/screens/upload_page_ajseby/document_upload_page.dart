import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Add this import

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({Key? key}) : super(key: key);

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _expiryController = TextEditingController();
  
  File? _selectedFile;
  Uint8List? _selectedFileBytes; // Add this for web support
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _expiryController.dispose();
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
            // For web, use bytes
            _selectedFileBytes = result.files.single.bytes;
            _selectedFile = null;
          } else {
            // For mobile/desktop, use file path
            if (result.files.single.path != null) {
              _selectedFile = File(result.files.single.path!);
              _selectedFileBytes = null;
            }
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: $e');
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
        _expiryController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }



  Future<void> _uploadDocument() async {
    print('🚀 Starting upload process...');
    
    if (!_formKey.currentState!.validate() || 
        (_selectedFile == null && _selectedFileBytes == null)) {
      _showErrorSnackBar('Please fill all fields and select a file');
      return;
    }

    print('✅ Form validation passed');
    print('📱 Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
    print('📄 File name: $_selectedFileName');
    
    if (kIsWeb) {
      print('💾 File bytes size: ${_selectedFileBytes?.length ?? 0} bytes');
    } else {
      print('📁 File path: ${_selectedFile?.path}');
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Create a unique filename
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '${timestamp}_$_selectedFileName';
      
      print('🔄 Generated filename: $fileName');
      
      // Upload file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');
      print('📚 Storage reference created: documents/$fileName');
      
      UploadTask uploadTask;
      
      if (kIsWeb && _selectedFileBytes != null) {
        print('🌐 Using putData for web upload');
        uploadTask = storageRef.putData(_selectedFileBytes!);
      } else if (_selectedFile != null) {
        print('📱 Using putFile for mobile upload');
        uploadTask = storageRef.putFile(_selectedFile!);
      } else {
        throw Exception('No file data available');
      }

      print('⏳ Upload task created, starting upload...');

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('📊 Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      print('🎯 Waiting for upload completion...');
      final TaskSnapshot taskSnapshot = await uploadTask;
      print('✅ Upload completed!');
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('🔗 Download URL obtained: $downloadUrl');

      // Save document metadata to Firestore
      print('💾 Saving to Firestore...');
      await FirebaseFirestore.instance.collection('documents').add({
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'expiry': _expiryController.text.trim(),
        'fileName': _selectedFileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      print('🎉 Document saved to Firestore successfully!');
      _showSuccessSnackBar('Document uploaded successfully!');
      _clearForm();
      
    } catch (e) {
      print('❌ Upload error: $e');
      print('📋 Error type: ${e.runtimeType}');
      _showErrorSnackBar('Upload failed: $e');
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
    setState(() {
      _selectedFile = null;
      _selectedFileBytes = null;
      _selectedFileName = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
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
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
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
                      // Document Information Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document Information',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Name Field
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Type Field
                              TextFormField(
                                controller: _typeController,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                  hintText: 'e.g., Passport, License, Certificate',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter document type';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Expiry Field
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
                                    return 'Please select expiry date';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // File Selection Card
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Document File',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // File Picker Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isUploading ? null : _pickFile,
                                  icon: const Icon(Icons.file_upload),
                                  label: Text(_selectedFileName ?? 'Choose File'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    side: BorderSide(
                                      color: (_selectedFile != null || _selectedFileBytes != null)
                                          ? Colors.green 
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              
                              if (_selectedFile != null || _selectedFileBytes != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, 
                                           color: Colors.green.shade600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'File selected: $_selectedFileName',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 12),
                              Text(
                                'Supported formats: PDF, DOC, DOCX, TXT, JPG, PNG',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Upload Progress
                      if (_isUploading) ...[
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Uploading... ${(_uploadProgress * 100).toInt()}%',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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
            
            // Upload Button at Bottom
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadDocument,
                icon: _isUploading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload Document',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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