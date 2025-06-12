import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_image_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/homepage_menu_bar_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _showPasswordFields = false;
  bool _isLoading = false;
  File? _profileImage;
  String? _currentImageUrl;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  User? _currentUser;
  String? _memberSince;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  /// Loads user data (username, email, bio, profile image) from Firebase Auth and Firestore.
  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Populate email controller (read-only), will not be saved back directly
    _emailController.text = _currentUser!.email ?? 'N/A';

    // Set member since date
    if (_currentUser!.metadata.creationTime != null) {
      _memberSince =
          '${_currentUser!.metadata.creationTime!.day}/${_currentUser!.metadata.creationTime!.month}/${_currentUser!.metadata.creationTime!.year}';
    } else {
      _memberSince = 'N/A';
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          // Fetch and populate bio and username from Firestore if they exist
          _bioController.text = userData['bio'] ?? '';
          // Prioritize Firestore username, then Firebase Auth displayName, then an empty string
          _usernameController.text =
              userData['username'] ?? _currentUser!.displayName ?? '';
          if (mounted) {
            setState(() {
              _currentImageUrl = userData['imageUrl'];
            });
          }
        }
      } else {
        // If user document doesn't exist, try populating from Firebase Auth display name
        _usernameController.text = _currentUser!.displayName ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
    } finally {
      if (mounted) {
        // Update the global profile image provider after loading
        ref.read(profileImageProvider).updateImage(_currentImageUrl);
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  /// Saves updated user data (username, bio) to Firestore.
  Future<void> _saveUserData() async {
    if (_currentUser == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for saving
    });

    try {
      // Save username and bio to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set(
            {
              'username': _usernameController.text.trim(),
              'bio': _bioController.text.trim(),
              'email': _currentUser!.email, // Keep email updated in Firestore
              'lastUpdated': FieldValue.serverTimestamp(),
              'imageUrl': _currentImageUrl, // Ensure image URL is also saved
            },
            SetOptions(merge: true), // Merge to avoid overwriting other fields
          );

      // Update Firebase Auth display name if username changed
      if (_currentUser!.displayName != _usernameController.text.trim()) {
        await _currentUser!.updateDisplayName(_usernameController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  /// Handles picking and uploading a new profile image.
  Future<void> _pickImage() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for image pick/upload
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide if no image selected
          });
        }
        return;
      }

      if (_currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No user logged in to upload image.'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // FIX: Ensure _profileImage is set from the XFile path
      if (mounted) {
        setState(() => _profileImage = File(image.path));
      }

      final storageRef = FirebaseStorage.instance.ref().child(
        'profile-pictures/${_currentUser!.uid}.jpg',
      );

      // Check if _profileImage is null before attempting to upload
      if (_profileImage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Selected image file is null.'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'imageUrl': downloadUrl}, SetOptions(merge: true));

      if (mounted) {
        ref.read(profileImageProvider).updateImage(downloadUrl);
        setState(() {
          _currentImageUrl = downloadUrl; // Update the stored URL
          _profileImage = null; // Clear the local file reference AFTER upload
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
          ),
        );
      }
    } on FirebaseException catch (e) {
      // Catch Firebase specific exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: ${e.message ?? e.code}. Check permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred during upload: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  /// Handles removing the current profile image.
  Future<void> _removeImage() async {
    if (_currentUser == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for image removal
    });

    try {
      // Only attempt to delete from storage if it's a Firebase Storage URL
      if (_currentImageUrl != null &&
          _currentImageUrl!.startsWith(
            'https://firebasestorage.googleapis.com/',
          )) {
        final oldImageRef = FirebaseStorage.instance.refFromURL(
          _currentImageUrl!,
        );
        await oldImageRef.delete();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'imageUrl':
                FieldValue.delete(), // Remove imageUrl field from Firestore
          });

      if (mounted) {
        setState(() {
          _profileImage = null; // Clear local file reference
          _currentImageUrl = null; // Clear the stored URL
        });
      }

      if (mounted) {
        ref.read(profileImageProvider).updateImage(null); // Notify global state
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed!')),
        );
      }
    } on FirebaseException catch (e) {
      // Catch Firebase specific exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Remove failed: ${e.message ?? e.code}. Check permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Toggles the visibility of password change fields.
  void _togglePasswordFields() {
    setState(() {
      _showPasswordFields = !_showPasswordFields;
      if (!_showPasswordFields) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  /// Handles changing the user's password.
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for password change
    });

    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user logged in to change password.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: _currentPasswordController.text,
      );

      await _currentUser!.reauthenticateWithCredential(credential);
      await _currentUser!.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
      }
      if (mounted) {
        setState(() {
          _showPasswordFields = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Invalid current password.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'This operation is sensitive and requires recent authentication. Please log in again.';
      } else {
        errorMessage = 'Failed to change password: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (_isEditing) {
                  if (_formKey.currentState!.validate()) {
                    await _saveUserData();
                    if (mounted) {
                      setState(() {
                        _isEditing = false;
                      });
                    }
                  }
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      drawer: const HomePageMenuBar(),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  _profileImage != null
                                      ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                      )
                                      : _currentImageUrl != null
                                      ? Image.network(
                                        _currentImageUrl!,
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Icon(
                                            Icons.person,
                                            size: 150,
                                            color: colorScheme.onSurface
                                                .withAlpha((255 * 0.4).round()),
                                          );
                                        },
                                      )
                                      : Icon(
                                        Icons.person,
                                        size: 150,
                                        color: colorScheme.onSurface.withAlpha(
                                          (255 * 0.4).round(),
                                        ),
                                      ),
                            ),
                          ),
                          if (_isEditing && !_isLoading)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onPrimary,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                        ],
                      ),
                      if (_isEditing &&
                          (_profileImage != null || _currentImageUrl != null) &&
                          !_isLoading)
                        TextButton(
                          onPressed: _removeImage,
                          child: Text(
                            'Remove photo',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        _usernameController.text.isNotEmpty
                            ? _usernameController.text
                            : 'No Username Set',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Divider(thickness: 2, color: colorScheme.primary),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            label: "Bio",
                            controller: _bioController,
                            initialValue: _bioController.text,
                            enabled: _isEditing && !_isLoading,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            label: "Username",
                            controller: _usernameController,
                            initialValue: _usernameController.text,
                            enabled: _isEditing && !_isLoading,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            label: "Email",
                            controller: _emailController,
                            initialValue: _emailController.text,
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyField(
                            label: "Member Since",
                            value: _memberSince ?? 'N/A',
                          ),
                          const SizedBox(height: 20),
                          if (!_showPasswordFields && _isEditing && !_isLoading)
                            Center(
                              child: TextButton(
                                onPressed: _togglePasswordFields,
                                child: Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          if (_showPasswordFields) ...[
                            _buildPasswordField(
                              label: "Current Password",
                              controller: _currentPasswordController,
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(
                              label: "New Password",
                              controller: _newPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildPasswordField(
                              label: "Confirm New Password",
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _togglePasswordFields,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surface,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _changePassword,
                                  child: const Text('Save Password'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(thickness: 2, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String initialValue,
    bool readOnly = false,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    if (controller.text.isEmpty && initialValue.isNotEmpty) {
      controller.text = initialValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly || !enabled,
          enabled: enabled,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((255 * 0.5).round()),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          validator: validator,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((255 * 0.5).round()),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha((255 * 0.3).round()),
            ),
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
