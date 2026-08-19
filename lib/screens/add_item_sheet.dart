import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../services/photo_analysis_service.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/color_picker_grid.dart';
import '../widgets/clothing_photo_box.dart';
import 'bulk_add_screen.dart';

Future<void> showAddItemSheet(BuildContext context, {ClothingItem? existingItem}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => _AddItemSheet(existingItem: existingItem),
  );
}

/// Wspólne okno wyboru sposobu dodawania ubrania - dodaj ręcznie (jeden
/// formularz) albo grupowo (kilka zdjęć naraz). Używane zarówno przez
/// przycisk "+" w pasku nawigacji, jak i przez szybką akcję na Home.
void showAddOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 22 + MediaQuery.of(sheetContext).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dodaj ubranie', style: displayFont(fontSize: 18)),
          const SizedBox(height: 16),
          _addOptionTile(
            context: sheetContext,
            icon: Icons.edit_outlined,
            title: 'Dodaj ręcznie',
            subtitle: 'Jedno ubranie, pełny formularz',
            onTap: () {
              Navigator.pop(sheetContext);
              showAddItemSheet(context);
            },
          ),
          const SizedBox(height: 10),
          _addOptionTile(
            context: sheetContext,
            icon: Icons.photo_library_outlined,
            title: 'Dodaj grupowo',
            subtitle: 'Kilka zdjęć naraz - spróbujemy uzupełnić dane automatycznie',
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BulkAddScreen()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _addOptionTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkSoft),
        ],
      ),
    ),
  );
}

class _AddItemSheet extends StatefulWidget {
  final ClothingItem? existingItem;
  const _AddItemSheet({this.existingItem});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _customSubcatCtrl = TextEditingController();
  final _photoAnalysis = PhotoAnalysisService();

