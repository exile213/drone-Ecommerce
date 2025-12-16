import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../services/storage_service.dart';

/// Widget that displays product images, handling CORS issues on web
/// by using Firebase Storage getData() method for Firebase Storage URLs
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? 
          Container(
            color: Colors.grey[200],
            width: width,
            height: height,
            child: const Icon(Icons.image, size: 48),
          );
    }

    // For web with Firebase Storage URLs, use getData() to bypass CORS
    // For other platforms or non-Firebase URLs, use Image.network
    if (kIsWeb && StorageService.isFirebaseStorageUrl(imageUrl)) {
      return FutureBuilder<Uint8List?>(
        future: StorageService.getImageBytes(imageUrl!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ??
                SizedBox(
                  width: width,
                  height: height,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
            );
          }

          // Fallback to Image.network if getData() failed
          return Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ??
                  Container(
                    color: Colors.grey[200],
                    width: width,
                    height: height,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  );
            },
          );
        },
      );
    }

    // For non-web or non-Firebase URLs, use Image.network
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: Colors.grey[200],
              width: width,
              height: height,
              child: const Icon(Icons.image_not_supported, size: 48),
            );
      },
    );
  }
}

