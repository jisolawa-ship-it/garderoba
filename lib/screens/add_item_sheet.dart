import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/color_picker_grid.dart';

Future<void> showAddItemSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => const _AddItemSheet(),
  );
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _customSubcatCtrl = TextEditingController();

  ClothingCategory _category = ClothingCategory.top;
  String? _subcategory;
  bool _useCustomSubcat = false;
  String _colorHex = kClothingColors.first.hex;
  File? _photoFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _subcategory = _category.defaultSubcategories.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _customSubcatCtrl.dispose();
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
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    final subcat = _useCustomSubcat ? _customSubcatCtrl.text.trim() : (_subcategory ?? '');

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
    if (_photoFile == null) {
      _showError('Dodaj zdjęcie ubrania — jest wymagane.');
      return;
    }

    setState(() => _saving = true);
    await context.read<WardrobeProvider>().addItem(
          name: name,
          category: _category,
          subcategory: subcat,
          colorHex: _colorHex,
          price: price,
          photoFile: _photoFile!,
        );
    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            Text('Dodaj ubranie', style: displayFont(fontSize: 20)),
            const SizedBox(height: 16),

            const Text('Zdjęcie *', style: _labelStyle),
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
                child: _photoFile == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppColors.inkSoft),
                            SizedBox(height: 6),
                            Text('Dodaj zdjęcie', style: TextStyle(color: AppColors.inkSoft)),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_photoFile!, fit: BoxFit.contain),
                      ),
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

            const Text('Kategoria', style: _labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<ClothingCategory>(
              value: _category,
              decoration: _inputDecoration(null),
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text('${c.icon} ${c.label}')))
                  .toList(),
              onChanged: (c) {
                if (c == null) return;
                setState(() {
                  _category = c;
                  _subcategory = c.defaultSubcategories.first;
                  _useCustomSubcat = false;
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

            const Text('Kolor', style: _labelStyle),
            const SizedBox(height: 6),
            ColorPickerGrid(
              selectedHex: _colorHex,
              onChanged: (hex) => setState(() => _colorHex = hex),
            ),
            const SizedBox(height: 16),

            const Text('Cena (zł)', style: _labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('0.00'),
            ),
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
                    : const Text('Dodaj do szafy'),
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
