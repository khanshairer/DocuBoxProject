import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save changes logic here
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                    border: Border.all(color: Colors.blue[900]!, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/default_profile_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement image picker
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "John Doe", // Replace with actual username
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 30),
            Divider(thickness: 2, color: Colors.blue[900]),
            const SizedBox(height: 20),
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField(
                    label: "Bio",
                    controller: _bioController,
                    initialValue: "Flutter enthusiast and nature lover",
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    label: "Username",
                    controller: _usernameController,
                    initialValue: "johndoe123",
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    label: "Email",
                    controller: _emailController,
                    initialValue: "john.doe@example.com",
                    readOnly: true, // Email often shouldn't be editable
                  ),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    label: "Member Since",
                    value: "January 2023",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 2, color: Colors.blue[900]),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String initialValue,
    bool readOnly = false,
  }) {
    if (controller.text.isEmpty) {
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
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: !_isEditing || readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[900]!),
            ),
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
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
