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
  final Size canvasSize;

  const ClothingSticker({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
    required this.onRemove,
    required this.onChanged,
    required this.canvasSize,
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
  // Ramka jest szersza niż wysoka - dla zdjęć pionowych zostaje odrobinę
  // pustego miejsca po bokach (mało widoczne), ale zdjęcia poziome mają
  // teraz realnie miejsce, żeby się w całości i sensownie zmieścić, zamiast
  // kurczyć się do wąskiego paska na środku kwadratu.
  static const double _widthFactor = 1.3;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final w = _baseSize * _widthFactor * d.scale;
    final h = _baseSize * d.scale;
    return Positioned(
      left: d.position.dx - w / 2,
      top: d.position.dy - h / 2,
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
            final raw = _startPosition + (details.focalPoint - _startFocalPoint);
            // Ograniczamy pozycję do granic płótna (z małym marginesem, żeby
            // dało się podejść blisko krawędzi) - inaczej przeciągnięcie
            // wystarczająco daleko w bok chowa element poza obszarem, który
            // płótno przycina, i staje się jednocześnie niewidzialny i
            // nieklikalny, więc nie da się go już wyciągnąć z powrotem.
            const margin = 24.0;
            d.position = Offset(
              raw.dx.clamp(margin, widget.canvasSize.width - margin),
              raw.dy.clamp(margin, widget.canvasSize.height - margin),
            );
            d.scale = (_startScale * details.scale).clamp(0.4, 2.5);
            d.rotation = _startRotation + details.rotation;
          });
          widget.onChanged();
        },
        child: Transform.rotate(
          angle: d.rotation,
          child: Container(
            width: w,
            height: h,
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
                ClothingPhotoBox(item: d.item, height: h, borderRadius: 14),
                if (widget.selected)
                  Positioned(
                    top: -16,
                    right: -16,
                    // Widoczna kropka zostaje mała (24px), ale klikalny
                    // obszar wokół niej jest większy (40px) - to zmniejsza
                    // ryzyko, że dotknięcie blisko krawędzi "przegra" z
                    // gestem przeciągania całej naklejki, który siedzi tuż
                    // pod spodem.
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onRemove,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        color: Colors.transparent,
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
