import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_hub/config/api_config.dart';
import 'package:project_hub/providers/auth_provider.dart';
import 'package:project_hub/res/images/app_images.dart';
import 'package:project_hub/services/image_picker_service.dart';
import 'package:provider/provider.dart';

class AvatarCard extends StatefulWidget {
  const AvatarCard({Key? key}) : super(key: key);

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard> {
  Future<void> _uploadAvatar() async {
    try {
      final imageFile = await ImagePickerService.showImageSourceDialog(context);
      if (imageFile == null) {
        return;
      }

      if (!ImagePickerService.isValidFileSize(imageFile)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File size exceeds 2MB limit')));
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.uploadAvatar(imageFile);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading avatar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null || authProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image:
                  (authProvider.user?.avatar == "None" ||
                          authProvider.errorMessage != null)
                      ? AssetImage(AppImages.avt)
                      : NetworkImage(
                        '${ApiConfig.socketUrl}/${authProvider.user!.avatar!}',
                      ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _uploadAvatar,
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
