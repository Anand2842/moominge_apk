import 'package:flutter/material.dart';

/// A widget that safely loads images with fallback for web CORS issues
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackInitial;

  const SafeNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackInitial,
  });

  @override
  Widget build(BuildContext context) {
    final widget = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }

  Widget _buildImage() {
    // If no URL or empty, show placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // For local assets
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // For network images - use Image.network with error handling
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoading();
      },
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD3A15F).withOpacity(0.3),
            const Color(0xFF8B5A2B).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: fallbackInitial != null
            ? Text(
                fallbackInitial!,
                style: TextStyle(
                  color: const Color(0xFF5D3A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: (width ?? 50) * 0.4,
                ),
              )
            : Icon(
                Icons.pets,
                color: const Color(0xFF5D3A1A).withOpacity(0.5),
                size: (width ?? 50) * 0.4,
              ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5E0C3),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD3A15F),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Circle avatar with safe image loading
class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackInitial;

  const SafeCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackInitial,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SafeNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fallbackInitial: fallbackInitial,
      ),
    );
  }
}
