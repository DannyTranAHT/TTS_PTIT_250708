import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Request permissions for different Android versions
  static Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Try new Android 13+ permissions first
        Map<Permission, PermissionStatus> newPermissions =
            await [
              Permission.camera,
              Permission.photos, // READ_MEDIA_IMAGES for Android 13+
            ].request();

        // If new permissions work, use them
        if (newPermissions[Permission.camera]?.isGranted == true) {
          return newPermissions[Permission.photos]?.isGranted == true;
        }

        // Fallback to legacy permissions for older Android
        Map<Permission, PermissionStatus> legacyPermissions =
            await [Permission.camera, Permission.storage].request();

        return legacyPermissions[Permission.camera]?.isGranted == true &&
            legacyPermissions[Permission.storage]?.isGranted == true;
      } else if (Platform.isIOS) {
        Map<Permission, PermissionStatus> statuses =
            await [Permission.camera, Permission.photos].request();

        return statuses[Permission.camera]?.isGranted == true &&
            statuses[Permission.photos]?.isGranted == true;
      }
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Show permission dialog
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String type,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cần cấp quyền'),
            content: Text(
              'Ứng dụng cần quyền truy cập $type. '
              'Vui lòng vào Cài đặt để cấp quyền.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text('Mở cài đặt'),
              ),
            ],
          ),
    );
  }

  // Show dialog để chọn nguồn ảnh
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final String? source = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn ảnh đại diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Chụp ảnh'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Chọn từ thư viện'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );

    if (source == null) {
      print('❌ User cancelled image selection');
      return null;
    }

    print('📱 User selected source: $source');

    // Now call the appropriate picker
    if (source == 'camera') {
      return await _getImageFromCamera(context);
    } else if (source == 'gallery') {
      return await _getImageFromGallery(context);
    }

    return null;
  }

  // Chụp ảnh từ camera
  static Future<File?> _getImageFromCamera(BuildContext context) async {
    try {
      print('🎥 Attempting to access camera...');

      // Check and request permissions
      final cameraPermission = await Permission.camera.status;
      print('📋 Current camera permission: $cameraPermission');

      if (cameraPermission.isDenied) {
        print('📋 Requesting camera permission...');
        final result = await Permission.camera.request();
        print('📋 Camera permission result: $result');

        if (result.isDenied || result.isPermanentlyDenied) {
          if (context.mounted) {
            await _showPermissionDialog(context, 'camera');
          }
          return null;
        }
      }

      // Additional permission request
      final hasAllPermissions = await _requestPermissions();
      if (!hasAllPermissions) {
        print('❌ Not all permissions granted');
        if (context.mounted) {
          await _showPermissionDialog(context, 'camera và storage');
        }
        return null;
      }

      print('✅ Permissions granted, opening camera...');
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        print('✅ Image captured: ${pickedFile.path}');
        return File(pickedFile.path);
      } else {
        print('❌ No image captured');
        return null;
      }
    } on PlatformException catch (e) {
      print('❌ Platform exception: ${e.code} - ${e.message}');
      if (e.code == 'camera_access_denied' && context.mounted) {
        await _showPermissionDialog(context, 'camera');
      }
      return null;
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      return null;
    }
  }

  // Chọn ảnh từ thư viện
  static Future<File?> _getImageFromGallery(BuildContext context) async {
    try {
      print('🖼️ Attempting to access gallery...');

      // Check permissions
      Permission storagePermission =
          Platform.isAndroid
              ? Permission
                  .photos // For Android 13+
              : Permission.photos; // For iOS

      final currentStatus = await storagePermission.status;
      print('📋 Current storage permission: $currentStatus');

      if (currentStatus.isDenied) {
        print('📋 Requesting storage permission...');
        final result = await storagePermission.request();
        print('📋 Storage permission result: $result');

        if (result.isDenied || result.isPermanentlyDenied) {
          if (context.mounted) {
            await _showPermissionDialog(context, 'thư viện ảnh');
          }
          return null;
        }
      }

      // Additional permission request
      final hasAllPermissions = await _requestPermissions();
      if (!hasAllPermissions) {
        print('❌ Not all permissions granted');
        if (context.mounted) {
          await _showPermissionDialog(context, 'thư viện ảnh');
        }
        return null;
      }

      print('✅ Permissions granted, opening gallery...');
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Image selected: ${pickedFile.path}');
        return File(pickedFile.path);
      } else {
        print('❌ No image selected');
        return null;
      }
    } on PlatformException catch (e) {
      print('❌ Platform exception: ${e.code} - ${e.message}');
      if (e.code == 'photo_access_denied' && context.mounted) {
        await _showPermissionDialog(context, 'thư viện ảnh');
      }
      return null;
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  // Kiểm tra kích thước file (max 5MB)
  static bool isValidFileSize(File file) {
    try {
      final fileSizeInBytes = file.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      print('📊 File size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      return fileSizeInMB <= 5;
    } catch (e) {
      print('❌ Error checking file size: $e');
      return false;
    }
  }
}
