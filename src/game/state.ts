import { enemies, itemForEnemy, type ItemDefinition } from "../data/content";

export type CombatPose = "idle" | "attack" | "hit" | "defeated";
export type GameState = {
  level:number; xp:number; xpToNext:number; gold:number;
  enemyIndex:number; enemyHp:number; enemyPose:CombatPose;
  playerHp:number; playerMaxHp:number;
  equipped:ItemDefinition|null; inventory:ItemDefinition[]; victories:number;
};
const SAVE_KEY="realm-alliance-v2-save";
export function createInitialState():GameState {
  return {level:1,xp:0,xpToNext:40,gold:0,enemyIndex:0,enemyHp:enemies[0].maxHp,enemyPose:"idle",playerHp:100,playerMaxHp:100,equipped:null,inventory:[],victories:0};
}
export function loadState():GameState {
  const raw=localStorage.getItem(SAVE_KEY); if(!raw)return createInitialState();
  try {
    const parsed=JSON.parse(raw) as Partial<GameState>;
    const index=Math.min(parsed.enemyIndex??0,enemies.length-1); const enemy=enemies[index];
    return {...createInitialState(),...parsed,enemyIndex:index,enemyHp:Math.min(parsed.enemyHp??enemy.maxHp,enemy.maxHp),enemyPose:"idle"};
  } catch { return createInitialState(); }
}
export function saveState(state:GameState){localStorage.setItem(SAVE_KEY,JSON.stringify({...state,enemyPose:"idle"}));}
export function resetSave(){localStorage.removeItem(SAVE_KEY);}
export function playerDamage(state:GameState){return 6+state.level*2+(state.equipped?.power??0);}
export function enemyDamage(state:GameState){return enemies[state.enemyIndex].attack;}
export function applyEnemyHit(state:GameState):GameState {
  return {...state,playerHp:Math.max(1,state.playerHp-enemyDamage(state)),enemyPose:"attack"};
}
export function applyVictory(state:GameState):GameState {
  const enemy=enemies[state.enemyIndex], rewardItem=itemForEnemy(state.enemyIndex);
  let xp=state.xp+enemy.xp, level=state.level, xpToNext=state.xpToNext;
  while(xp>=xpToNext){xp-=xpToNext;level+=1;xpToNext=Math.round(xpToNext*1.3);}
  return {...state,level,xp,xpToNext,gold:state.gold+enemy.gold,
    inventory:state.inventory.some(i=>i.id===rewardItem.id)?state.inventory:[...state.inventory,rewardItem],
    victories:state.victories+1,enemyPose:"defeated"};
}
export function advanceEnemy(state:GameState):GameState {
  const nextIndex=(state.enemyIndex+1)%enemies.length;
  return {...state,enemyIndex:nextIndex,enemyHp:enemies[nextIndex].maxHp,enemyPose:"idle",playerHp:Math.min(state.playerMaxHp,state.playerHp+18)};
}
