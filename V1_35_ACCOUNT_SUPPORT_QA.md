# V1.35 Account / Profile / Cloud / Support QA

1. Splash → Bootstrap → Welcome remains the boot path.
2. SPIEL STARTEN is dominant; Guest/Login/Register remain secondary.
3. Guest mode enters MainGame without online authentication.
4. Register rejects names shorter than 3 or longer than 16 characters.
5. Register rejects passwords shorter than 6 characters or mismatched confirmation.
6. Password is never written to AccountState or SaveGame.
7. Consent is required before local profile creation.
8. BootFlow never writes PlayerData save before MainGame safely loads the existing save.
9. Existing saves without `account_state` remain backward compatible.
10. Account panel shows Guest/Local profile state and current account level.
11. Guest→Account UX clearly states that secure linking needs the server backend.
12. Cloud status never claims that synchronization occurred.
13. Support panel exposes Help/Privacy/Terms/Imprint release slots without invented URLs.
14. HOME / SPIN / DORF remain unchanged.
15. New Account art is placeholder/integration art only.
16. MainGame scene syntax must not contain concatenated `[node` tokens.
