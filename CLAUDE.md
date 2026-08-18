# Szafnik — kontekst projektu

Szafnik to appka Flutter do zarządzania garderobą: katalog ubrań, tworzenie
stylizacji, planowanie w kalendarzu i analiza opłacalności zakupów. Część
większego ekosystemu **Elory** (wcześniejsze nazwy: Garderoba, Elora),
budowana dla jednej osoby (Product Owner: Joanna, nie programuje).

**Stos technologiczny:**
- **Flutter / Dart** — appka na Androida (kanał publikacji: Google Play) i iOS (na razie tylko przez AltStore, dla testerki).
- **Firebase** — Firestore (backup/sync danych), Storage (zdjęcia ubrań), Auth (logowanie Google).
- **Drift** (nakładka na SQLite) — docelowa lokalna baza danych appki, patrz uwaga niżej.
- **Google ML Kit** — lokalne, offline rozpoznawanie kategorii/koloru ubrania ze zdjęcia. Bez zewnętrznego, płatnego AI (Claude/GPT) w żadnej funkcji rdzeniowej appki — to świadoma decyzja kosztowa.
- **Codemagic** — budowanie appki (kompilacja do pliku instalacyjnego) w chmurze.

> ⚠️ **Rozbieżność dokumentacja ↔ kod (stan na dziś):** dokumentacja produktowa
> (`00`–`03`) opisuje częściowo *docelową* architekturę, nie zawsze to, co już
> jest w repo. Sprawdzone w kodzie:
> - Lokalny storage **dziś to `SharedPreferences`** (JSON blob w `StorageService`), **nie Drift** — migracja na Drift to dopiero **Etap 1** planu etapowego, jeszcze nie zrobiony. Nie zakładaj, że pakiet `drift` już jest w `pubspec.yaml` — sprawdź, zanim się na niego powołasz.
> - `lib/theme.dart` dziś zawiera tylko `AppColors` (paleta beż/złoto) + pomocnicze funkcje fontów (`displayFont`, `monoFont`) i listę kolorów ubrań. **`GlassCard`, `AppRadius`, `EmptyStateCard` jeszcze nie istnieją** — to część nowego design systemu (róż/mleczne szkło) z Etapu 2 planu etapowego, do zbudowania.
> - Kalendarz, Przymierzalnia (Dressing Room) i flaga `isPremium` — opisane w dokumentacji jako plan/wizja, **nie znalezione w obecnym kodzie**.
> Zasady niżej to kierunek, którego appka ma trzymać się **od teraz i w kolejnych etapach** — nie opis stanu faktycznego wstecz.

---

## Zasady, których zawsze przestrzegam w tym projekcie

1. **Offline-first.** Appka musi w pełni działać bez internetu. Docelowo: dane
   zapisują się najpierw lokalnie (Drift), appka pokazuje zmianę natychmiast,
   a synchronizacja z Firestore dzieje się asynchronicznie w tle, bez
   blokowania UI. Ekrany nie rozmawiają bezpośrednio z Firestore — jedynym
   źródłem prawdy dla UI jest lokalna baza. Konflikty: lokalna, jeszcze
   niewysłana zmiana zawsze wygrywa, appka nigdy nie nadpisuje cichcem
   czegoś, czego jeszcze nie zdążyła wysłać. Usuwanie = tombstone
   (`deleted: true`) do czasu potwierdzenia synchronizacji, nie natychmiastowy
   hard delete.

2. **Human in Control.** Żadna destrukcyjna akcja (usunięcie ubrania/stylizacji,
   nadpisanie już zaplanowanego dnia w kalendarzu, itp.) nie dzieje się bez
   wyraźnego, jawnego potwierdzenia użytkowniczki. Dotyczy to też
   automatycznego rozpoznawania zdjęć (ML Kit) — appka nigdy nie zapisuje
   rozpoznanych danych bez zatwierdzenia, nawet jeśli rozpoznawanie się myli.

