import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../services/photo_analysis_service.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/color_picker_grid.dart';
import '../widgets/glass_card.dart';

class _DraftItem {
  final File photo;
  ClothingCategory category;
  String colorHex;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  bool analyzing;

  /// Osobno dla kategorii i osobno dla koloru - appka potrafi rozpoznać
  /// jedno bez drugiego, a wspólna flaga kazała jej twierdzić, że rozpoznała
  /// oba, nawet gdy kategoria była tylko wartością domyślną.
  bool categoryAutoFilled = false;
  bool colorAutoFilled = false;

  _DraftItem({
    required this.photo,
    this.category = ClothingCategory.top,
    this.colorHex = '#8C8C88',
    this.analyzing = true,
  })  : nameCtrl = TextEditingController(),
        priceCtrl = TextEditingController();

  String get subcategory => category.defaultSubcategories.first;
}

/// Dodawanie kilku ubrań naraz - wybierasz zdjęcia, appka rozpoznaje
/// kategorię i kolor każdego z osobna (lokalnie, bez AI w chmurze - ten sam
/// mechanizm co przy dodawaniu pojedynczego ubrania), a Ty tylko sprawdzasz
/// i uzupełniasz nazwę oraz cenę przed zatwierdzeniem. Nic nie zapisuje się
/// do szafy, dopóki nie klikniesz "Dodaj wszystkie".
class BulkAddScreen extends StatefulWidget {
  const BulkAddScreen({super.key});

