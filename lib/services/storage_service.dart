import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart' as constants;
import 'api_service.dart';

class StorageService {
  // Upload image file (for File objects - non-web)
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      final response = await ApiService.postMultipart(
        constants.AppConstants.imageUploadPath,
        'image',
        fileBytes,
        fileName,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'imageUrl': response['imageUrl'],
          'filename': response['filename'],
          'message': response['message'] ?? 'Image uploaded successfully',
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to upload image',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading image: ${e.toString()}',
      };
    }
  }

  // Upload image from XFile (cross-platform)
  static Future<Map<String, dynamic>> uploadImageFromXFile(XFile xFile) async {
    try {
      final fileBytes = await xFile.readAsBytes();
      
      // Extract filename - prefer name, fallback to path, final fallback to generated name
      String fileName;
      if (xFile.name.isNotEmpty) {
        fileName = xFile.name;
      } else if (xFile.path.isNotEmpty) {
        final pathParts = xFile.path.split('/');
        final lastPart = pathParts.last;
        if (lastPart.contains('\\')) {
          fileName = lastPart.split('\\').last;
        } else {
          fileName = lastPart;
        }
      } else {
        // Fallback: generate filename with extension detection
        fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }
      
      // Ensure filename has extension
      if (!fileName.contains('.')) {
        fileName = '$fileName.jpg';
      }

      final response = await ApiService.postMultipart(
        constants.AppConstants.imageUploadPath,
        'image',
        fileBytes,
        fileName,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'imageUrl': response['imageUrl'],
          'filename': response['filename'],
          'message': response['message'] ?? 'Image uploaded successfully',
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to upload image',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading image: ${e.toString()}',
      };
    }
  }

  // Delete image
  static Future<Map<String, dynamic>> deleteImage(String filename) async {
    try {
      // Extract just the filename from full path/URL if needed
      String cleanFilename = filename;
      if (filename.contains('/')) {
        cleanFilename = filename.split('/').last;
      }
      
      final response = await ApiService.delete(
        '${constants.AppConstants.imageUploadPath}?filename=$cleanFilename',
      );
      
      return {
        'success': response['success'] == true,
        'message': response['message'] ?? 'Failed to delete image',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting image: ${e.toString()}',
      };
    }
  }

  // Get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty or placeholder image
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Otherwise, construct URL using platform-aware base URL
    final baseUrl = ApiService.getBaseUrl();
    return '$baseUrl/uploads/$imagePath';
  }
}

