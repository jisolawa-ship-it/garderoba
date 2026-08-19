SZAFNIK – WERSJA 1.0 (CORE SPEC)

KONTEKST

Szafnik to aplikacja do zarządzania garderobą i stylizacjami.

Wersja 1.0 to stabilna, prosta baza produktu.
Celem NIE jest stworzenie wszystkiego, tylko solidnego fundamentu.


ZAKRES 1.0

Wchodzą:

- Garderoba (dodawanie ubrań)
- Stylizacje (tworzenie i zapis)
- Dressing Room (układanie stylizacji)
- Kalendarz (planowanie stylizacji)
- Home (podstawowy widok dnia)
- Profil (ustawienia)
- Statystyki

Nie wchodzą:

- płatne AI
- zewnętrzne API AI
- social
- zakupy
- zaawansowane systemy rekomendacji


AI

Wersja 1.0 NIE używa żadnych płatnych funkcji AI.

Dozwolone:
- ML Kit (lokalne rozpoznawanie zdjęć)

Zamiast AI:
- prosta logika lokalna
- brak predykcji
- brak automatycznych sugestii


DANE

- aplikacja działa lokalnie (offline-first)
- Firebase służy do synchronizacji i backupu
- UI nie zależy bezpośrednio od Firebase


UX

- prostota ponad wszystko
- brak skomplikowanych flow
- brak ukrytych funkcji
- użytkownik ma pełną kontrolę


DESIGN

- minimalistyczny
- elegancki
- pudrowy róż + neutralne kolory
- lekkie karty, dużo przestrzeni
KOLORY (PALETA)

TŁO GŁÓWNE:
#FFF7FB  (bardzo jasny pudrowy róż / prawie biały)

KARTY:
#FFFFFF  (czyste, lekkie)

PRIMARY (akcent główny):
#E8B4C7  (pudrowy róż)

PRIMARY HOVER / ACTIVE:
#DFA2B8  (ciemniejszy róż)

SECONDARY:
#F3D6E0  (bardzo delikatny róż)

TEKST GŁÓWNY:
#2E2A2C  (ciemny, ale miękki — nie czarny)

TEKST DRUGORZĘDNY:
#8E858A  (ciepły szary z nutą różu)

BORDER:
#F1E4EA  (bardzo subtelny różowy border)



TYPOGRAFIA

Styl:
- lekki
- elegancki
- modowy

Nagłówki:
- półgrube

Treść:
- regular

Unikamy:
- ciężkich fontów
- „technicznych” krojów


4. KARTY

Styl:
- zaokrąglenie: 16–20px
- brak ciężkich cieni
- bardzo subtelny shadow

Efekt:
- „floating cards”


5. PRZYCISKI

Primary:
- pudrowy róż (#E8B4C7)
- tekst biały

Secondary:
- białe tło
- delikatny border

Ghost:
- tekst w kolorze primary


6. IKONY

Styl:
- cienkie
- eleganckie
- bez wypełnienia

Kolor:
- tekst drugorzędny lub primary



ZASADY

- nie dodajemy nowych funkcji poza zakresem
- nie komplikujemy UI
- nie używamy AI w tle
- każda funkcja musi mieć realną wartość


CEL

Stworzyć stabilną wersję aplikacji,
która działa szybko, prosto i bez kosztów,
i może być rozwijana w przyszłości.

EMPTY STATES

Każdy pusty ekran zawiera:
- ilustrację
- krótki tekst (max 2 linie)
- jedno CTA

Styl:
- minimalistyczny
- modowy
- pudrowy róż

Ton:
- spokojny
- wspierający

Cel:
- pokazać użytkownikowi co zrobić dalej

ANIMACJA STARTOWA

Cel:
stworzyć efekt „wejścia do garderoby”

Opis:
- ekran startowy z minimalistycznymi drzwiami
- drzwi otwierają się na boki
- po animacji pojawia się Home

Czas:
- 400–600 ms

Styl:
- minimalistyczny
- pastelowy róż
- brak realizmu

Zasady:
- tylko przy starcie aplikacji
- brak dźwięku
- brak ciężkich animacji