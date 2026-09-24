import React,{useEffect,useMemo,useState}from"react";
import{createRoot}from"react-dom/client";
import{enemies}from"./data/content";
import{advanceEnemy,applyEnemyHit,applyVictory,loadState,playerDamage,resetSave,revivePlayer,saveState,type GameState}from"./game/state";
import"./styles/app.css";

type FloatFx={id:number;text:string;kind:"damage"|"hurt"|"xp"|"gold"};
function App(){
 const[started,setStarted]=useState(false),[state,setState]=useState<GameState>(()=>loadState());
 const[message,setMessage]=useState("Bereit"),[reward,setReward]=useState<{xp:number;gold:number;item:string}|null>(null);
 const[flash,setFlash]=useState<"hit"|"attack"|"victory"|null>(null),[busy,setBusy]=useState(false),[fx,setFx]=useState<FloatFx[]>([]);
 const enemy=enemies[state.enemyIndex],damage=useMemo(()=>playerDamage(state),[state]);
 useEffect(()=>saveState(state),[state]);
 function float(text:string,kind:FloatFx["kind"]){const id=Date.now()+Math.random();setFx(v=>[...v,{id,text,kind}]);setTimeout(()=>setFx(v=>v.filter(x=>x.id!==id)),850)}
 function strike(){
  if(state.enemyHp<=0||state.playerHp<=0||busy)return;setBusy(true);setFlash("hit");float(`−${damage}`,"damage");navigator.vibrate?.(16);
  setTimeout(()=>setState(c=>{const hit=playerDamage(c),nextHp=Math.max(0,c.enemyHp-hit);
   if(nextHp===0){const e=enemies[c.enemyIndex],item=(c.inventory.find(i=>i.id===["twig-blade","moss-edge","forest-charm"][c.enemyIndex])?.name)||["Astklinge","Moosschneide","Grünhain-Talisman"][c.enemyIndex];setReward({xp:e.xp,gold:e.gold,item});setFlash("victory");setMessage("Sieg");setBusy(false);setTimeout(()=>{float(`+${e.xp} XP`,"xp");float(`+${e.gold}`,"gold")},240);return applyVictory({...c,enemyHp:0,enemyPose:"defeated"})}
   setFlash("attack");setMessage(`Treffer −${hit} · Konter −${enemies[c.enemyIndex].attack}`);setTimeout(()=>float(`−${enemies[c.enemyIndex].attack} HP`,"hurt"),100);navigator.vibrate?.([10,28,14]);return applyEnemyHit({...c,enemyHp:nextHp,enemyPose:"attack"})
  }),130);
  setTimeout(()=>{setFlash(null);setBusy(false);setState(c=>c.enemyHp>0?{...c,enemyPose:"idle"}:c)},480)
 }
 function nextEncounter(){setReward(null);setState(c=>advanceEnemy(c));setMessage("Bereit");setBusy(false);setFlash(null)}
 function revive(){setState(c=>revivePlayer(c));setMessage("Bereit");setBusy(false);setFlash(null);navigator.vibrate?.(20)}
 function equip(id:string){setState(c=>({...c,equipped:c.inventory.find(i=>i.id===id)??null}));navigator.vibrate?.(10)}
 function reset(){resetSave();setState(loadState());setReward(null);setStarted(false)}
 if(!started)return <main className="splash"><section className="splash__card"><div className="brandmark">RA</div><p className="eyebrow">QUICK PLAY</p><h1>REALM<br/>ALLIANCE</h1><p className="lead">Grünhain wartet.</p><button className="primary" onClick={()=>setStarted(true)}>SPIELEN</button></section></main>;
 const ehp=Math.max(0,state.enemyHp/enemy.maxHp*100),php=Math.max(0,state.playerHp/state.playerMaxHp*100),xpp=Math.min(100,state.xp/state.xpToNext*100);
 return <main className={`game fx--${flash??"none"}`}>
  <header className="topbar"><button className="back-button" onClick={()=>setStarted(false)} aria-label="Zurück">‹</button><div className="level"><span>GRÜNHAIN</span><strong>Lv. {state.level}</strong></div><div className="currencies"><span>◈ {state.gold}</span><span className="xp-pill"><i style={{width:`${xpp}%`}}/>{state.xp}/{state.xpToNext} XP</span></div></header>
  <section className="battle">
   <div className="battle-title"><span>BEGEGNUNG {state.enemyIndex+1} · {enemy.tier}</span><h2>{enemy.name}</h2><small>{enemy.subtitle}</small></div>
   <div className="player-hp"><div><span>DU</span><b>{state.playerHp}/{state.playerMaxHp}</b></div><div className="bar"><i style={{width:`${php}%`}}/></div></div>
   <div className="stage" onClick={state.enemyHp>0&&state.playerHp>0?strike:undefined}>
    <div className="forest-layer forest-layer--far"/><div className="forest-layer forest-layer--near"/><div className="ambient ambient--1"/><div className="ambient ambient--2"/><div className="ground"/>
    <div className={`creature creature--${state.enemyPose}`}><span className="horn horn--l"/><span className="horn horn--r"/><span className="head"><i/><i/><b/></span><span className="body"><i/><i/></span><span className="shadow"/></div>
    <div className="fx-layer">{fx.map(x=><em key={x.id} className={`float-fx float-fx--${x.kind}`}>{x.text}</em>)}</div>
    {flash==="hit"&&<div className="slash"><i/><i/></div>}
    {state.enemyHp<=0&&<div className="victory-burst"><i>✦</i><i>✦</i><i>✦</i></div>}
   </div>
   <div className="enemy-hp"><div><span>{enemy.name.toUpperCase()}</span><b>{state.enemyHp}/{enemy.maxHp}</b></div><div className="bar bar--enemy"><i style={{width:`${ehp}%`}}/></div></div>
  </section>
  <footer className="action-dock">
   {state.playerHp<=0?<div className="result result--defeat"><span>BESIEGT</span><strong>Der Grünhain schlägt zurück.</strong><button className="next" onClick={revive}>NOCHMAL ›</button></div>:state.enemyHp>0?<><div className="combat-note">{message}</div><button className="attack" onClick={e=>{e.stopPropagation();strike()}} disabled={busy}><span>⚔</span><strong>ANGRIFF</strong><small>{damage} SCHADEN</small></button></>:<div className="result result--victory"><span className="result__label">SIEG</span><div className="reward-row"><div><small>ERFAHRUNG</small><b>+{reward?.xp??enemy.xp} XP</b></div><div><small>GOLD</small><b>+{reward?.gold??enemy.gold}</b></div></div><div className="loot-card"><i>✦</i><span><small>BEUTE ERHALTEN</small><b>{reward?.item??state.inventory.at(-1)?.name??"Beute"}</b></span></div><button className="next" onClick={nextEncounter}>NÄCHSTER KAMPF ›</button></div>}
   <details className="inventory"><summary><span>✦ AUSRÜSTUNG</span><b>+{state.equipped?.power??0} Power</b></summary><div className="inventory-sheet">{state.inventory.length?state.inventory.map(item=><button key={item.id} className={state.equipped?.id===item.id?"equipped":""} onClick={()=>equip(item.id)}><i>✦</i><span><b>{item.name}</b><small>{item.rarity} · +{item.power} Power</small></span><em>{state.equipped?.id===item.id?"AKTIV":"ANLEGEN"}</em></button>):<p>Noch keine Beute.</p>}<button className="dev-reset" onClick={reset}>Spielstand zurücksetzen</button></div></details>
  </footer>
 </main>
}
createRoot(document.getElementById("root")!).render(<React.StrictMode><App/></React.StrictMode>);
