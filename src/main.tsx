import React,{useEffect,useMemo,useState}from"react";
import{createRoot}from"react-dom/client";
import{enemies}from"./data/content";
import{advanceEnemy,applyEnemyHit,applyVictory,loadState,playerDamage,resetSave,revivePlayer,saveState,type GameState}from"./game/state";
import"./styles/app.css";

function App(){
 const[started,setStarted]=useState(false),[state,setState]=useState<GameState>(()=>loadState());
 const[message,setMessage]=useState("Bereit"),[damagePop,setDamagePop]=useState<number|null>(null);
 const[reward,setReward]=useState<{xp:number;gold:number}|null>(null),[flash,setFlash]=useState<"hit"|"attack"|null>(null),[busy,setBusy]=useState(false);
 const enemy=enemies[state.enemyIndex],damage=useMemo(()=>playerDamage(state),[state]);
 useEffect(()=>saveState(state),[state]);
 function strike(){
  if(state.enemyHp<=0||state.playerHp<=0||busy)return;
  setBusy(true);
  setFlash("hit");setDamagePop(damage);navigator.vibrate?.(18);
  window.setTimeout(()=>setFlash(null),180);window.setTimeout(()=>setDamagePop(null),520);
  window.setTimeout(()=>setState(c=>{
   const hit=playerDamage(c),nextHp=Math.max(0,c.enemyHp-hit);
   if(nextHp===0){setBusy(false);setReward({xp:enemies[c.enemyIndex].xp,gold:enemies[c.enemyIndex].gold});setMessage("Sieg");return applyVictory({...c,enemyHp:0,enemyPose:"defeated"});}
   setMessage(`−${hit} · Konter −${enemies[c.enemyIndex].attack}`);setFlash("attack");navigator.vibrate?.([12,25,12]);
   const retaliated=applyEnemyHit({...c,enemyHp:nextHp,enemyPose:"attack"});if(retaliated.playerHp<=0){setMessage("Besiegt");setBusy(false);}return retaliated;
  }),150);
  window.setTimeout(()=>{setFlash(null);setBusy(false);setState(c=>c.enemyHp>0?{...c,enemyPose:"idle"}:c)},440);
 }
 function nextEncounter(){setReward(null);setState(c=>advanceEnemy(c));setMessage("Bereit");setBusy(false);}
 function revive(){setState(c=>revivePlayer(c));setMessage("Bereit");setBusy(false);navigator.vibrate?.(20);}
 function equip(id:string){setState(c=>({...c,equipped:c.inventory.find(i=>i.id===id)??null}));navigator.vibrate?.(12);}
 function reset(){resetSave();setState(loadState());setReward(null);setStarted(false);}
 if(!started)return <main className="splash"><section className="splash__card"><div className="brandmark">RA</div><p className="eyebrow">QUICK PLAY</p><h1>REALM<br/>ALLIANCE</h1><p className="lead">Grünhain wartet.</p><button className="primary" onClick={()=>setStarted(true)}>Spielen</button></section></main>;
 const ehp=Math.max(0,state.enemyHp/enemy.maxHp*100),php=state.playerHp/state.playerMaxHp*100;
 return <main className={`game fx--${flash??"none"}`}>
  <header className="topbar"><button className="back-button" onClick={()=>setStarted(false)}>‹</button><div className="level"><span>GRÜNHAIN</span><strong>Lv. {state.level}</strong></div><div className="currencies"><span>◈ {state.gold}</span><span className="xp-pill"><i style={{width:`${Math.min(100,state.xp/state.xpToNext*100)}%`}}/>{state.xp}/{state.xpToNext} XP</span></div></header>
  <section className="battle">
   <div className="battle-title"><span>BEGEGNUNG {state.enemyIndex+1} · {enemy.tier}</span><h2>{enemy.name}</h2></div>
   <div className="player-hp"><div><span>DU</span><b>{state.playerHp}/{state.playerMaxHp}</b></div><div className="bar"><i style={{width:`${php}%`}}/></div></div>
   <div className="stage">
    <div className="ambient ambient--1"/><div className="ambient ambient--2"/><div className="ground"/>
    <button className={`creature creature--${state.enemyPose}`} onClick={strike} disabled={!state.enemyHp}>
      <span className="horn horn--l"/><span className="horn horn--r"/><span className="head"><i/><i/><b/></span><span className="body"><i/><i/></span><span className="shadow"/>
      {damagePop&&<em className="damage-pop">−{damagePop}</em>}
    </button>
   </div>
   <div className="enemy-hp"><div><span>{enemy.name}</span><b>{state.enemyHp}/{enemy.maxHp}</b></div><div className="bar bar--enemy"><i style={{width:`${ehp}%`}}/></div></div>
  </section>
  <footer className="action-dock">
   {state.playerHp<=0?<div className="defeat-panel"><span>BESIEGT</span><strong>Der Grünhain schlägt zurück.</strong><button className="next" onClick={revive}>NOCHMAL ›</button></div>:state.enemyHp>0?<><div className="combat-note">{message}</div><button className="attack" onClick={strike} disabled={busy}><span>⚔</span><strong>ANGRIFF</strong><small>{damage} SCHADEN</small></button></>:<div className="reward"><span className="reward__title">SIEG</span><div className="reward__values"><b className="xp-reward">+{reward?.xp??enemy.xp}<small> XP</small></b><b className="gold-reward">+{reward?.gold??enemy.gold}<small> GOLD</small></b></div><div className="drop"><i>✦</i><span><small>BEUTE</small><b>{state.inventory.at(-1)?.name??"Beute gesichert"}</b></span></div><button className="next" onClick={nextEncounter}>NÄCHSTER KAMPF ›</button></div>}
   <details className="inventory"><summary><span>✦ AUSRÜSTUNG</span><b>+{state.equipped?.power??0} Power</b></summary><div className="inventory-sheet">{state.inventory.length?state.inventory.map(item=><button key={item.id} className={state.equipped?.id===item.id?"equipped":""} onClick={()=>equip(item.id)}><i>✦</i><span><b>{item.name}</b><small>{item.rarity} · +{item.power}</small></span><em>{state.equipped?.id===item.id?"AKTIV":"ANLEGEN"}</em></button>):<p>Noch keine Beute.</p>}<button className="dev-reset" onClick={reset}>Spielstand zurücksetzen</button></div></details>
  </footer>
 </main>
}
createRoot(document.getElementById("root")!).render(<React.StrictMode><App/></React.StrictMode>);
