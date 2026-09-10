from pathlib import Path
import json,re,sys
r=Path(__file__).resolve().parents[1]
errors=[]
def req(cond,msg):
    if not cond: errors.append(msg)
b=json.loads((r/'data/build_manifest_v1_23.json').read_text())
ui=json.loads((r/'data/ui_interface_contract_v1_23.json').read_text())
meta=json.loads((r/'data/master_v1_8_runtime_contract_v1_23.json').read_text())
settings=(r/'SettingsService.gd').read_text(); main=(r/'MainGame.gd').read_text(); flags=(r/'FeatureFlags.gd').read_text(); scene=(r/'MainGame.tscn').read_text()
req(b['source_version']=='V1.23' and b['build_number']==33,'build contract')
req(b['master_version']=='1.8','master version')
req(b['save_lifecycle']['schema_version']==20 and b['save_lifecycle']['preserved'],'save lifecycle')
req(ui['primary_navigation']==['tap','spin','build'],'primary nav')
for k in ['screen_shake_enabled','language_code','toggle_screen_shake','cycle_language']:
    req(k in settings,'settings '+k)
for k in ['ScreenShakeToggleP0','LanguageToggleP0']:
    req(k in scene and k in main,'scene/main '+k)
for e in ['spin_request','spin_result','spin_empty']:
    req(e in main,'analytics '+e)
for k in ['SHOW_DICE := false','SHOW_PUZZLE := false','SHOW_REALM_JOURNEY := false','SHOW_EVENTS := false','SHOW_RANKINGS := false','SHOW_REALM_CHEST := false']:
    req(k in flags,'flag '+k)
req(meta['core_visibility']==['tap','spin','build'],'core visibility')
if errors:
    print('V1.23 VALIDATION FAIL')
    [print('-',x) for x in errors]
    sys.exit(1)
print('V1.23 SPIN + UI FOUNDATION: PASS')