  ClothingCategory _category = ClothingCategory.top;
  String? _subcategory;
  bool _useCustomSubcat = false;
  String _colorHex = kClothingColors.first.hex;
  File? _photoFile;
  bool _saving = false;
  bool _analyzing = false;
  bool _categoryAutoFilled = false;
  bool _colorAutoFilled = false;
  final Set<String> _selectedSeasons = {};
  String? _ownershipAge;
  final _initialWearsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    if (existing != null) {
      _nameCtrl.text = existing.name;
      if (existing.price != null) _priceCtrl.text = existing.price!.toStringAsFixed(2);
      _category = existing.category;
      _colorHex = existing.colorHex;
      _selectedSeasons.addAll(existing.seasons);
      _ownershipAge = existing.ownershipAge;
      _initialWearsCtrl.text = existing.wears.toString();
      if (existing.category.defaultSubcategories.contains(existing.subcategory)) {
        _subcategory = existing.subcategory;
        _useCustomSubcat = false;
      } else {
        _useCustomSubcat = existing.subcategory.isNotEmpty;
        _customSubcatCtrl.text = existing.subcategory;
        _subcategory = existing.category.defaultSubcategories.first;
      }
    } else {
      _subcategory = _category.defaultSubcategories.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _customSubcatCtrl.dispose();
    _initialWearsCtrl.dispose();
    _photoAnalysis.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Wybierz z galerii'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Zrób zdjęcie'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1000, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _photoFile = File(picked.path);
        _categoryAutoFilled = false;
        _colorAutoFilled = false;
      });
      await _analyzePhoto();
    }
  }

  /// Rozpoznaje kategorię i kolor ze zdjęcia (w całości na urządzeniu, bez
  /// wysyłania zdjęcia gdziekolwiek). To WYŁĄCZNIE podpowiedź do formularza -
  /// nic nie zapisuje się do szafy, dopóki nie zatwierdzisz przyciskiem
  /// "Dodaj do szafy", a każde pole nadal można ręcznie zmienić.
  Future<void> _analyzePhoto() async {
    if (_photoFile == null) return;
    setState(() => _analyzing = true);
    try {
      final result = await _photoAnalysis.analyze(_photoFile!);
      if (!mounted) return;
      setState(() {
        if (result.category != null) {
          _category = result.category!;
          _subcategory = result.category!.defaultSubcategories.first;
          _useCustomSubcat = false;
          _categoryAutoFilled = true;
        }
        if (result.colorHex != null) {
          _colorHex = result.colorHex!;
          _colorAutoFilled = true;
        }
      });
      if (result.category != null || result.colorHex != null) {
        _showInfo('Rozpoznano automatycznie — sprawdź i popraw w razie potrzeby.');
      }
    } catch (_) {
      // Rozpoznawanie się nie powiodło - formularz zostaje taki, jak był,
      // uzupełniasz ręcznie jak dotychczas.
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    final subcat = _useCustomSubcat ? _customSubcatCtrl.text.trim() : (_subcategory ?? '');
    final isEditing = widget.existingItem != null;

    if (name.isEmpty) {
      _showError('Podaj nazwę ubrania.');
      return;
    }
    if (price == null || price < 0) {
      _showError('Podaj poprawną cenę.');
      return;
    }
    if (_useCustomSubcat && subcat.isEmpty) {
      _showError('Wpisz własną podkategorię.');
      return;
    }
    // Przy dodawaniu nowego ubrania zdjęcie jest wymagane. Przy edycji
    // istniejące ubranie już je ma - nowe jest opcjonalne (zmieniasz tylko,
    // jeśli chcesz).
    if (_photoFile == null && !isEditing) {
      _showError('Dodaj zdjęcie ubrania — jest wymagane.');
      return;
    }

    setState(() => _saving = true);
    final wardrobe = context.read<WardrobeProvider>();
    // "Ile razy już noszone" ma sens tylko dla ubrań, które nie są nowe -
    // dla "Nowe" zawsze startujemy od zera, niezależnie od tego, co zostało
    // wpisane w polu (gdyby ktoś zapomniał go wyczyścić po zmianie wyboru).
    final wearsInput = int.tryParse(_initialWearsCtrl.text.trim());
    final effectiveWears = (_ownershipAge != null && _ownershipAge != 'Nowe') ? wearsInput : null;

    if (isEditing) {
      await wardrobe.updateItem(
        id: widget.existingItem!.id,
        name: name,
        category: _category,
        subcategory: subcat,
        colorHex: _colorHex,
        price: price,
        newPhotoFile: _photoFile,
        seasons: _selectedSeasons.toList(),
        ownershipAge: _ownershipAge,
        wears: effectiveWears ?? (_ownershipAge == 'Nowe' ? 0 : null),
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      final added = await wardrobe.addItem(
        name: name,
        category: _category,
        subcategory: subcat,
        colorHex: _colorHex,
        price: price,
        photoFile: _photoFile!,
        seasons: _selectedSeasons.toList(),
        ownershipAge: _ownershipAge,
        initialWears: effectiveWears,
      );
      if (!mounted) return;
      if (added) {
        Navigator.of(context).pop();
      } else {
        setState(() => _saving = false);
        _showError(
          'Osiągnęłaś limit ${WardrobeProvider.freeItemLimit} ubrań w darmowej wersji. '
          'Przejdź na Premium, żeby dodawać więcej.',
        );
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.ink),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subcats = _category.defaultSubcategories;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(widget.existingItem != null ? 'Edytuj ubranie' : 'Dodaj ubranie',
                style: displayFont(fontSize: 20)),
            if (widget.existingItem == null && context.watch<WardrobeProvider>().hasReachedFreeLimit) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Osiągnęłaś limit ${WardrobeProvider.freeItemLimit} ubrań w darmowej wersji.',
                        style: const TextStyle(fontSize: 12, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            const Text('Zdjęcie', style: _labelStyle),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: _photoFile != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_photoFile!, fit: BoxFit.contain),
                          ),
                          if (_analyzing)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.bg.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Rozpoznaję zdjęcie…',
                                        style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : (widget.existingItem != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClothingPhotoBox(item: widget.existingItem!, height: 140, borderRadius: 8),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Dotknij, żeby zmienić',
                                      style: TextStyle(fontSize: 10, color: Colors.white)),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: AppColors.inkSoft),
                                SizedBox(height: 6),
                                Text('Dodaj zdjęcie', style: TextStyle(color: AppColors.inkSoft)),
                              ],
                            ),
                          )),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Nazwa', style: _labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration('np. Sweter wełniany'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Kategoria', style: _labelStyle),
                if (_categoryAutoFilled) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.auto_awesome, size: 11, color: AppColors.champagneGold),
                  const SizedBox(width: 2),
                  Text('wykryto automatycznie',
                      style: TextStyle(fontSize: 10, color: AppColors.champagneGold)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<ClothingCategory>(
              value: _category,
              decoration: _inputDecoration(null),
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.iconData, size: 16, color: AppColors.inkSoft),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (c) {
                if (c == null) return;
                setState(() {
                  _category = c;
                  _subcategory = c.defaultSubcategories.first;
                  _useCustomSubcat = false;
                  _categoryAutoFilled = false;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text('Podkategoria', style: _labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _useCustomSubcat ? '__custom__' : _subcategory,
              decoration: _inputDecoration(null),
              items: [
                ...subcats.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                const DropdownMenuItem(value: '__custom__', child: Text('+ Własna…')),
              ],
              onChanged: (v) {
                setState(() {
                  if (v == '__custom__') {
                    _useCustomSubcat = true;
                  } else {
                    _useCustomSubcat = false;
                    _subcategory = v;
                  }
                });
              },
            ),
            if (_useCustomSubcat) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _customSubcatCtrl,
                decoration: _inputDecoration('np. Kardigan'),
              ),
            ],
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Kolor', style: _labelStyle),
                if (_colorAutoFilled) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.auto_awesome, size: 11, color: AppColors.champagneGold),
                  const SizedBox(width: 2),
                  Text('wykryto automatycznie',
                      style: TextStyle(fontSize: 10, color: AppColors.champagneGold)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            ColorPickerGrid(
              selectedHex: _colorHex,
              onChanged: (hex) => setState(() {
                _colorHex = hex;
                _colorAutoFilled = false;
              }),
            ),
            const SizedBox(height: 16),

            const Text('Cena (zł)', style: _labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('0.00'),
            ),
            const SizedBox(height: 18),

            const Text('Sezon', style: _labelStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kSeasons.map((season) {
                final selected = _selectedSeasons.contains(season);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedSeasons.remove(season);
                    } else {
                      _selectedSeasons.add(season);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(Icons.check, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(season,
                            style: TextStyle(
                              fontSize: 13,
                              color: selected ? Colors.white : AppColors.ink,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            const Text('Od kiedy masz to ubranie?', style: _labelStyle),
            const SizedBox(height: 4),
            const Text(
              'Nie znamy dokładnej daty zakupu - przybliżenie wystarczy.',
              style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kOwnershipAgeOptions.map((option) {
                final selected = _ownershipAge == option;
                return GestureDetector(
                  onTap: () => setState(() {
                    _ownershipAge = selected ? null : option;
                    if (_ownershipAge == 'Nowe') _initialWearsCtrl.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: selected ? AppColors.ink : AppColors.line),
                    ),
                    child: Text(option,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? AppColors.paper : AppColors.ink,
                        )),
                  ),
                );
              }).toList(),
            ),

            // Pole widoczne tylko wtedy, gdy ubranie NIE jest nowe - dla
            // nowego zawsze zaczynamy liczenie noszeń od zera.
            if (_ownershipAge != null && _ownershipAge != 'Nowe') ...[
              const SizedBox(height: 16),
              const Text('Ile razy nosiłaś to do tej pory?', style: _labelStyle),
              const SizedBox(height: 4),
              const Text(
                'Appka nie znała tego ubrania wcześniej - podaj przybliżoną liczbę, '
                'żeby koszt za noszenie był realny, nie zaczynał się od zera.',
                style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _initialWearsCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('np. 12'),
              ),
            ],
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.paper,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paper))
                    : Text(widget.existingItem != null ? 'Zapisz zmiany' : 'Dodaj do szafy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      );
}

const _labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.inkSoft,
  letterSpacing: 0.4,
);
