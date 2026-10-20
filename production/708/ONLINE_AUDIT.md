# Online-Bestand und Integration 708

Geprüft wurden der gesicherte vollständige 707-Quellstand sowie die verfügbaren GitHub-Bäume von Broosskyy/Realm-Alliance (main 1b5080edca8514b974128ef5f7e5c238d5b2082a und feature/work-6-7-1-hero-art-direction 3ca48b45a3b7e58b1883c5d31905cffd1198129b).

In diesen Ständen gibt es `src/online/foundation.ts` in der älteren React-Vorlage. Accounts, Familien und Ranglisten dort basieren auf Browser-localStorage einschließlich generierter Arena-/Ranglistengegner. Der ausgelieferte Godot-Spielpfad enthielt diese Community-Oberflächen nicht. Ein fertiggestelltes öffentliches Backend oder vollständige Meilensteine 7.1–7.5 konnten in den geprüften Quellen nicht nachgewiesen werden.

708 fügt deshalb im tatsächlichen Godot-Spiel den sichtbaren Gemeinschaftsbereich und einen eigenen SQLite-/HTTP-Dienst hinzu. Konten, gemeinsame Familienmitglieder, PvP-Wertung, Raid-HP, Online-Titel und Sicherungen werden über diesen Dienst geteilt. Ohne Dienst werden keine fremden Spieler vorgetäuscht. Lokale Titel bleiben verfügbar. Der öffentliche Betrieb dieses neuen Dienstes ist noch nicht eingerichtet.

Der verbundene fremde Supabase-Bestand wurde nicht verändert. Kein öffentlicher Deploy und kein GitHub-Push.
