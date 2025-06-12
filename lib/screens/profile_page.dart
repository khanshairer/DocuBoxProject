import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_image_provider.dart'; // Ensure this path is correct
import 'package:go_router/go_router.dart';
import '../widgets/homepage_menu_bar_widget.dart'; // Ensure this path is correct

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
    // Listen for auth state changes to ensure _currentUser is always up-to-date
    // and data loading happens when the user is truly logged in.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          if (user != null) {
            _loadUserData(); // Load data only when a user is logged in
          } else {
            // User is logged out, clear data or navigate to login
            _bioController.clear();
            _usernameController.clear();
            _emailController.clear();
            _currentImageUrl = null;
            _profileImage = null;
            _memberSince = null;
            _isLoading = false; // Stop loading if user logs out
          }
        });
      }
    });
    // Initial load if user is already signed in on app start
    if (FirebaseAuth.instance.currentUser != null) {
      _loadUserData();
    }
  }

  /// Loads user data (username, email, bio, profile image) from Firebase Auth and Firestore.
  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      // If no current user, don't attempt to load data
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    _emailController.text = _currentUser!.email ?? 'N/A';

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
          _bioController.text = userData['bio'] ?? '';
          _usernameController.text =
              userData['username'] ?? _currentUser!.displayName ?? '';
          if (mounted) {
            setState(() {
              _currentImageUrl = userData['imageUrl'];
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
    } finally {
      if (mounted) {
        // Update Riverpod provider for profile image across the app
        ref.read(profileImageProvider.notifier).updateImage(_currentImageUrl);
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'bio': _bioController.text.trim(),
            'email': _currentUser!.email,
            'lastUpdated': FieldValue.serverTimestamp(),
            'imageUrl': _currentImageUrl,
          }, SetOptions(merge: true));

      if (_currentUser!.displayName != _usernameController.text.trim()) {
        await _currentUser!.updateDisplayName(_usernameController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.message}')),
        );
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

  /// Handles picking and uploading a new profile image.
  Future<void> _pickImage() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for image pick/upload
    });

    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
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
            const SnackBar(content: Text('No user logged in to upload image.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() => _profileImage = File(image.path));
      }

      final storageRef = FirebaseStorage.instance.ref().child(
        'profile-pictures/${_currentUser!.uid}.jpg',
      );

      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'imageUrl': downloadUrl}, SetOptions(merge: true));

      if (mounted) {
        ref.read(profileImageProvider.notifier).updateImage(downloadUrl);
        setState(() {
          _currentImageUrl = downloadUrl;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
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
          .update({'imageUrl': FieldValue.delete()});

      if (mounted) {
        setState(() {
          _profileImage = null;
          _currentImageUrl = null;
        });
      }

      if (mounted) {
        ref.read(profileImageProvider.notifier).updateImage(null);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed!')),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove image: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  /// Handles user signing out.
  Future<void> _signOut() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading indicator for sign out
    });
    try {
      // Show confirmation dialog
      final bool? confirmSignOut = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(false); // Dismiss dialog, return false
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(true); // Dismiss dialog, return true
                },
                child: const Text('Sign Out'),
              ),
            ],
          );
        },
      );

      if (confirmSignOut == true) {
        await FirebaseAuth.instance.signOut();
        // Clear Riverpod state after sign out
        ref.read(profileImageProvider.notifier).updateImage(null);
        // Navigate to the root or login page after sign out
        if (mounted) {
          context.go('/'); // Assuming '/' is your login/landing page
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.message}')),
        );
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
          // Show save/edit button only if not loading
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
      // Drawer is built here
      drawer: HomePageMenuBar(), // Removed const
      body:
          _isLoading // Show a full-page loading indicator if _isLoading is true
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
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center, // Center children horizontally
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment:
                            Alignment
                                .bottomRight, // Align children of Stack to bottom-right
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
                          // Only show camera button if editing and not loading
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
                      // Only show remove button if editing, image exists, and not loading
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
                            : 'No Username',
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
                            enabled:
                                _isEditing &&
                                !_isLoading, // Disable during loading
                            maxLines: 3, // Allow multiple lines for bio
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            label: "Username",
                            controller: _usernameController,
                            enabled:
                                _isEditing &&
                                !_isLoading, // Disable during loading
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            label: "Email",
                            controller: _emailController,
                            readOnly: true, // Email is read-only
                            enabled:
                                false, // Always disabled for editing via profile page
                          ),
                          const SizedBox(height: 20),
                          _buildReadOnlyField(
                            label: "Member Since",
                            value: _memberSince ?? 'N/A',
                          ),
                          const SizedBox(height: 20),
                          // "Change Password" button
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
                          // Password fields
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
                                      _isLoading
                                          ? null
                                          : _togglePasswordFields, // Disable during loading
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surface,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : _changePassword, // Disable during loading
                                  child: const Text('Save Password'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 30),
                      Divider(thickness: 2, color: colorScheme.primary),
                      const SizedBox(height: 30),
                      // Sign out button
                      ElevatedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : _signOut, // Disable during loading
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              colorScheme.error, // Use error color for signOut
                          foregroundColor: colorScheme.onError,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Spacing at the bottom
                    ],
                  ),
                ),
              ),
    );
  }

  // Helper widget to build form fields (username, bio)
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool enabled = true,
    int maxLines = 1, // Default to single line
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
          readOnly: readOnly || !enabled,
          enabled: enabled,
          maxLines: maxLines, // Apply maxLines
          validator: validator, // Apply validator
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

  // Helper widget to build password fields
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
          enabled: !_isLoading, // Disable during loading
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

  // Helper widget to build read-only fields
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
