import { enemies, itemForEnemy, type ItemDefinition } from "../data/content";
export type CombatPose="idle"|"attack"|"hit"|"defeated";
export type GameState={level:number;xp:number;xpToNext:number;gold:number;enemyIndex:number;enemyHp:number;enemyPose:CombatPose;playerHp:number;playerMaxHp:number;equipped:ItemDefinition|null;inventory:ItemDefinition[];victories:number};
const SAVE_KEY="realm-alliance-v2-save";
export function createInitialState():GameState{return{level:1,xp:0,xpToNext:40,gold:0,enemyIndex:0,enemyHp:enemies[0].maxHp,enemyPose:"idle",playerHp:100,playerMaxHp:100,equipped:null,inventory:[],victories:0}}
export function loadState():GameState{const raw=localStorage.getItem(SAVE_KEY);if(!raw)return createInitialState();try{const p=JSON.parse(raw)as Partial<GameState>;const i=Math.min(p.enemyIndex??0,enemies.length-1),e=enemies[i];return{...createInitialState(),...p,enemyIndex:i,enemyHp:Math.min(p.enemyHp??e.maxHp,e.maxHp),enemyPose:"idle",playerHp:Math.max(1,p.playerHp??100)}}catch{return createInitialState()}}
export function saveState(s:GameState){localStorage.setItem(SAVE_KEY,JSON.stringify({...s,enemyPose:"idle"}))}
export function resetSave(){localStorage.removeItem(SAVE_KEY)}
export function playerDamage(s:GameState){return 6+s.level*2+(s.equipped?.power??0)}
export function enemyDamage(s:GameState){return enemies[s.enemyIndex].attack}
export function applyEnemyHit(s:GameState):GameState{return{...s,playerHp:Math.max(0,s.playerHp-enemyDamage(s)),enemyPose:"attack"}}
export function revivePlayer(s:GameState):GameState{return{...s,playerHp:s.playerMaxHp,enemyHp:enemies[s.enemyIndex].maxHp,enemyPose:"idle"}}
export function applyVictory(s:GameState):GameState{const e=enemies[s.enemyIndex],item=itemForEnemy(s.enemyIndex);let xp=s.xp+e.xp,level=s.level,next=s.xpToNext;while(xp>=next){xp-=next;level++;next=Math.round(next*1.3)}return{...s,level,xp,xpToNext:next,gold:s.gold+e.gold,inventory:s.inventory.some(i=>i.id===item.id)?s.inventory:[...s.inventory,item],victories:s.victories+1,enemyPose:"defeated"}}
export function advanceEnemy(s:GameState):GameState{const i=(s.enemyIndex+1)%enemies.length;return{...s,enemyIndex:i,enemyHp:enemies[i].maxHp,enemyPose:"idle",playerHp:Math.min(s.playerMaxHp,s.playerHp+28)}}
