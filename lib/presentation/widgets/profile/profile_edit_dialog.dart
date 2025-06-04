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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          Hero(
                            tag: 'profile_avatar_${widget.user.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: colorScheme.surfaceVariant,
                                backgroundImage: widget.user.avatar != null
                                    ? NetworkImage(widget.user.avatar!)
                                    : null,
                                child: widget.user.avatar == null
                                    ? Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant)
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: colorScheme.primary,
                              elevation: 4,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Avatar upload coming soon!')),
                                  );
                                },
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    _buildSectionTitle(context, 'Basic Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      context,
                      controller: usernameController,
                      label: 'Username',
                      icon: Icons.person_outline,
                      prefix: '@',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: fullNameController,
                      label: 'Full Name',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'About'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: bioController,
                      label: 'Bio',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle(context, 'Gender and Birth Date'),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 400) {
                          // Xếp dọc khi hẹp
                          return Column(
                            children: [
                              _buildDropdownField(
                                context,
                                value: selectedGender,
                                label: 'Gender',
                                icon: Icons.people_outline,
                                items: const [
                                  DropdownMenuItem(value: 'MALE', child: Text('Male', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'FEMALE', child: Text('Female', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'OTHER', child: Text('Other', overflow: TextOverflow.ellipsis)),
                                ],
                                onChanged: (value) => setState(() => selectedGender = value),
                              ),
                              const SizedBox(height: 8),
                              _buildDateField(context),
                            ],
                          );
                        } else {
                          // Xếp ngang khi đủ rộng
                          return Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: _buildDropdownField(
                                  context,
                                  value: selectedGender,
                                  label: 'Gender',
                                  icon: Icons.people_outline,
                                  items: const [
                                    DropdownMenuItem(value: 'MALE', child: Text('Male', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'FEMALE', child: Text('Female', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'OTHER', child: Text('Other', overflow: TextOverflow.ellipsis)),
                                  ],
                                  onChanged: (value) => setState(() => selectedGender = value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 1,
                                child: _buildDateField(context),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Contact Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: websiteController,
                      label: 'Website',
                      icon: Icons.language_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: locationController,
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Privacy'),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Private Profile',
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Only followers can see your posts',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: isPrivate,
                        onChanged: (value) => setState(() => isPrivate = value),
                        activeColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      items: items,
      onChanged: onChanged,
      style: theme.textTheme.bodyLarge,
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
      dropdownColor: colorScheme.surface,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedBirthDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: colorScheme.copyWith(
                  primary: colorScheme.primary,
                  onPrimary: colorScheme.onPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            selectedBirthDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Birth Date',
          prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Text(
          selectedBirthDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedBirthDate!)
              : 'Select date',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: selectedBirthDate != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
} 