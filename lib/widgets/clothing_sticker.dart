import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import 'clothing_photo_box.dart';

class StickerData {
  final String id;
  final ClothingItem item;
  Offset position;
  double scale;
  double rotation;

  StickerData({
    required this.id,
    required this.item,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

/// Pojedyncze ubranie na "płótnie" manekina - można je przeciągać,
/// skalować (uszczypnięcie) i obracać jednym gestem.
class ClothingSticker extends StatefulWidget {
  final StickerData data;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const ClothingSticker({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<ClothingSticker> createState() => _ClothingStickerState();
}

class _ClothingStickerState extends State<ClothingSticker> {
  Offset _startPosition = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  double _startScale = 1.0;
  double _startRotation = 0.0;

  static const double _baseSize = 130;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Positioned(
      left: d.position.dx - (_baseSize * d.scale) / 2,
      top: d.position.dy - (_baseSize * d.scale) / 2,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: (details) {
          _startPosition = d.position;
          _startFocalPoint = details.focalPoint;
          _startScale = d.scale;
          _startRotation = d.rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            d.position = _startPosition + (details.focalPoint - _startFocalPoint);
            d.scale = (_startScale * details.scale).clamp(0.4, 2.5);
            d.rotation = _startRotation + details.rotation;
          });
          widget.onChanged();
        },
        child: Transform.rotate(
          angle: d.rotation,
          child: Container(
            width: _baseSize * d.scale,
            height: _baseSize * d.scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: widget.selected
                  ? Border.all(color: AppColors.champagneGold, width: 2)
                  : null,
              boxShadow: widget.selected ? AppColors.softCardShadow : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClothingPhotoBox(item: d.item, height: _baseSize * d.scale, borderRadius: 14),
                if (widget.selected)
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: AppColors.paper),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
