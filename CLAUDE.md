# Szafnik — kontekst projektu

Szafnik to appka Flutter do zarządzania garderobą: katalog ubrań, tworzenie
stylizacji (w tym Przymierzalnia na manekinie), planowanie w kalendarzu
tygodniowym i analiza opłacalności zakupów. Część większego ekosystemu
**Elory** (wcześniejsze nazwy: Garderoba, Elora), budowana dla jednej osoby
(Product Owner: Joanna, nie programuje).

**Stos technologiczny (zweryfikowany w kodzie, nie tylko w dokumentacji):**
- **Flutter / Dart** — appka na Androida (`applicationId`/`namespace`:
  `com.elory.szafnik`, kanał publikacji: Google Play) i iOS (na razie tylko
  przez AltStore, dla testerki).
- **Drift** (`pubspec.yaml`: `drift`, `drift_dev`, `sqlite3_flutter_libs`) —
  lokalna baza SQLite, **jedyne źródło prawdy dla UI**. Schemat:
  `lib/data/local_database.dart` (+ wygenerowany `local_database.g.dart`),
  dostęp przez `lib/data/wardrobe_local_store.dart` (`WardrobeLocalStore`).
- **Firebase** — Firestore (sync/backup w tle, `CloudSyncService`),
  Storage (zdjęcia), Auth + Google Sign-In (logowanie).
- **Google ML Kit** (`google_mlkit_image_labeling`) — lokalne, offline
  rozpoznawanie kategorii/koloru ubrania ze zdjęcia
  (`lib/services/photo_analysis_service.dart`). Bez zewnętrznego, płatnego
  AI (Claude/GPT) w żadnej funkcji rdzeniowej appki — świadoma decyzja
  kosztowa.
- **flutter_localizations / intl** — infrastruktura tłumaczeń gotowa
  (`lib/l10n/`), ale `locale` jest dziś na sztywno ustawiony na `pl` w
  `main.dart` — appka realnie działa tylko po polsku, przełącznik języka to
  osobny, jeszcze niezrobiony krok.
- **Codemagic** — appka jest budowana z gałęzi **`main`** (`codemagic.yaml`).

---

## Zasady, których zawsze przestrzegam w tym projekcie

1. **Offline-first — to już zaimplementowane, nie tylko plan.** Każdy ekran
   czyta/pisze wyłącznie przez `WardrobeProvider` → `WardrobeLocalStore`
   (Drift) — nigdy bezpośrednio przez `CloudSyncService`/Firestore. Zapis
   dzieje się od razu lokalnie i natychmiast aktualizuje UI; synchronizacja
   z chmurą (`_reconcileWithCloud` w `wardrobe_provider.dart`) jest
   asynchroniczna, w tle, nigdy nie blokuje interakcji. Każdy rekord ma flagę
   `dirty` (niewysłana zmiana) — appka **najpierw wypycha lokalne zmiany do
   chmury, dopiero potem** ściąga to, co nowsze z chmury, i nigdy nie
   nadpisuje rekordu, który ma jeszcze niewysłaną lokalną zmianę. Usuwanie =
   tombstone (soft delete) do czasu potwierdzenia synchronizacji, nie
   natychmiastowy hard delete. Jeśli dodajesz nowe pole/encję do modelu
   danych, przechodzi ono przez ten sam wzorzec (Drift + `dirty` +
   `WardrobeLocalStore`), nie omija lokalnej bazy.

2. **Human in Control.** Żadna destrukcyjna akcja (usunięcie ubrania/
   stylizacji, nadpisanie już zaplanowanego dnia w kalendarzu) nie dzieje
   się bez wyraźnego, jawnego potwierdzenia użytkowniczki — dialog
   potwierdzający musi wystąpić **przed** wywołaniem metody providera (np.
   `planOutfit` w `WardrobeProvider` samo w sobie nadpisuje bez pytania —
   pytanie o potwierdzenie to obowiązek warstwy UI, która ją wywołuje).
   Dotyczy to też ML Kit — appka nigdy nie zapisuje rozpoznanych danych bez
   zatwierdzenia, nawet jeśli rozpoznawanie się myli.

3. **Brak premature ecosystem architecture.** Nie buduj wspólnej
   infrastruktury dla całego ekosystemu Elory "na zapas". Wspólne konto
   Google i docelowo wspólny język projektowy — tak, ale osobna
   warstwa/pakiet/serwis współdzielony z innymi appkami Elory (np. Domownik)
   powstaje dopiero wtedy, gdy jest do tego konkretny, aktualny powód — nie
   wcześniej "bo się przyda".

