import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import 'login_screen.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/usecases/user/update_profile_usecase.dart';

class ProfileScreen extends StatefulWidget {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final String? userId; // null means current user's profile

  const ProfileScreen({
    super.key,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.getUserByIdUseCase,
    required this.updateProfileUseCase,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  User? _currentUser;
  bool _isLoading = true;
  String _error = '';
  final LoginUseCase _loginUseCase = sl<LoginUseCase>();

  // Kiểm tra xem đang xem profile của chính mình hay không
  bool get isViewingOwnProfile {
    if (_currentUser == null || _user == null) return false;
    return _currentUser!.id == _user!.id;
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Initialize timeago
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Luôn lấy thông tin user hiện tại trước
      _currentUser = await widget.getCurrentUserUseCase();

      // Sau đó mới lấy thông tin profile cần xem
      if (widget.userId == null || widget.userId == _currentUser!.id) {
        // Nếu là profile của chính mình
        _user = _currentUser;
      } else {
        // Nếu là profile của người khác
        _user = await widget.getUserByIdUseCase(widget.userId!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (!isViewingOwnProfile) return; // Chỉ cho phép logout từ profile của chính mình
    
    try {
      await widget.logoutUseCase();
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            loginUseCase: sl<LoginUseCase>(),
            googleSignInUseCase: sl<GoogleSignInUseCase>(),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (!isViewingOwnProfile) return;

    final TextEditingController usernameController = TextEditingController(text: _user?.username);
    final TextEditingController emailController = TextEditingController(text: _user?.email);
    final TextEditingController fullNameController = TextEditingController(text: _user?.fullName);
    final TextEditingController bioController = TextEditingController(text: _user?.bio);
    final TextEditingController websiteController = TextEditingController(text: _user?.website);
    final TextEditingController locationController = TextEditingController(text: _user?.location);
    final TextEditingController phoneController = TextEditingController(text: _user?.phoneNumber);
    
    String? selectedGender = _user?.gender;
    DateTime? selectedBirthDate = _user?.birthDate;
    bool isPrivate = _user?.isPrivate ?? false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    // TODO: Implement avatar upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar upload coming soon!')),
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user?.avatar != null
                            ? NetworkImage(_user!.avatar!)
                            : null,
                        child: _user?.avatar == null
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
              onPressed: () async {
                try {
                  final updatedUser = await widget.updateProfileUseCase(
                    id: _user!.id,
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
                  
                  setState(() {
                    _user = updatedUser;
                    _currentUser = updatedUser;
                  });

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
              },
              child: const Text('Save'),
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
        title: Text(isViewingOwnProfile ? 'My Profile' : 'Profile'),
        actions: [
          if (isViewingOwnProfile)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _user?.avatar != null
                                  ? NetworkImage(_user!.avatar!)
                                  : null,
                              child: _user?.avatar == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user?.username ?? '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (_user?.fullName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _user!.fullName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                            if (!isViewingOwnProfile && _user != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement follow/unfollow
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Follow functionality coming soon!'),
                                        ),
                                      );
                                    },
                                    child: Text(_user!.isFollowing ? 'Unfollow' : 'Follow'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      // TODO: Implement message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Message functionality coming soon!'),
                                        ),
                                      );
                                    },
                                    child: const Text('Message'),
                                  ),
                                ],
                              ),
                            ],
                            if (isViewingOwnProfile) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _showEditProfileDialog,
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Posts', _user?.postsCount ?? 0),
                          _buildStatItem('Followers', _user?.followersCount ?? 0),
                          _buildStatItem('Following', _user?.followingCount ?? 0),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
                        Text(
                          'Bio',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_user!.bio!),
                        const SizedBox(height: 24),
                      ],

                      // Personal Information
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              if (_user?.gender != null) ...[
                                _buildInfoRow(
                                  Icons.person_outline,
                                  'Gender',
                                  _formatGender(_user!.gender!),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_user?.birthDate != null) ...[
                                _buildInfoRow(
                                  Icons.cake,
                                  'Birth Date',
                                  DateFormat('dd/MM/yyyy').format(_user!.birthDate!.toLocal()),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_user?.status != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(_user!.status!),
                                      size: 20,
                                      color: _getStatusColor(_user!.status!),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                          Text(
                                            _formatStatus(_user!.status!),
                                            style: TextStyle(
                                              color: _getStatusColor(_user!.status!),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_user?.lastSeen != null) ...[
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Last Seen',
                                  timeago.format(_user!.lastSeen!.toLocal()),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_user?.role != null && _user!.role != 'USER') ...[
                                _buildInfoRow(
                                  Icons.verified_user,
                                  'Role',
                                  _user!.role,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Information
                      if (isViewingOwnProfile || !_user!.isPrivate) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                if (isViewingOwnProfile || _user!.email != null)
                                  _buildInfoRow(
                                    Icons.email,
                                    'Email',
                                    _user?.email ?? '',
                                  ),
                                if (_user?.phoneNumber != null && _user!.phoneNumber!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.phone,
                                    'Phone',
                                    _user!.phoneNumber!,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.person,
                                  'Username',
                                  _user?.username ?? '',
                                ),
                                if (_user?.location != null && _user!.location!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.location_on,
                                    'Location',
                                    _user!.location!,
                                  ),
                                ],
                                if (_user?.website != null && _user!.website!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.link,
                                    'Website',
                                    _user!.website!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Account Information
                      if (isViewingOwnProfile)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Created At',
                                  DateFormat('dd/MM/yyyy HH:mm').format(_user!.createdAt.toLocal()),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.update,
                                  'Last Updated',
                                  DateFormat('dd/MM/yyyy HH:mm').format(_user!.updatedAt.toLocal()),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  String _formatGender(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return 'Online';
      case 'OFFLINE':
        return 'Offline';
      case 'AWAY':
        return 'Away';
      case 'BUSY':
        return 'Busy';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return Icons.circle;
      case 'OFFLINE':
        return Icons.circle_outlined;
      case 'AWAY':
        return Icons.access_time;
      case 'BUSY':
        return Icons.do_not_disturb_on;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return Colors.green;
      case 'OFFLINE':
        return Colors.grey;
      case 'AWAY':
        return Colors.orange;
      case 'BUSY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 