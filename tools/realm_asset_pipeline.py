#!/usr/bin/env python3
"""REALM ALLIANCE V1.60 asset ingestion pipeline.
Run from project root: python tools/realm_asset_pipeline.py
No third-party packages required.
"""
from __future__ import annotations
import hashlib, json, os, re, struct
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets'
OUT=ROOT/'data'/'generated_asset_index_v160.json'
REGISTRY=ROOT/'data'/'production_asset_registry.json'
VALID={'.png','.jpg','.jpeg','.webp','.wav','.ogg','.mp3'}

def png_size(path:Path):
    try:
        with path.open('rb') as f:
            head=f.read(24)
        if head[:8]==b'\x89PNG\r\n\x1a\n':
            return list(struct.unpack('>II',head[16:24]))
    except OSError: pass
    return None

def classify(rel:str):
    q=rel.lower(); cat='other'; sub='general'; state=''; entity=''; source='single'
    if '/monsters/' in q:
        cat='monster'; sub='greenvale' if '/greenvale/' in q else 'monster'
        m=re.search(r'/([mb]\d{3})_([a-z]+)\.',q)
        if m: entity=m.group(1).upper(); state=m.group(2)
    elif '/heroes/' in q: cat='hero'
    elif '/village/' in q or '/v153_village/' in q: cat='village'; sub='building'
    elif '/production/atlases/' in q: cat='atlas'; source='atlas_sheet'
    elif '/production/ui_v4/' in q: cat='ui'; sub=q.split('/production/ui_v4/')[1].split('/')[0]
    elif '/ui/' in q: cat='ui'; sub='legacy_ui'
    elif '/world/' in q: cat='world'; sub='background'
    elif '/fx/' in q: cat='vfx'
    elif '/audio/' in q: cat='audio'
    elif '/battle/' in q: cat='lane_battle'
    elif '/defense/' in q or '/v149_td/' in q: cat='tower_defense'
    elif '/entry/' in q: cat='entry'
    elif '/social/' in q or '/account/' in q: cat='social'
    elif '/spin/' in q or '/wheel/' in q: cat='spin'
    return cat,sub,state,entity,source

def main():
    assets={}; by_hash={}
    for path in sorted(p for p in ASSETS.rglob('*') if p.is_file() and p.suffix.lower() in VALID):
        rel='res://'+path.relative_to(ROOT).as_posix(); raw=path.read_bytes(); sha=hashlib.sha1(raw).hexdigest()
        cat,sub,state,entity,source=classify(rel)
        e={'path':rel,'category':cat,'subcategory':sub,'state':state,'entity':entity,'source_type':source,'sha1':sha,'placeholder':'_placeholder' in rel.lower()}
        size=png_size(path)
        if size: e['size']=size
        assets[rel]=e; by_hash.setdefault(sha,[]).append(rel)
    duplicate_groups=[]; resolved=0
    for sha,paths in by_hash.items():
        if len(paths)<2: continue
        def score(p): return (100 if not assets[p]['placeholder'] else 0)+(20 if '/production/' in p else 0)+(5 if '/states/' in p and '_shield.' not in p else 0)
        canonical=max(paths,key=score); aliases=[p for p in paths if p!=canonical]
        group={'sha1':sha,'paths':paths,'canonical':canonical,'aliases':aliases}; duplicate_groups.append(group)
        assets[canonical]['duplicate_status']='canonical'
        for a in aliases:
            assets[a]['duplicate_status']='exact_alias'; assets[a]['alias_to']=canonical
            if assets[a]['placeholder'] and not assets[canonical]['placeholder']:
                assets[a]['placeholder_resolved_by_alias']=True; resolved+=1
    reg=json.loads(REGISTRY.read_text(encoding='utf-8')) if REGISTRY.exists() else {}
    virtual={}
    for aid,a in reg.get('atlases',{}).items():
        for rid,r in a.get('regions',{}).items():
            key=f'atlas:{aid}/{rid}'
            virtual[key]={'asset':key,'atlas':aid,'region_id':rid,'region':r.get('region',[]),'path':a.get('path',''),'category':'ui_atlas','source_type':'atlas_region'}
    placeholders=sum(1 for e in assets.values() if e['placeholder'])
    out={'version':'1.60','generated':True,'policy':'Exact duplicates are aliases, never auto-deleted. Production/non-placeholder wins canonical selection.','assets':assets,'virtual_assets':virtual,'duplicate_groups':duplicate_groups,'stats':{'files':len(assets),'virtual_regions':len(virtual),'exact_duplicate_groups':len(duplicate_groups),'placeholders':placeholders,'resolved_placeholder_aliases':resolved,'unresolved_placeholder_files':placeholders-resolved}}
    OUT.write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
    print('REALM Asset Pipeline V1.60:',out['stats'])

if __name__=='__main__': main()
