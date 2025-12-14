import 'dart:io';
import '../utils/constants.dart' as constants;
import 'api_service.dart';

class StorageService {
  // Upload image file
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

