# V1.51 Hero / Combat Progression QA

Static acceptance:
- Hero Mastery 1–5 for Knight/Archer/Mage.
- MonsterDefeatService signal path feeds Hero Mastery.
- Boss and normal-kill Mastery rules are explicit.
- Mastery 2 specialization for every existing hero.
- No new currency.
- Mastery claims are persisted.
- Hero progression is in SaveGame and global Progression Overview.
- Legacy fabricated ranking rows removed.
- Exactly 8 isolated transparent 768×768 placeholders.
- Save V20 unchanged.

Pending:
- Godot executable/device parser validation.
- Android touch/layout QA.
- Final Recraft hero/equipment/mastery art.
- Future deeper hero abilities/loadouts should be introduced only after device validation of this progression layer.
