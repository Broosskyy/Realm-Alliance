from pathlib import Path
import json, sys
R=Path(__file__).resolve().parents[1]
errors=[]
def req(c,m):
    if not c: errors.append(m)
b=(R/'BuildInfo.gd').read_text()
req('SOURCE_VERSION := "V1.22"' in b,'source version')
req('MASTER_CONCEPT := "V1.6"' in b,'master version')
req('BUILD_NUMBER := 32' in b,'build number')
contract=(R/'P0RuntimeContract.gd').read_text()
req('const STARTING_SPINS := 10' in contract,'starting spins contract')
player=(R/'PlayerData.gd').read_text()
req('var spins: int = P0RuntimeContract.STARTING_SPINS' in player,'fresh player spins')
wheel=json.loads((R/'data/wheel_p0_v1_6.json').read_text())
weights=[x['weight'] for x in wheel['segments']]
ids=[x['id'] for x in wheel['segments']]
req(weights==[24,18,10,14,8,12,9,5],f'wheel weights {weights}')
req(sum(weights)==100,'wheel weight sum')
req(ids==['gold_small','gold_medium','gold_large','shield','attack','bonus_spins','puzzle_bonus','jackpot'],f'wheel ids {ids}')
ws=(R/'WheelSystem.gd').read_text()
req('wheel_p0_v1_6.json' in ws,'wheel runtime config')
feature=json.loads((R/'data/master_v1_6_runtime_contract_v1_22.json').read_text())
req(feature['bonus_active_pillar']['status']=='reserved_not_enabled','puzzle gate')
req(all(x['status']=='preserved_hidden' for x in feature['strategy_pillars']),'strategy gates')
# V1.21 lifecycle must remain intact
save=(R/'SaveGame.gd').read_text()
for needle in ['load_source','save_sequence','last_save_ok','SAVE_VERSION := 20']:
    req(needle in save,'save lifecycle '+needle)
print(json.dumps({'ok':not errors,'errors':errors,'wheel_weights':weights,'starting_spins':10,'save_schema':20},indent=2))
sys.exit(0 if not errors else 1)