4. **Design system — zawsze przez stałe, nigdy na sztywno.** `lib/theme.dart`
   definiuje `AppColors` (paleta: kremowy beż + pudrowy róż jako `primary`;
   `wine` **wyłącznie** do akcji niebezpiecznych — usuwanie, błędy,
   wylogowanie, nigdy do zaznaczania/pozytywnych akcji) i `AppRadius`
   (`pill` = 999, `card` = 16, `hero` = 26). `GlassCard`
   (`lib/widgets/glass_card.dart`, z wariantem `cheap: true` dla ekranów z
   dużą liczbą kart naraz) i `EmptyStateCard`
   (`lib/widgets/empty_state_card.dart`, z wariantem `compact`) to
   podstawowe, współdzielone komponenty. Nowy kod zawsze korzysta z tych
   stałych/komponentów — nigdy nie wpisuj hex koloru ani promienia
   zaokrąglenia na sztywno w widgecie. Brakującej stałej — dodaj ją do
   `theme.dart`, nie hardkoduj lokalnie.

5. **Brak kosztownego AI bez wyraźnej decyzji.** Sugestie stylizacji i
   dopasowanie kolorystyczne (`lib/services/suggestion_engine.dart`) działają
   na regułach punktowych, nie na zewnętrznym modelu AI. Prawdziwe AI
   (analiza zdjęć w chmurze, generowanie stylizacji) jest świadomie odłożone
   na v2.5+ i ma być pozycjonowane jako funkcja premium — nie dodawaj
   wywołań do płatnych API AI do funkcji rdzeniowych bez wyraźnej zgody
   Joanny.

---

## Struktura folderów (`lib/`)

- **`lib/screens/`** — pełne ekrany. `splash_door_screen.dart` (animacja
  startowa, "drzwi szafy") → `home_screen.dart` (shell: `IndexedStack` +
  dolny pasek nawigacji z centralnym FAB „+", kontrolowany przez
  `NavTabController`) z pięcioma zakładkami: `dashboard_screen.dart` (Home —
  karta "Dziś" z kalendarza, szybkie akcje, insighty), `wardrobe_screen.dart`
  (Garderoba), `outfits_screen.dart` (Stylizacje), `calendar_screen.dart`
  (Kalendarz — bez ikony w pasku, otwierany programowo np. z karty "Dziś"),
  `account_screen.dart` (Profil). Ekrany otwierane "nad" appką:
  `item_detail_screen.dart`, `fitting_room_screen.dart` (Przymierzalnia —
  manekin, przeciąganie/obrót/skalowanie, zapis layoutu przy stylizacji),
  `add_item_sheet.dart` (dodawanie ręczne), `bulk_add_screen.dart` (dodawanie
  grupowe, ML Kit).
- **`lib/models/`** — `clothing_item.dart` (`ClothingItem`), `outfit.dart`
  (`Outfit`, z opcjonalnym zapisanym layoutem z Przymierzalni),
  `calendar_entry.dart` (`CalendarEntry` — osobny obiekt data+stylizacja, nie
  pole "data" na `Outfit`, bo ta sama stylizacja może być zaplanowana na
  wiele dni).
- **`lib/state/`** — `wardrobe_provider.dart` (`WardrobeProvider`: jedyne
  źródło prawdy dla UI, offline-first + sync, limit darmowej wersji 50
  ubrań przez `hasReachedFreeLimit`/`isPremium`), `nav_controller.dart`
  (`NavTabController` + stałe indeksów zakładek `NavTabs`).
- **`lib/data/`** — warstwa Drift: `local_database.dart` (schemat),
  `wardrobe_local_store.dart` (`WardrobeLocalStore` — CRUD + `dirty`/tombstone,
  migracja z legacy `SharedPreferences`).
- **`lib/widgets/`** — komponenty wielokrotnego użytku, w tym design-systemowe
  `glass_card.dart`, `empty_state_card.dart`, oraz `clothing_photo_box.dart`,
  `clothing_tag_card.dart`, `clothing_sticker.dart`, `color_picker_grid.dart`,
  `outfit_preview_dialog.dart`, `outfit_collage.dart`, `suggestion_card.dart`,
  `mannequin_painter.dart` (rysowanie manekina w Przymierzalni),
  `barcode_strip.dart` (dekoracyjny kod kreskowy na metce).
- **`lib/services/`** — `cloud_sync_service.dart` (Firestore/Storage sync),
  `auth_service.dart` (logowanie Google), `suggestion_engine.dart` (silnik
  dopasowania kolorystycznego, bez AI), `photo_analysis_service.dart` (ML Kit
  + analiza koloru), `storage_service.dart` (dziś: **tylko pliki zdjęć** na
  dysku — dane przeniosły się do Drift).
- **`lib/theme.dart`** — design system appki (patrz zasada 4).

---

## Android package i Firebase

`applicationId`/`namespace`: `com.elory.szafnik` (zmienione z
`com.example.aplikacja`). Firebase (projekt `psjoanna-e55aa`) ma
zarejestrowane **obie** appki Android w `android/app/google-services.json`
— starą (`com.example.aplikacja`) i nową (`com.elory.szafnik`), obie z tym
samym SHA-1 certyfikatu podpisującego, więc logowanie Google działa dla obu.
`lib/firebase_options.dart` (sekcja `android`) wskazuje na nową appkę.