  @override
  State<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends State<BulkAddScreen> {
  static const int _maxPhotosPerBatch = 25;

  final _photoAnalysis = PhotoAnalysisService();
  final List<_DraftItem> _drafts = [];
  bool _picking = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickPhotos());
  }

  @override
  void dispose() {
    _photoAnalysis.dispose();
    for (final d in _drafts) {
      d.nameCtrl.dispose();
      d.priceCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotosPerBatch - _drafts.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masz już maksymalną liczbę zdjęć w tej paczce (25). Zapisz je, a potem dodaj kolejne.',
          ),
        ),
      );
      return;
    }

    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(maxWidth: 1000, imageQuality: 80);
      if (picked.isEmpty) {
        if (mounted && _drafts.isEmpty) Navigator.of(context).pop();
        return;
      }

      final toAdd = picked.take(remaining).toList();
      final skipped = picked.length - toAdd.length;
      final newDrafts = toAdd.map((p) => _DraftItem(photo: File(p.path))).toList();
      setState(() => _drafts.addAll(newDrafts));
      for (final draft in newDrafts) {
        _analyzeDraft(draft);
      }

      if (skipped > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Można dodać maksymalnie $_maxPhotosPerBatch zdjęć naraz — pominięto $skipped. '
              'Zapisz tę paczkę, a potem dodaj kolejną.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _analyzeDraft(_DraftItem draft) async {
    try {
      final result = await _photoAnalysis.analyze(draft.photo);
      if (!mounted) return;
      setState(() {
        if (result.category != null) draft.category = result.category!;
        if (result.colorHex != null) draft.colorHex = result.colorHex!;
        draft.categoryAutoFilled = result.category != null;
        draft.colorAutoFilled = result.colorHex != null;
        draft.analyzing = false;
      });
    } catch (_) {
      if (mounted) setState(() => draft.analyzing = false);
    }
  }

  void _removeDraft(_DraftItem draft) {
    setState(() => _drafts.remove(draft));
    draft.nameCtrl.dispose();
    draft.priceCtrl.dispose();
  }

  Future<void> _saveAll() async {
    final wardrobe = context.read<WardrobeProvider>();

    setState(() => _saving = true);
    int incomplete = 0;
    int added = 0;
    int blockedByLimit = 0;
    for (final d in _drafts) {
      if (wardrobe.hasReachedFreeLimit) {
        blockedByLimit++;
        continue;
      }

      final priceText = d.priceCtrl.text.trim().replaceAll(',', '.');
      final price = priceText.isEmpty ? null : double.tryParse(priceText);
      final name = d.nameCtrl.text.trim();
      if (name.isEmpty || price == null) incomplete++;

      final ok = await wardrobe.addItem(
        name: name,
        category: d.category,
        subcategory: d.subcategory,
        colorHex: d.colorHex,
        price: price,
        photoFile: d.photo,
      );
      if (ok) {
        added++;
      } else {
        blockedByLimit++;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    final messages = <String>[];
    if (added > 0) {
      messages.add('Dodano $added ${added == 1 ? "ubranie" : "ubrań"} do szafy.');
    }
    if (incomplete > 0) {
      messages.add('$incomplete ${incomplete == 1 ? "wymaga" : "wymagają"} uzupełnienia nazwy/ceny w Garderobie.');
    }
    if (blockedByLimit > 0) {
      messages.add(
        '$blockedByLimit ${blockedByLimit == 1 ? "zdjęcie nie zmieściło" : "zdjęć nie zmieściło"} się w limicie '
        '${WardrobeProvider.freeItemLimit} ubrań darmowej wersji — przejdź na Premium, żeby dodać więcej.',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messages.isEmpty ? 'Nic nie dodano.' : messages.join(' '),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atLimit = _drafts.length >= _maxPhotosPerBatch;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text(
          _drafts.isEmpty
              ? 'Dodaj grupowo'
              : 'Dodaj grupowo (${_drafts.length}/$_maxPhotosPerBatch)',
          style: displayFont(fontSize: 20),
        ),
        actions: [
          if (_drafts.isNotEmpty)
            IconButton(
              tooltip: atLimit ? 'Osiągnięto limit 25 zdjęć' : 'Dodaj więcej zdjęć',
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: (_picking || atLimit) ? null : _pickPhotos,
            ),
        ],
      ),
      body: _drafts.isEmpty
          ? Center(
              child: _picking
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : const Text('Nie wybrano żadnych zdjęć.', style: TextStyle(color: AppColors.inkSoft)),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              itemCount: _drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _draftCard(_drafts[i]),
            ),
      bottomNavigationBar: _drafts.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Dodaj wszystkie (${_drafts.length})',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
    );
  }

  Widget _draftCard(_DraftItem draft) {
    // cheap: true - w jednej paczce może być do 25 zdjęć naraz.
    return GlassCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(12),
      cheap: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(draft.photo, width: 84, height: 84, fit: BoxFit.cover),
              ),
              if (draft.analyzing)
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: draft.nameCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Nazwa (opcjonalnie)',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<ClothingCategory>(
                        value: draft.category,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(fontSize: 12, color: AppColors.ink),
                        items: ClothingCategory.values
                            .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                            .toList(),
                        onChanged: (c) {
                          if (c == null) return;
                          setState(() {
                            draft.category = c;
                            draft.categoryAutoFilled = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: draft.priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Cena',
                          helperText: 'opcjonalnie',
                          helperStyle: TextStyle(fontSize: 9, color: AppColors.inkSoft),
                          suffixText: 'zł',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickColorFor(draft),
                      child: ClothingColorSwatch(hex: draft.colorHex, size: 24),
                    ),
                    if (!draft.analyzing) ...[
                      const SizedBox(width: 6),
                      if (draft.categoryAutoFilled || draft.colorAutoFilled) ...[
                        const Icon(Icons.auto_awesome, size: 11, color: AppColors.primary),
                        const SizedBox(width: 2),
                      ],
                      // Wprost nazywamy to, czego appka NIE rozpoznała.
                      // Wcześniej każdy wynik wyglądał tak samo pewnie, więc
                      // domyślna kategoria ("Góra") udawała rozpoznaną i
                      // łatwo było ją przeoczyć.
                      Expanded(
                        child: Text(
                          _detectionHint(draft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: draft.categoryAutoFilled
                                ? AppColors.primary
                                : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.inkSoft),
            onPressed: () => _removeDraft(draft),
          ),
        ],
      ),
    );
  }

  /// Krótki, uczciwy opis tego, co appka faktycznie rozpoznała na zdjęciu.
  /// Rozpoznawanie typu ubrania działa lokalnie, na ogólnym modelu Google -
  /// przy zdjęciach ubrań rozłożonych na podłodze potrafi się mylić, więc
  /// zamiast zawsze coś zgadywać, mówi wprost, co warto sprawdzić.
  String _detectionHint(_DraftItem draft) {
    if (draft.categoryAutoFilled && draft.colorAutoFilled) {
      return 'wykryto automatycznie - sprawdź';
    }
    if (draft.colorAutoFilled) return 'wykryto kolor - sprawdź kategorię';
    if (draft.categoryAutoFilled) return 'wykryto kategorię - sprawdź kolor';
    return 'sprawdź kategorię i kolor';
  }

  void _pickColorFor(_DraftItem draft) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      // SafeArea(top: false) - bez tego ostatni rząd kółek renderował się
      // pod systemowym paskiem nawigacji (na telefonach z fizycznymi/
      // ekranowymi przyciskami nawigacji, nie gestami) i nie dało się go
      // dotknąć, mimo że był częściowo widoczny.
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ColorPickerGrid(
            selectedHex: draft.colorHex,
            onChanged: (hex) {
              setState(() {
                draft.colorHex = hex;
                draft.colorAutoFilled = false;
              });
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }
}
