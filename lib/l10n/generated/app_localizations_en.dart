// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Szafnik';

  @override
  String get navHome => 'Home';

  @override
  String get navWardrobe => 'Wardrobe';

  @override
  String get navOutfits => 'Outfits';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navProfile => 'Profile';

  @override
  String greeting(String name) {
    return 'Good morning, $name';
  }

  @override
  String get greetingNoName => 'Good morning';

  @override
  String get todayLabel => 'TODAY';

  @override
  String get todayNoOutfit => 'You don\'t have an outfit planned yet';

  @override
  String get todayTapToCreate => 'Tap to create one';

  @override
  String get tipLabel => 'TIP';

  @override
  String get createOutfit => 'Create outfit';

  @override
  String get wardrobeEmptyTitle => 'Your wardrobe is waiting';

  @override
  String get wardrobeEmptySubtitle =>
      'Add your first items and start creating outfits you\'ll love.';

  @override
  String get addManually => 'Add manually';

  @override
  String get searchWardrobe => 'Search your wardrobe';
}
