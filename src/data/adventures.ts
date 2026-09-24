export type AdventureMode="dungeon"|"tower";
export type AdventureEnemy={name:string;icon:string;hp:number;attack:number;rewardGold:number;rewardEssence:number;boss:boolean};
const dungeonNames=["Mooswächter","Runenkrabbler","Schatzmimik","Höhlenkoloss"];
const towerNames=["Turmwächter","Aetherklinge","Prüfer der Höhe","Zenitwächter"];
export function adventureEnemy(mode:AdventureMode,wave:number,zone:number,floor:number):AdventureEnemy{
 const boss=wave%4===3,scale=1+zone*.16+(mode==="tower"?floor*.08:wave*.12),names=mode==="tower"?towerNames:dungeonNames;
 return{name:names[wave%names.length]??"Wächter",icon:boss?"♛":mode==="tower"?"♜":"◆",hp:Math.round((boss?150:65)*scale),attack:Math.round((boss?9:4)*scale),rewardGold:Math.round((boss?75:24)*scale),rewardEssence:boss?2:0,boss};
}
export const ADVENTURE_WAVES=4;
