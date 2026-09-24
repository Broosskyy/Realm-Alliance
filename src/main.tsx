import React,{useEffect,useMemo,useState}from"react";
import{createRoot}from"react-dom/client";
import{enemies}from"./data/content";
import{advanceEnemy,applyEnemyHit,applyVictory,loadState,playerDamage,resetSave,saveState,type GameState}from"./game/state";
import"./styles/app.css";

function App(){
 const[started,setStarted]=useState(false),[state,setState]=useState<GameState>(()=>loadState());
 const[message,setMessage]=useState("Der Grünhain wartet."),[damagePop,setDamagePop]=useState<number|null>(null);
 const enemy=enemies[state.enemyIndex],damage=useMemo(()=>playerDamage(state),[state]);
 useEffect(()=>saveState(state),[state]);
 function strike(){
  if(state.enemyHp<=0)return;
  setDamagePop(damage); setState(c=>({...c,enemyPose:"hit"}));
  window.setTimeout(()=>setDamagePop(null),420);
  window.setTimeout(()=>setState(c=>{
   const hit=playerDamage(c),nextHp=Math.max(0,c.enemyHp-hit);
   if(nextHp===0){setMessage(`${enemies[c.enemyIndex].name} besiegt · Beute gesichert`);return applyVictory({...c,enemyHp:0,enemyPose:"defeated"});}
   setMessage(`${hit} Schaden · Gegner kontert für ${enemies[c.enemyIndex].attack}`);
   return applyEnemyHit({...c,enemyHp:nextHp,enemyPose:"attack"});
  }),120);
  window.setTimeout(()=>setState(c=>c.enemyHp>0?{...c,enemyPose:"idle"}:c),420);
 }
 function nextEncounter(){setState(c=>advanceEnemy(c));setMessage("Ein neuer Gegner tritt aus dem Grün.");}
 function equip(id:string){setState(c=>({...c,equipped:c.inventory.find(i=>i.id===id)??null}));}
 function reset(){resetSave();setState(loadState());setStarted(false);setMessage("Der Grünhain wartet.");}
 if(!started)return <main className="splash"><section className="splash__card"><div className="brandmark">RA</div><p className="eyebrow">WEB FIRST · QUICK PLAY</p><h1>REALM<br/>ALLIANCE</h1><p className="lead">Direkt in den Grünhain. Kein Download.<br/>Kein Pflichtkonto vor dem ersten Kampf.</p><button className="primary" onClick={()=>setStarted(true)}>Spielen</button><span className="save-note">Fortschritt wird auf diesem Gerät gespeichert.</span></section></main>;
 const hp=Math.max(0,state.enemyHp/enemy.maxHp*100),php=state.playerHp/state.playerMaxHp*100;
 return <main className="game">
  <header className="topbar"><div><span className="eyebrow">GRÜNHAIN</span><strong>Level {state.level}</strong></div><div className="currencies"><span>◈ {state.gold}</span><span>{state.xp}/{state.xpToNext} XP</span></div></header>
  <section className="arena">
   <div className="encounter-copy"><span>BEGEGNUNG {state.enemyIndex+1} · {enemy.tier}</span><h2>{enemy.name}</h2><p>{enemy.subtitle}</p></div>
   <div className="combat-hud player-vitals"><div className="hp-row"><span>DEIN LEBEN</span><strong>{state.playerHp}/{state.playerMaxHp}</strong></div><div className="bar bar--player"><div className="bar__fill" style={{width:`${php}%`}}/></div></div>
   <button className={`monster monster--${state.enemyPose}`} onClick={strike} disabled={state.enemyHp<=0} aria-label={`${enemy.name} angreifen`}><span className="monster__ears">◆ ◆</span><span className="monster__face"><i/><i/></span><span className="monster__body">✦</span><span className="monster__shadow"/>{damagePop&&<b className="damage-pop">−{damagePop}</b>}</button>
   <div className="enemy-hud"><div className="hp-row"><span>{enemy.name.toUpperCase()}</span><strong>{state.enemyHp}/{enemy.maxHp}</strong></div><div className="bar"><div className="bar__fill" style={{width:`${hp}%`}}/></div></div>
  </section>
  <section className="controls"><div className="message">{message}</div>
   {state.enemyHp>0?<button className="attack" onClick={strike}><span>ANGRIFF</span><small>{damage} Schaden · Tippen</small></button>:<section className="victory"><span className="eyebrow">SIEG</span><strong>+{enemy.xp} XP · +{enemy.gold} Gold</strong><button className="primary" onClick={nextEncounter}>Weiter</button></section>}
   <section className="loot"><div className="section-heading"><div><span className="eyebrow">AUSRÜSTUNG</span><h3>Gefundene Beute</h3></div><strong>Power +{state.equipped?.power??0}</strong></div>
   {state.inventory.length===0?<p className="empty">Besiege deinen ersten Gegner, um Beute zu erhalten.</p>:<div className="items">{state.inventory.map(item=><button key={item.id} className={`item item--${item.rarity} ${state.equipped?.id===item.id?"item--equipped":""}`} onClick={()=>equip(item.id)}><span className="item__icon">✦</span><span><strong>{item.name}</strong><small>{item.rarity} · +{item.power} Power</small></span><b>{state.equipped?.id===item.id?"Aktiv":"Anlegen"}</b></button>)}</div>}</section>
   <button className="reset" onClick={reset}>Entwicklungsstand zurücksetzen</button>
  </section>
 </main>
}
createRoot(document.getElementById("root")!).render(<React.StrictMode><App/></React.StrictMode>);
