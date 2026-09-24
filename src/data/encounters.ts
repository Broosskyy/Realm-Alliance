export type EncounterKind="normal"|"tough"|"elite"|"treasure"|"essence"|"golden"|"cursed"|"boss";
export type EncounterDefinition={kind:EncounterKind;label:string;hpMultiplier:number;attackMultiplier:number;xpMultiplier:number;goldMultiplier:number;essenceMultiplier:number;lootMultiplier:number};
export const ENCOUNTERS:Record<EncounterKind,EncounterDefinition>={
normal:{kind:"normal",label:"Normal",hpMultiplier:1,attackMultiplier:1,xpMultiplier:1,goldMultiplier:1,essenceMultiplier:1,lootMultiplier:1},
tough:{kind:"tough",label:"Zäh",hpMultiplier:1.25,attackMultiplier:1.1,xpMultiplier:1.2,goldMultiplier:1.15,essenceMultiplier:1,lootMultiplier:1.1},
elite:{kind:"elite",label:"Elite",hpMultiplier:1.8,attackMultiplier:1.35,xpMultiplier:1.8,goldMultiplier:1.6,essenceMultiplier:2,lootMultiplier:1.8},
treasure:{kind:"treasure",label:"Schatzwesen",hpMultiplier:.75,attackMultiplier:.7,xpMultiplier:1,goldMultiplier:4,essenceMultiplier:1,lootMultiplier:2.2},
essence:{kind:"essence",label:"Essenzriss",hpMultiplier:1.2,attackMultiplier:1.15,xpMultiplier:1.15,goldMultiplier:.7,essenceMultiplier:4,lootMultiplier:1.25},
golden:{kind:"golden",label:"Goldwesen",hpMultiplier:1.1,attackMultiplier:1,xpMultiplier:1.1,goldMultiplier:5,essenceMultiplier:1,lootMultiplier:1.4},
cursed:{kind:"cursed",label:"Verflucht",hpMultiplier:1.65,attackMultiplier:1.5,xpMultiplier:1.6,goldMultiplier:1.8,essenceMultiplier:2,lootMultiplier:2},
boss:{kind:"boss",label:"Boss",hpMultiplier:1,attackMultiplier:1,xpMultiplier:1,goldMultiplier:1,essenceMultiplier:1,lootMultiplier:2.5}};
export function encounterForStage(enemyIndex:number,zone=1):EncounterKind{
 if(enemyIndex===4)return"boss";
 const seed=(zone*37+enemyIndex*17)%100;
 if(seed<7)return"treasure";
 if(seed<14)return"golden";
 if(seed<21)return"essence";
 if(seed<29)return"elite";
 if(seed<35)return"cursed";
 return enemyIndex>=2?"tough":"normal";
}
