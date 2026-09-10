# REALM ALLIANCE – MASTER CONCEPT V0.2

## 1. Produktpositionierung

**Genre:** Portrait Hybrid-Casual Fantasy RPG / Idle Strategy / Clicker  
**Core Promise:** Ein Spieler baut ein kleines Fantasy-Reich auf, besiegt permanent Monster, dreht ein Glücksrad für Aktionen, verbessert Helden und Gebäude und wird regelmäßig in kurze Angriffs- oder Verteidigungssequenzen geschickt.

Das Spiel soll nicht wie sechs getrennte Minispiele wirken. Alle Systeme speisen denselben Progressionskreislauf.

## 2. Core Loop

1. Auf dem Home-/Tap-Screen Monster antippen.
2. Gold, XP und gelegentlich Spins erhalten.
3. Spins am Glücksrad einsetzen.
4. Glücksrad liefert Gold, Schild, Angriff oder Verteidigung.
5. Gold fließt in Dorf- und Tap-/Helden-Upgrades.
6. Dorf-Level und Account-Level öffnen neue Gebäude, Helden, Gebiete und Systeme.
7. Angriff/Verteidigung liefern zusätzliche Belohnungen.
8. Spieler kehrt auf den Tap-Homescreen zurück.

**Session-Ziel:** 30 Sekunden bis 5 Minuten funktioniert ebenso wie längere Sessions.

## 3. Progression

### Account-Level
Account-XP kommt primär aus Boss-Kills, Quests, Angriffen und Verteidigung. Account-Level schaltet Systeme frei.

V0.2 Zielkurve:
- Lv 1: Tap + Glücksrad + Dorf
- Lv 3: tägliche Quests
- Lv 5: erster Held
- Lv 7: Lane-Angriff
- Lv 10: Tower Defense
- Lv 12: zweiter Held
- Lv 15: Events
- Lv 20: Gilden/Clans als spätere Erweiterung

### Monster-Progression
Monster-HP skaliert zunächst mit Faktor 1,22 pro Level. Jeder Boss gibt steigendes Gold. Alle 10 Level kann später ein Boss-Tier mit eigener Optik und besserem Loot erscheinen.

### Tap-/Hero-Progression
Tap-Schaden startet bei 10. Upgrades kosten Gold und erhöhen den Schaden. Später wird Tap Damage in:
- Base Tap
- Hero Damage
- Critical Chance
- Critical Multiplier
- Auto DPS
aufgeteilt.

### Dorf-Progression
Das Dorf ist die wichtigste Gold-Senke. Statt nur eines Rathauses soll es langfristig 6–10 Gebäude geben:
- Rathaus
- Goldmine
- Schmiede
- Heldengilde
- Schildwerkstatt
- Glückstempel
- Verteidigungsturm
- Marktplatz

Jedes Gebäude kann mehrere Level besitzen. Das Rathaus begrenzt die Maximallevel anderer Gebäude.

### Welt-/Chapter-Progression
Mehrere Regionen verhindern visuelle Monotonie:
1. Grünhain
2. Frostmark
3. Aschenlande
4. Kristallküste
5. Schattenreich
6. Himmelsfestung

Jede Region erhält eigene Monster, Dorfdeko und Belohnungstabellen.

## 4. Economy

### Soft Currency – Gold
Quelle: Tap-Kills, Glücksrad, Angriff, Verteidigung, Idle Rewards, Quests.  
Senken: Dorf, Tap Damage, Helden, Gebäude, Crafting.

### Premium Currency – Gems
Quelle: Achievements, seltene Event-Rewards, Payment.  
Nutzung: optionale Convenience, Cosmetics, ausgewählte Shop-Angebote. Keine harte Pflicht für Kernprogression.

### Spins
Spins sind Energie/Aktionswährung des Glücksrads. Quellen:
- Startbestand
- Boss-Drops
- Tagesbonus
- Quests
- Events
- optional Rewarded Ads
- Shop

### Shields
Maximal 3. Sie schützen das Dorf gegen bestimmte Angriffsauswirkungen. Bei vollem Schild wird ein weiterer Schildgewinn in eine Ersatzbelohnung umgewandelt.

## 5. Glücksrad

V0.2 Wahrscheinlichkeiten:
- 40 % Gold
- 30 % Schild
- 15 % Angriff
- 15 % Verteidigung

Langfristig sollte das Rad 8 sichtbare Segmente besitzen. Die sichtbare Segmentstruktur und die serverseitige Reward-Tabelle müssen logisch übereinstimmen.

Keine irreführende Darstellung von Gewinnwahrscheinlichkeiten. Für reale Monetarisierung und zufallsbasierte bezahlte Inhalte sind Plattform-/Jugendschutz-/Rechtsanforderungen gesondert zu prüfen.

