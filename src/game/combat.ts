import{critChance,playerDamage,type GameState}from"./state";
import{SKILLS,skillMultiplier,type SkillId}from"../data/skills";
export type AttackResult={damage:number;critical:boolean;enemyHp:number;killed:boolean};
export function resolveBasicAttack(s:GameState,roll=Math.random()):AttackResult{const critical=roll*100<critChance(s),damage=Math.round(playerDamage(s)*(critical?1.75:1)),enemyHp=Math.max(0,s.enemyHp-damage);return{damage,critical,enemyHp,killed:enemyHp<=0}}
export function resolveSkillAttack(s:GameState,id:SkillId):AttackResult{const level=id==="slash"?s.skillSlash:s.skillNova,damage=Math.round(playerDamage(s)*skillMultiplier(id,level)),enemyHp=Math.max(0,s.enemyHp-damage);return{damage,critical:false,enemyHp,killed:enemyHp<=0}}
export function skillReadyAt(id:SkillId,usedAt:number){return usedAt+SKILLS[id].cooldownMs}
