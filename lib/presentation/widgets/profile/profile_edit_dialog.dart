import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/user/update_profile_usecase.dart';

class ProfileEditDialog extends StatefulWidget {
  final User user;
  final UpdateProfileUseCase updateProfileUseCase;
  final Function(User) onProfileUpdated;

  const ProfileEditDialog({
    super.key,
    required this.user,
    required this.updateProfileUseCase,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController fullNameController;
  late final TextEditingController bioController;
  late final TextEditingController websiteController;
  late final TextEditingController locationController;
  late final TextEditingController phoneController;
  
  late String? selectedGender;
  late DateTime? selectedBirthDate;
  late bool isPrivate;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    fullNameController = TextEditingController(text: widget.user.fullName);
    bioController = TextEditingController(text: widget.user.bio);
    websiteController = TextEditingController(text: widget.user.website);
    locationController = TextEditingController(text: widget.user.location);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    
    selectedGender = widget.user.gender;
    selectedBirthDate = widget.user.birthDate;
    isPrivate = widget.user.isPrivate;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    fullNameController.dispose();
    bioController.dispose();
    websiteController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    try {
      final updatedUser = await widget.updateProfileUseCase(
        id: widget.user.id,
        username: usernameController.text,
        email: emailController.text,
        fullName: fullNameController.text,
        bio: bioController.text,
        website: websiteController.text,
        location: locationController.text,
        phoneNumber: phoneController.text,
        gender: selectedGender,
        birthDate: selectedBirthDate,
        isPrivate: isPrivate,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onProfileUpdated(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar upload coming soon!')),
                );
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.avatar != null
                        ? NetworkImage(widget.user.avatar!)
                        : null,
                    child: widget.user.avatar == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Username
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),

            // Full Name
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Bio
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),

            // Gender
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 8),

            // Birth Date
            ListTile(
              title: const Text('Birth Date'),
              subtitle: Text(
                selectedBirthDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedBirthDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedBirthDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    selectedBirthDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 8),

            // Website
            TextField(
              controller: websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),

            // Location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Phone
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),

            // Privacy
            SwitchListTile(
              title: const Text('Private Profile'),
              subtitle: const Text('Only followers can see your posts'),
              value: isPrivate,
              onChanged: (value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 