## 6. Angriff – Lane Battle

Kurze 45–90-Sekunden-Sequenz:
- 2 Lanes
- Gegnerisches Dorf oben
- eigenes Team unten
- 3–4 Heldenkarten
- Energie/Elixier regeneriert
- Spieler setzt Einheiten
- Ziel: mindestens ein Kerngebäude zerstören

V0.2 noch nicht implementiert; Architektur folgt nach den drei Kernansichten.

## 7. Tower Defense

Kurze PvE-Verteidigung:
- Dorf als Zentrum
- 1–3 feste Pfade
- Helden/Türme greifen automatisch an
- Wellen
- Mini-Boss
- Belohnung nach überstandener Verteidigung

## 8. Idle Layer

Offline Rewards werden später aus Dorfgebäuden und Helden-DPS berechnet. Ziel: Fortschritt auch nach kurzer Abwesenheit, aber aktive Sessions bleiben wertvoller.

## 9. Itemshop

Shop soll klein starten und nicht den Homescreen dominieren.

### Launch-Kategorien
- Starter-Angebot
- Spins
- Gems
- Cosmetics
- Werbung entfernen
- Event-Angebote später

### Beispielprodukte
- Starter Pack: Gold + Spins + Gems
- Spin Pack S/M/L
- Gem Pack S/M/L
- No Ads
- Cosmetic Hero Skin

### Regeln
- Preise kommen niemals hart aus dem UI.
- Store-Produkt-ID ist die Quelle für realen Preis.
- Belohnungen werden datengetrieben konfiguriert.
- Einmalkäufe müssen server-/storeseitig nachvollziehbar sein.
- Keine Client-only Freischaltung für reale Käufe.

## 10. Payment Architecture

### Android
Google Play Billing.

### iOS
Apple StoreKit / In-App Purchase.

### Web
Nur falls eine Web-Version monetarisiert wird: eigener Zahlungsfluss getrennt von nativen Store-Käufen und unter Beachtung der jeweils aktuellen Plattformregeln.

### Sicherheitsprinzip
Client startet Kauf → Store bestätigt → Receipt/Purchase Token → Backend validiert → Backend schreibt Entitlement → Client synchronisiert.

V0.2 enthält nur `PurchaseService.gd` als Mock/Abstraktion. Es findet keine echte Zahlung statt.

## 11. Ads

Optional und erst nach Core-Loop-Validierung:
- Rewarded Ad für 1–3 Spins
- Rewarded Ad für Offline-Reward-Multiplikator
- keine aggressiven Interstitials nach jedem Screen
- No-Ads entfernt nur Werbeunterbrechungen, nicht notwendigerweise freiwillige Rewarded Ads

## 12. Retention

Daily:
- Login Reward
- 3 Tagesquests
- Gratis-Spin
- Boss-Streak

Weekly:
- Wochenquest
- Mini-Event
- Rangliste später

Long-term:
- Regionen
- Helden
- Dorf
- Sammlungen
- Cosmetics
- Seasons später

## 13. Asset Direction

Stil: sauberes 2D-Cartoon-Fantasy, große Silhouetten, wenige kleine Details, mobile Lesbarkeit.

Asset-Priorität:
P0 = für Vertical Slice nötig  
P1 = für Core Loop nötig  
P2 = nach Validierung

## 14. Technische Prinzipien

- Portrait 1080×1920 Referenz.
- UI mit Anchors/Containers.
- Daten/Balance zentral in `GameConfig.gd`.
- Player-State in `PlayerData.gd`.
- Payment hinter `PurchaseService.gd`.
- spätere Save-/Cloud-Schicht getrennt.
- keine Shoppreise oder Balancewerte direkt in Szenen hart codieren.
- neue Systeme möglichst datengetrieben.

## 15. Roadmap

### V0.2 – jetzt
- Mobile Foundation
- Tap Progression
- Account-Level
- Village Progression
- Wheel Outcome Feedback
- Economy Config
- Shop/Payment Architecture
- Asset Masterlist

### V0.3
- echtes 8-Segment-Rad
- erste finale Monster-Art
- erster Background
- echte Village Tiles/Buildings
- SaveGame JSON
- Daily Rewards

### V0.4
- Hero System
- 3 Hero Cards
- Auto DPS
- Equipment light

### V0.5
- Lane Attack Vertical Slice

### V0.6
- Tower Defense Vertical Slice

### V0.7
- Shop UI + Sandbox IAP
- Receipt Validation Backend Skeleton

### V0.8
- LiveOps/Event Config
- Analytics
- Balancing Pass
