import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'api_service.dart';
import '../utils/debug_logger.dart';

class StorageService {
  // Generate unique filename for Firebase Storage
  static String _generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    
    // Extract extension from original filename
    String extension = 'jpg';
    if (originalFileName.contains('.')) {
      extension = originalFileName.split('.').last.toLowerCase();
      // Validate extension - default to jpg if invalid
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        extension = 'jpg';
      }
    }
    
    return 'products/${timestamp}_$random.$extension';
  }

  // Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // Upload image file (for File objects - non-web)
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final originalFileName = imageFile.path.split('/').last;
      final storagePath = _generateUniqueFileName(originalFileName);
      final extension = originalFileName.contains('.')
          ? originalFileName.split('.').last.toLowerCase()
          : 'jpg';
      final contentType = _getContentType(extension);

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(contentType: contentType),
      );

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      // #region agent log
      await DebugLogger.log(
        location: 'storage_service.dart:67',
        message: 'Firebase Storage download URL obtained (uploadImage)',
        data: {
          'downloadUrl': downloadUrl,
          'storagePath': storagePath,
          'isFirebaseUrl': downloadUrl.contains('firebasestorage.googleapis.com'),
          'urlLength': downloadUrl.length,
        },
        hypothesisId: 'A',
      );
      // #endregion

      return {
        'success': true,
        'imageUrl': downloadUrl,
        'filename': storagePath,
        'message': 'Image uploaded successfully',
      };
    } on FirebaseException catch (e) {
      String errorMessage = 'Failed to upload image';
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check Firebase Storage rules.';
          break;
        case 'unauthenticated':
          errorMessage = 'Authentication required. Please log in again.';
          break;
        case 'canceled':
          errorMessage = 'Upload was canceled.';
          break;
        case 'unknown':
          errorMessage = 'An unknown error occurred: ${e.message}';
          break;
        default:
          errorMessage = 'Upload failed: ${e.message ?? e.code}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      String errorMsg = 'Error uploading image: ${e.toString()}';
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMsg = 'Upload timed out. Please try again.';
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  // Upload image from XFile (cross-platform)
  static Future<Map<String, dynamic>> uploadImageFromXFile(XFile xFile) async {
    try {
      final fileBytes = await xFile.readAsBytes();
      
      // Extract filename - prefer name, fallback to path, final fallback to generated name
      String originalFileName;
      if (xFile.name.isNotEmpty) {
        originalFileName = xFile.name;
      } else if (xFile.path.isNotEmpty) {
        final pathParts = xFile.path.split('/');
        final lastPart = pathParts.last;
        if (lastPart.contains('\\')) {
          originalFileName = lastPart.split('\\').last;
        } else {
          originalFileName = lastPart;
        }
      } else {
        // Fallback: generate filename with extension detection
        originalFileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }
      
      // Ensure filename has extension
      if (!originalFileName.contains('.')) {
        originalFileName = '$originalFileName.jpg';
      }

      final storagePath = _generateUniqueFileName(originalFileName);
      final extension = originalFileName.contains('.')
          ? originalFileName.split('.').last.toLowerCase()
          : 'jpg';
      final contentType = _getContentType(extension);

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putData(
        Uint8List.fromList(fileBytes),
        SettableMetadata(contentType: contentType),
      );

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      // #region agent log
      await DebugLogger.log(
        location: 'storage_service.dart:158',
        message: 'Firebase Storage download URL obtained (uploadImageFromXFile)',
        data: {
          'downloadUrl': downloadUrl,
          'storagePath': storagePath,
          'isFirebaseUrl': downloadUrl.contains('firebasestorage.googleapis.com'),
          'urlLength': downloadUrl.length,
        },
        hypothesisId: 'A',
      );
      // #endregion

      return {
        'success': true,
        'imageUrl': downloadUrl,
        'filename': storagePath,
        'message': 'Image uploaded successfully',
      };
    } on FirebaseException catch (e) {
      String errorMessage = 'Failed to upload image';
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check Firebase Storage rules.';
          break;
        case 'unauthenticated':
          errorMessage = 'Authentication required. Please log in again.';
          break;
        case 'canceled':
          errorMessage = 'Upload was canceled.';
          break;
        case 'unknown':
          errorMessage = 'An unknown error occurred: ${e.message}';
          break;
        default:
          errorMessage = 'Upload failed: ${e.message ?? e.code}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      String errorMsg = 'Error uploading image: ${e.toString()}';
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMsg = 'Upload timed out. Please try again.';
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  // Extract Firebase Storage path from URL
  static String? _extractStoragePathFromUrl(String url) {
    try {
      // Firebase Storage URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token=...
      if (url.contains('firebasestorage.googleapis.com')) {
        final uri = Uri.parse(url);
        // Extract path from the 'o' parameter
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 3 && pathSegments[0] == 'v0' && pathSegments[1] == 'b') {
          // Find 'o' segment which contains the file path
          final oIndex = pathSegments.indexOf('o');
          if (oIndex != -1 && oIndex < pathSegments.length - 1) {
            // Get everything after 'o' and decode URL encoding
            final encodedPath = pathSegments.sublist(oIndex + 1).join('/');
            return Uri.decodeComponent(encodedPath);
          }
        }
      }
      // If it's already a path (starts with 'products/'), return as-is
      if (url.startsWith('products/')) {
        return url;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete image
  static Future<Map<String, dynamic>> deleteImage(String filenameOrUrl) async {
    try {
      // Extract Firebase Storage path from URL or use as-is if it's already a path
      String? storagePath = _extractStoragePathFromUrl(filenameOrUrl);
      
      // If extraction failed, check if it's a direct path
      if (storagePath == null) {
        if (filenameOrUrl.startsWith('products/')) {
          storagePath = filenameOrUrl;
        } else {
          // If it's an old PHP filename, we can't delete from Firebase Storage
          // Return success (file doesn't exist in Firebase Storage anyway)
          return {
            'success': true,
            'message': 'Image not found in Firebase Storage (may be old PHP upload)',
          };
        }
      }

      // Delete from Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.delete();

      return {
        'success': true,
        'message': 'Image deleted successfully',
      };
    } on FirebaseException catch (e) {
      // If file doesn't exist, treat as success (already deleted)
      if (e.code == 'object-not-found') {
        return {
          'success': true,
          'message': 'Image not found (may already be deleted)',
        };
      }
      
      String errorMessage = 'Failed to delete image';
      if (e.code == 'permission-denied') {
        errorMessage = 'Permission denied. Cannot delete image.';
      } else {
        errorMessage = 'Delete failed: ${e.message ?? e.code}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting image: ${e.toString()}',
      };
    }
  }

  // Check if URL is a Firebase Storage URL
  static bool isFirebaseStorageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.contains('firebasestorage.googleapis.com');
  }

  // Delete image silently (for cleanup - doesn't throw errors)
  // Returns true if deleted successfully or if it's not a Firebase Storage image
  static Future<bool> deleteImageIfFirebase(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return true;
    
    // Only delete Firebase Storage images, not old PHP images
    if (!isFirebaseStorageUrl(imageUrl)) {
      return true; // Not a Firebase image, nothing to delete
    }

    try {
      final result = await deleteImage(imageUrl);
      // Return true even if deletion "failed" due to object-not-found (already deleted)
      return result['success'] == true || 
             (result['message']?.toString().contains('not found') ?? false);
    } catch (e) {
      // Silently fail - don't break product operations if image deletion fails
      return false;
    }
  }

  // Get image bytes from Firebase Storage (bypasses CORS on web)
  static Future<Uint8List?> getImageBytes(String imageUrl) async {
    try {
      // Only use this method for Firebase Storage URLs
      if (!isFirebaseStorageUrl(imageUrl)) {
        return null; // Not a Firebase Storage URL, use regular Image.network
      }

      // Extract storage path from URL
      final storagePath = _extractStoragePathFromUrl(imageUrl);
      if (storagePath == null) {
        return null; // Couldn't extract path
      }

      // Fetch image bytes using Firebase Storage SDK (bypasses CORS)
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final bytes = await storageRef.getData();
      
      // #region agent log
      await DebugLogger.log(
        location: 'storage_service.dart:getImageBytes',
        message: 'Fetched image bytes from Firebase Storage',
        data: {
          'imageUrl': imageUrl,
          'storagePath': storagePath,
          'bytesLength': bytes?.length ?? 0,
        },
        hypothesisId: 'G',
      );
      // #endregion
      
      return bytes;
    } catch (e) {
      // #region agent log
      await DebugLogger.log(
        location: 'storage_service.dart:getImageBytes',
        message: 'Failed to fetch image bytes',
        data: {
          'imageUrl': imageUrl,
          'error': e.toString(),
        },
        hypothesisId: 'G',
      );
      // #endregion
      return null; // Return null to fall back to Image.network
    }
  }

  // Get full image URL (with backward compatibility)
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty or placeholder image
    }

    // If it's already a full URL (Firebase Storage or any HTTPS/HTTP URL), return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Otherwise, treat as old PHP filename and construct URL using platform-aware base URL
    // This maintains backward compatibility for existing products with PHP-uploaded images
    final baseUrl = ApiService.getBaseUrl();
    return '$baseUrl/uploads/$imagePath';
  }
}

