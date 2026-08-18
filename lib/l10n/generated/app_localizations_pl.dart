// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Szafnik';

  @override
  String get navHome => 'Home';

  @override
  String get navWardrobe => 'Garderoba';

  @override
  String get navOutfits => 'Stylizacje';

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navProfile => 'Profil';

  @override
  String greeting(String name) {
    return 'Dzień dobry, $name';
  }

  @override
  String get greetingNoName => 'Dzień dobry';

  @override
  String get todayLabel => 'DZISIAJ';

  @override
  String get todayNoOutfit => 'Nie masz jeszcze zaplanowanej stylizacji';

  @override
  String get todayTapToCreate => 'Dotknij, żeby ją stworzyć';

  @override
  String get tipLabel => 'WSKAZÓWKA';

  @override
  String get createOutfit => 'Stwórz stylizację';

  @override
  String get wardrobeEmptyTitle => 'Twoja garderoba czeka';

  @override
  String get wardrobeEmptySubtitle =>
      'Dodaj pierwsze ubrania i zacznij tworzyć stylizacje, które pokochasz.';

  @override
  String get addManually => 'Dodaj ręcznie';

  @override
  String get searchWardrobe => 'Szukaj w garderobie';
}
