import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import 'color_picker_grid.dart';

/// Pudełko ze zdjęciem ubrania - zdjęcie mieści się w całości (BoxFit.contain)
/// na jasnym, neutralnym tle, żeby nic nie było przycięte.
/// Kolejność źródeł: lokalny plik (najszybszy) -> zdjęcie z chmury (gdy
/// zalogowana, np. na nowym urządzeniu) -> kolor ubrania jako zapasowo.
class ClothingPhotoBox extends StatelessWidget {
  final ClothingItem item;
  final double height;
  final double borderRadius;

  const ClothingPhotoBox({
    super.key,
    required this.item,
    this.height = 120,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalPhoto =
        item.photoPath != null && File(item.photoPath!).existsSync();
    final hasCloudPhoto = item.photoUrl != null && item.photoUrl!.isNotEmpty;

    Widget child;
    if (hasLocalPhoto) {
      child = Image.file(File(item.photoPath!), fit: BoxFit.contain);
    } else if (hasCloudPhoto) {
      child = CachedNetworkImage(
        imageUrl: item.photoUrl!,
        fit: BoxFit.contain,
        placeholder: (ctx, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (ctx, url, err) => ClothingColorSwatch(
          hex: item.colorHex,
          size: height,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    } else {
      child = ClothingColorSwatch(
        hex: item.colorHex,
        size: height,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/wardrobe_bg.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: AppColors.bg.withValues(alpha: 0.4)),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
