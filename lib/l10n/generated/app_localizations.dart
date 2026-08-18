import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// Nazwa aplikacji, widoczna m.in. w nagłówku Home
  ///
  /// In pl, this message translates to:
  /// **'Szafnik'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In pl, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWardrobe.
  ///
  /// In pl, this message translates to:
  /// **'Garderoba'**
  String get navWardrobe;

  /// No description provided for @navOutfits.
  ///
  /// In pl, this message translates to:
  /// **'Stylizacje'**
  String get navOutfits;

  /// No description provided for @navCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get navCalendar;

  /// No description provided for @navProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// Powitanie na Home z imieniem użytkowniczki
  ///
  /// In pl, this message translates to:
  /// **'Dzień dobry, {name}'**
  String greeting(String name);

  /// No description provided for @greetingNoName.
  ///
  /// In pl, this message translates to:
  /// **'Dzień dobry'**
  String get greetingNoName;

  /// No description provided for @todayLabel.
  ///
  /// In pl, this message translates to:
  /// **'DZISIAJ'**
  String get todayLabel;

  /// No description provided for @todayNoOutfit.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze zaplanowanej stylizacji'**
  String get todayNoOutfit;

  /// No description provided for @todayTapToCreate.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij, żeby ją stworzyć'**
  String get todayTapToCreate;

  /// No description provided for @tipLabel.
  ///
  /// In pl, this message translates to:
  /// **'WSKAZÓWKA'**
  String get tipLabel;

  /// No description provided for @createOutfit.
  ///
  /// In pl, this message translates to:
  /// **'Stwórz stylizację'**
  String get createOutfit;

  /// No description provided for @wardrobeEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twoja garderoba czeka'**
  String get wardrobeEmptyTitle;

  /// No description provided for @wardrobeEmptySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwsze ubrania i zacznij tworzyć stylizacje, które pokochasz.'**
  String get wardrobeEmptySubtitle;

  /// No description provided for @addManually.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj ręcznie'**
  String get addManually;

  /// No description provided for @searchWardrobe.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj w garderobie'**
  String get searchWardrobe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
