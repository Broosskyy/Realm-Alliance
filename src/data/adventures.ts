export type AdventureMode="dungeon"|"tower";
export type AdventureRoom="battle"|"elite"|"treasure"|"boss";export type AdventureEnemy={name:string;icon:string;hp:number;attack:number;rewardGold:number;rewardEssence:number;boss:boolean;room:AdventureRoom;intent:string};
const dungeonNames=["Mooswächter","Runenkrabbler","Schatzmimik","Höhlenkoloss"];
const towerNames=["Turmwächter","Aetherklinge","Prüfer der Höhe","Zenitwächter"];
export function adventureEnemy(mode:AdventureMode,wave:number,zone:number,floor:number):AdventureEnemy{
 const boss=wave%4===3,room:AdventureRoom=boss?"boss":wave===2?"elite":wave===1&&mode==="dungeon"?"treasure":"battle",scale=1+zone*.16+(mode==="tower"?floor*.08:wave*.12),names=mode==="tower"?towerNames:dungeonNames,elite=room==="elite"?1.35:1,treasure=room==="treasure"?.82:1;
 return{name:names[wave%names.length]??"Wächter",icon:boss?"♛":room==="treasure"?"▣":room==="elite"?"✦":mode==="tower"?"♜":"◆",hp:Math.round((boss?150:65)*scale*elite*treasure),attack:Math.round((boss?9:4)*scale*(room==="elite"?1.25:1)),rewardGold:Math.round((boss?75:room==="treasure"?55:24)*scale),rewardEssence:boss?2:room==="elite"?1:0,boss,room,intent:boss?"Phasenangriff":room==="elite"?"Schwerer Schlag":room==="treasure"?"Schatz bewachen":"Angriff"};
}
export const ADVENTURE_WAVES=4;