3. **Brak premature ecosystem architecture.** Nie buduj wspólnej
   infrastruktury dla całego ekosystemu Elory "na zapas". Wspólne konto
   Google i docelowo wspólny język projektowy — tak, ale osobna
   warstwa/pakiet/serwis współdzielony z innymi appkami Elory (np. Domownik)
   powstaje dopiero wtedy, gdy jest do tego konkretny, aktualny powód — nie
   wcześniej "bo się przyda".

4. **Design system — zawsze przez stałe, nigdy na sztywno.** Kolory,
   zaokrąglenia i komponenty współdzielone (`AppColors`, docelowo `AppRadius`,
   `GlassCard`, `EmptyStateCard`) są/będą zdefiniowane w `lib/theme.dart`.
   Nowy kod zawsze korzysta z tych stałych — nigdy nie wpisuj wartości
   kolorów (hex) ani rozmiarów zaokrągleń na sztywno w widgetach. Jeśli
   potrzebnej stałej jeszcze nie ma w `theme.dart`, dodaj ją tam, zamiast
   lokalnie hardkodować wartość.

5. **Brak kosztownego AI bez wyraźnej decyzji.** Sugestie stylizacji i
   dopasowanie kolorystyczne działają na regułach (silnik punktowy), nie na
   zewnętrznym modelu AI. Prawdziwe AI (analiza zdjęć w chmurze, generowanie
   stylizacji) jest świadomie odłożone na v2.5+ i ma być pozycjonowane jako
   funkcja premium, nie darmowa — nie dodawaj wywołań do płatnych API AI do
   funkcji rdzeniowych bez wyraźnej zgody Joanny.

---

## Struktura folderów (`lib/`)

- **`lib/screens/`** — pełne ekrany appki. Dziś: `home_screen.dart`,
  `wardrobe_screen.dart` (Garderoba), `outfits_screen.dart` (Stylizacje),
  `summary_screen.dart` (Podsumowanie/statystyki — wg planu ma docelowo zniknąć
  jako osobny ekran i wejść do Home), `account_screen.dart` (Konto/Profil),
  `add_item_sheet.dart` (dodawanie ubrania). Kalendarz i Przymierzalnia
  jeszcze nie istnieją jako pliki — do zbudowania wg roadmapy.
- **`lib/models/`** — modele danych: `clothing_item.dart` (`ClothingItem`,
  kategorie/podkategorie/kolory), `outfit.dart` (`Outfit`). `CalendarEntry`
  jeszcze nie istnieje.
- **`lib/state/`** — zarządzanie stanem przez `provider`. Dziś jeden plik:
  `wardrobe_provider.dart` (`WardrobeProvider`) — trzyma listy ubrań/stylizacji,
  status logowania i synchronizacji.
- **`lib/widgets/`** — komponenty wielokrotnego użytku: `clothing_photo_box.dart`,
  `clothing_tag_card.dart`, `color_picker_grid.dart`, `outfit_preview_dialog.dart`,
  `suggestion_card.dart`, `barcode_strip.dart` (dekoracyjny kod kreskowy na metce).
- **`lib/services/`** — logika niezwiązana z UI: `storage_service.dart`
  (lokalny zapis, dziś `SharedPreferences`), `cloud_sync_service.dart`
  (synchronizacja z Firestore/Storage), `auth_service.dart` (logowanie Google),
  `suggestion_engine.dart` (silnik dopasowania kolorystycznego, bez AI).
- **`lib/theme.dart`** — design system appki (patrz zasada 4).

---

## Android package

`applicationId`/`namespace`: `com.elory.szafnik` (zmienione z
`com.example.aplikacja`). Firebase Android app dla nowego package name musi
być zarejestrowana osobno w projekcie `psjoanna-e55aa` z prawidłowym SHA-1,
inaczej logowanie Google nie zadziała — patrz historia zmian / commit
dotyczący rebrandingu pakietu.
