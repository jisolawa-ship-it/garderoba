import 'package:flutter/foundation.dart';

/// Które zakładki odpowiadają którym indeksom w dolnym pasku nawigacji -
/// jedno miejsce, z którego korzystają wszystkie ekrany chcące przełączyć
/// zakładkę (np. karta "Dzisiaj" na Home otwierająca Kalendarz).
class NavTabs {
  static const home = 0;
  static const wardrobe = 1;
  static const outfits = 2;
  static const calendar = 3;
  static const profile = 4;
}

class NavTabController extends ChangeNotifier {
  int _index = NavTabs.home;
  int get index => _index;

  void goTo(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}
