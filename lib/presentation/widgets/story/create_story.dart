import 'package:flutter/material.dart';
import '../../../di/injection_container.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/entities/user.dart'; // Make sure to import your User entity

class CreateStoryEntry extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const CreateStoryEntry({
    super.key,
    required this.onTap,
    this.text = 'Tạo tin',
  });

  @override
  Widget build(BuildContext context) {
    final GetCurrentUserUseCase getCurrentUserUseCase = sl<GetCurrentUserUseCase>();

    return FutureBuilder<User>(
      future: getCurrentUserUseCase.call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorPlaceholder();
        }

        final user = snapshot.data!;
        final userImageUrl = user.avatar; // Assuming your User entity has avatarUrl

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 110,
            height: 190,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // User avatar part
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    userImageUrl!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Colors.grey[200],
                          height: 140,
                          child: const Icon(Icons.person, size: 40),
                        ),
                  ),
                ),

                // Create story button
                Positioned(
                  bottom: 40,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),

                // Text
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 110,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 110,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: Icon(Icons.error)),
    );
  }
}