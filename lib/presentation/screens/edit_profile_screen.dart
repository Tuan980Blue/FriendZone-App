import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../theme/app_theme.dart';
import '../theme/app_page_transitions.dart';
import '../widgets/common/custom_snackbar.dart';
import '../widgets/profile/edit_profile_avatar_section.dart';
import '../widgets/profile/edit_profile_section_card.dart';
import '../widgets/profile/edit_profile_form_fields.dart';
import '../widgets/profile/edit_profile_bottom_save_button.dart';
import '../widgets/profile/edit_profile_discard_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final UpdateProfileUseCase updateProfileUseCase;
  final Function(User) onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.updateProfileUseCase,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
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
  
  // Store original values for comparison
  late String? originalGender;
  late DateTime? originalBirthDate;
  late bool originalIsPrivate;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    fullNameController = TextEditingController(text: widget.user.fullName);
    bioController = TextEditingController(text: widget.user.bio);
    websiteController = TextEditingController(text: widget.user.website);
    locationController = TextEditingController(text: widget.user.location);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    
    selectedGender = widget.user.gender;
    // Normalize birthDate to local date only to avoid timezone issues
    selectedBirthDate = widget.user.birthDate != null 
        ? DateTime(
            widget.user.birthDate!.year,
            widget.user.birthDate!.month,
            widget.user.birthDate!.day,
          )
        : null;
    isPrivate = widget.user.isPrivate;
    
    // Store original values
    originalGender = widget.user.gender;
    originalBirthDate = widget.user.birthDate != null 
        ? DateTime(
            widget.user.birthDate!.year,
            widget.user.birthDate!.month,
            widget.user.birthDate!.day,
          )
        : null;
    originalIsPrivate = widget.user.isPrivate;

    // Add listeners to track changes
    usernameController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    fullNameController.addListener(_onFieldChanged);
    bioController.addListener(_onFieldChanged);
    websiteController.addListener(_onFieldChanged);
    locationController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _slideController.forward();
  }

  void _onFieldChanged() {
    _checkForChanges();
  }
  
  void _checkForChanges() {
    bool hasChanges = false;
    
    // Check text fields
    hasChanges = hasChanges || 
                 usernameController.text != widget.user.username ||
                 emailController.text != widget.user.email ||
                 fullNameController.text != widget.user.fullName ||
                 bioController.text != widget.user.bio ||
                 websiteController.text != widget.user.website ||
                 locationController.text != widget.user.location ||
                 phoneController.text != widget.user.phoneNumber;
    
    // Check non-text fields
    hasChanges = hasChanges || 
                 selectedGender != originalGender ||
                 isPrivate != originalIsPrivate;
    
    // Check birthDate with proper null handling
    if (selectedBirthDate != originalBirthDate) {
      if (selectedBirthDate == null && originalBirthDate == null) {
        // Both are null, no change
      } else if (selectedBirthDate == null || originalBirthDate == null) {
        // One is null, other is not - there's a change
        hasChanges = true;
      } else {
        // Both are not null, compare only year, month, and day
        bool dateChanged = !_isSameDate(selectedBirthDate!, originalBirthDate!);
        hasChanges = hasChanges || dateChanged;
      }
    }
    
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  // Helper method to compare dates by year, month, and day only
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
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
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

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
      
      widget.onProfileUpdated(updatedUser);
      
      // Pop with result to indicate successful save
      Navigator.pop(context, true);

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Hồ sơ đã được cập nhật thành công!',
      );
    } catch (e) {
      if (!mounted) return;
      
      CustomSnackBar.showError(
        context: context,
        message: 'Không thể cập nhật hồ sơ. Vui lòng thử lại sau.',
        onRetry: _handleSave,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDiscardDialog() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const EditProfileDiscardDialog(),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 20),
          ),
          onPressed: _showDiscardDialog,
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            AnimatedOpacity(
              opacity: _hasChanges ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Lưu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                EditProfileAvatarSection(user: widget.user),
                
                // Basic Information
                EditProfileSectionCard(
                  title: 'Thông tin cơ bản',
                  icon: Icons.person_outline_rounded,
                  accentColor: Colors.blue[600],
                  children: [
                    EditProfileFormFields.buildTextField(
                      label: 'Tên đầy đủ',
                      icon: Icons.badge_outlined,
                      controller: fullNameController,
                    ),
                    EditProfileFormFields.buildTextField(
                      label: 'Tên người dùng',
                      icon: Icons.person_outline_rounded,
                      controller: usernameController,
                      prefix: '@',
                    ),
                    EditProfileFormFields.buildTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),

                // About
                EditProfileSectionCard(
                  title: 'Giới thiệu',
                  icon: Icons.description_outlined,
                  accentColor: Colors.green[600],
                  children: [
                    EditProfileFormFields.buildTextField(
                      label: 'Tiểu sử',
                      icon: Icons.description_outlined,
                      controller: bioController,
                      maxLines: 4,
                    ),
                  ],
                ),

                // Personal Details
                EditProfileSectionCard(
                  title: 'Thông tin cá nhân',
                  icon: Icons.people_outline_rounded,
                  accentColor: Colors.purple[600],
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: EditProfileFormFields.buildDropdownField(
                            label: 'Giới tính',
                            icon: Icons.people_outline_rounded,
                            value: selectedGender,
                            items: const [
                              DropdownMenuItem(value: 'MALE', child: Text('Nam')),
                              DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
                              DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
                            ],
                            onChanged: (value) {
                              setState(() => selectedGender = value);
                              _onFieldChanged();
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: EditProfileFormFields.buildDateField(
                            selectedDate: selectedBirthDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedBirthDate = date;
                                _onFieldChanged();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Contact Information
                EditProfileSectionCard(
                  title: 'Thông tin liên hệ',
                  icon: Icons.contact_phone_outlined,
                  accentColor: Colors.orange[600],
                  children: [
                    EditProfileFormFields.buildTextField(
                      label: 'Website',
                      icon: Icons.language_outlined,
                      controller: websiteController,
                      keyboardType: TextInputType.url,
                    ),
                    EditProfileFormFields.buildTextField(
                      label: 'Vị trí',
                      icon: Icons.location_on_outlined,
                      controller: locationController,
                    ),
                    EditProfileFormFields.buildTextField(
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                // Privacy Settings
                EditProfileSectionCard(
                  title: 'Cài đặt riêng tư',
                  icon: Icons.security_outlined,
                  accentColor: Colors.red[600],
                  children: [
                    EditProfileFormFields.buildPrivacyToggle(
                      isPrivate: isPrivate,
                      onChanged: (value) {
                        setState(() {
                          isPrivate = value;
                          _onFieldChanged();
                        });
                      },
                    ),
                  ],
                ), // Bottom padding for save button
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EditProfileBottomSaveButton(
        hasChanges: _hasChanges,
        isLoading: _isLoading,
        onSave: _handleSave,
      ),
    );
  }
} 