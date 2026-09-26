import React from "react";
import type {EnemyArchetype} from "../data/content";

type Family="cloud"|"lava"|"ice"|"crystal"|"sun"|"void"|string;
const palette:Record<string,[string,string,string,string]>={
 cloud:["#dff8ff","#73cde8","#426e91","#fff4c7"],lava:["#ffcc72","#e95732","#6f2830","#ffe7a3"],
 ice:["#e9fdff","#7ddcea","#4a83a5","#ffffff"],crystal:["#e5ddff","#9a7bea","#51498e","#8ff4ff"],
 sun:["#ffe89a","#d99c45","#8b5b35","#fff7c7"],void:["#e5a4ff","#9b4cc7","#392850","#ff8fe6"]
};
export function HeroPlaceholder({state="idle"}:{state?:string}){
 return <svg className={"code-art hero-art state-"+state} viewBox="0 0 220 260" role="img" aria-label="Held">
  <ellipse className="art-shadow" cx="110" cy="236" rx="62" ry="12"/>
  <path className="hero-cape" d="M76 104 Q48 145 61 218 Q91 237 119 215 L111 112Z"/>
  <path className="hero-leg" d="M87 178 L79 229 L99 229 L110 179Z"/><path className="hero-leg" d="M116 179 L126 229 L146 229 L135 174Z"/>
  <path className="hero-boot" d="M77 221 Q92 218 102 230 L96 239 H68Q67 229 77 221Z"/><path className="hero-boot" d="M126 221 Q143 218 153 231 L148 239 H120Z"/>
  <path className="hero-body-art" d="M76 99 Q109 80 145 103 L137 177 Q108 194 78 174Z"/>
  <path className="hero-shoulder" d="M71 102 Q55 105 52 126 L77 134Z"/><path className="hero-shoulder" d="M145 103 Q163 106 166 126 L139 135Z"/>
  <path className="hero-arm" d="M58 121 Q49 150 69 174 L84 162 L76 127Z"/><path className="hero-arm" d="M159 121 Q170 147 148 171 L134 159 L142 127Z"/>
  <path className="hero-head" d="M81 50 Q108 25 139 50 L143 91 Q112 113 79 89Z"/>
  <path className="hero-hair" d="M78 61 Q83 29 112 29 Q143 30 148 62 L136 55 L130 70 L119 55 L104 68 L92 54Z"/>
  <path className="hero-face" d="M91 66 Q109 54 132 67 L129 91 Q110 101 92 89Z"/>
  <path className="hero-eye" d="M97 72h8v5h-8zM119 72h8v5h-8z"/>
  <path className="hero-belt" d="M78 151 Q110 160 139 151 L138 165 Q109 173 78 164Z"/>
  <path className="hero-sword" d="M151 49 L164 40 L151 139 L139 151 L143 130Z"/><path className="hero-sword-edge" d="M158 47 L164 40 L151 139 L147 135Z"/>
  <path className="hero-guard" d="M132 139 L159 151 L154 159 L128 147Z"/>
 </svg>
}
export function MonsterPlaceholder({family,archetype,variant=0,boss=false,pose="idle"}:{family:Family;archetype:EnemyArchetype;variant?:number;boss?:boolean;pose?:string}){
 const p=palette[family]??palette.cloud; const eye=p[3]; const seed=variant%3;
 return <svg className={"code-art monster-art family-art-"+family+" archetype-art-"+archetype+" pose-"+pose+(boss?" boss-art":"")} viewBox="0 0 300 280" role="img" aria-label="Gegner" style={{"--art-a":p[0],"--art-b":p[1],"--art-c":p[2],"--art-eye":eye} as React.CSSProperties}>
  <ellipse className="art-shadow" cx="150" cy="247" rx={boss?96:78} ry="14"/>
  {archetype==="swift"&&<><path className="monster-tail" d="M91 174 Q37 163 39 117 Q57 143 90 137Z"/><path className="monster-wing" d="M105 116 Q54 74 49 120 Q71 112 102 145Z"/><path className="monster-wing right" d="M195 116 Q246 74 251 120 Q229 112 198 145Z"/></>}
  {archetype==="caster"&&<><path className="monster-orbit" d="M61 137 Q150 65 239 137 Q150 213 61 137Z"/><circle className="monster-rune" cx="150" cy="48" r="12"/></>}
  {archetype==="guardian"&&<><path className="monster-shield" d="M72 121 Q45 173 80 218 L104 198 L98 128Z"/><path className="monster-shield right" d="M228 121 Q255 173 220 218 L196 198 L202 128Z"/></>}
  {archetype==="stalker"&&<><path className="monster-tail" d="M91 181 Q38 214 45 239 Q72 215 116 212Z"/><path className="monster-spike" d="M96 91 L72 48 L118 76Z"/><path className="monster-spike right" d="M204 91 L228 48 L182 76Z"/></>}
  {archetype==="brute"&&<><path className="monster-horn" d="M103 82 Q70 35 55 72 L94 106Z"/><path className="monster-horn right" d="M197 82 Q230 35 245 72 L206 106Z"/></>}
  {boss&&<><path className="monster-horn" d="M105 78 L82 22 L132 65Z"/><path className="monster-horn right" d="M195 78 L218 22 L168 65Z"/><path className="boss-crown" d="M112 65 L128 31 L149 57 L171 27 L188 67Z"/></>}
  <path className="monster-body" d={boss?"M78 113 Q89 66 150 61 Q211 66 222 113 L226 190 Q210 235 150 238 Q90 235 74 190Z":"M91 121 Q101 78 150 76 Q199 78 209 121 L211 188 Q198 226 150 230 Q102 226 89 188Z"}/>
  <path className="monster-belly" d="M111 150 Q150 128 189 150 L184 205 Q150 220 116 204Z"/>
  <path className="monster-brow" d="M105 119 Q124 105 141 116 L136 126 Q119 119 106 129Z"/><path className="monster-brow right" d="M195 119 Q176 105 159 116 L164 126 Q181 119 194 129Z"/>
  <path className="monster-eye" d="M111 127 Q125 116 138 128 Q126 143 112 134Z"/><path className="monster-eye right" d="M189 127 Q175 116 162 128 Q174 143 188 134Z"/>
  <path className="monster-pupil" d="M122 125 L130 130 L123 136 L117 131Z"/><path className="monster-pupil right" d="M178 125 L170 130 L177 136 L183 131Z"/>
  <path className="monster-mouth" d={seed===0?"M126 169 Q150 185 174 169 Q166 195 150 197 Q134 195 126 169Z":seed===1?"M126 177 Q150 162 174 177 Q151 191 126 177Z":"M128 171 L142 181 L151 170 L161 182 L174 170"}/>
  <path className="monster-foot" d="M99 207 Q78 221 80 241 H126 L132 218Z"/><path className="monster-foot right" d="M201 207 Q222 221 220 241 H174 L168 218Z"/>
  <path className="monster-mark" d={seed===0?"M143 92 L150 78 L157 92 L150 105Z":seed===1?"M137 91 Q150 77 163 91 Q150 107 137 91Z":"M139 86 L161 86 L150 106Z"}/>
 </svg>
}

export function PetPlaceholder({kind="wisp",stage=1}:{kind?:string;stage?:number}){
 const ears=kind==="fox"||kind==="owl", wings=kind==="drake"||kind==="owl";
 return <svg className={"code-art pet-art pet-"+kind+" pet-evo-"+stage} viewBox="0 0 120 110" aria-hidden="true">
  <ellipse className="art-shadow" cx="60" cy="99" rx="31" ry="6"/>
  {wings&&<><path className="pet-wing" d="M39 55 Q10 37 15 70 Q28 65 43 75Z"/><path className="pet-wing right" d="M81 55 Q110 37 105 70 Q92 65 77 75Z"/></>}
  {ears&&<><path className="pet-ear" d="M39 39 L29 13 L52 33Z"/><path className="pet-ear right" d="M81 39 L91 13 L68 33Z"/></>}
  <path className="pet-body-art" d="M34 54 Q39 28 60 27 Q82 28 87 54 L83 84 Q61 101 37 84Z"/>
  <path className="pet-face-art" d="M43 53 Q60 42 77 53 L74 72 Q60 82 46 72Z"/>
  <circle className="pet-eye-art" cx="51" cy="58" r="4"/><circle className="pet-eye-art" cx="69" cy="58" r="4"/>
  <path className="pet-mark-art" d="M55 42 L60 34 L65 42 L60 49Z"/>
  {stage>=2&&<path className="pet-aura-art" d="M24 76 Q10 50 29 28 M96 76 Q110 50 91 28"/>}
 </svg>
}
export function LootPlaceholder({slot="weapon",rarity="common"}:{slot?:string;rarity?:string}){
 return <svg className={"code-art loot-art loot-"+slot+" rarity-art-"+rarity} viewBox="0 0 100 100" aria-hidden="true">
  <path className="loot-glow" d="M50 6 L62 24 L84 18 L78 41 L95 53 L76 65 L80 88 L58 80 L43 95 L31 76 L8 79 L17 57 L3 42 L25 34 L27 12Z"/>
  {slot==="weapon"?<><path className="loot-blade" d="M69 13 L82 18 L47 65 L36 70 L39 58Z"/><path className="loot-guard" d="M29 59 L52 76 L45 84 L22 67Z"/><path className="loot-grip" d="M31 72 L18 88"/></>:slot==="armor"?<><path className="loot-armor" d="M29 25 L42 17 Q50 25 58 17 L72 25 L83 43 L70 50 L68 82 H32 L30 50 L17 43Z"/><path className="loot-crest" d="M42 36 L50 28 L58 36 L50 51Z"/></>:<><circle className="loot-charm" cx="50" cy="55" r="23"/><path className="loot-chain" d="M31 36 Q50 6 69 36"/><path className="loot-crest" d="M43 50 L50 39 L58 50 L50 66Z"/></>}
 </svg>
}
export function ChestPlaceholder({open=false}:{open?:boolean}){
 return <svg className={"code-art chest-art "+(open?"open":"")} viewBox="0 0 130 105" aria-hidden="true">
  <ellipse className="art-shadow" cx="65" cy="94" rx="47" ry="7"/><path className="chest-body-art" d="M22 48 H108 L103 89 H27Z"/><path className="chest-band-art" d="M57 47 H73 V91 H57Z"/>
  <path className="chest-lid-art" d="M24 47 Q27 19 51 15 H80 Q103 20 106 47Z"/><path className="chest-rim-art" d="M20 43 H110 V55 H20Z"/><path className="chest-lock-art" d="M57 48 H73 V68 H57Z"/>
 </svg>
}
export function WorldScenery({world=0}:{world?:number}){
 return <svg className={"code-art world-art world-art-"+(world+1)} viewBox="0 0 420 330" preserveAspectRatio="none" aria-hidden="true">
  <path className="world-sky-art" d="M0 0H420V330H0Z"/><circle className="world-sun-art" cx={world===5?330:72} cy="62" r={world===5?28:38}/>
  <path className="world-back-art" d={world===0?"M0 180 Q55 125 108 171 Q167 99 226 169 Q300 107 420 172 V330H0Z":world===1?"M0 205 L54 115 L103 188 L158 74 L225 194 L292 106 L350 187 L420 129 V330H0Z":world===2?"M0 190 L72 91 L126 164 L193 57 L252 169 L326 84 L420 174 V330H0Z":world===3?"M0 205 L54 135 L84 190 L125 82 L165 188 L224 104 L260 191 L326 61 L365 186 L420 126 V330H0Z":world===4?"M0 195 L50 161 L86 177 L118 117 L154 177 L207 137 L256 177 L302 102 L352 174 L420 142 V330H0Z":"M0 185 Q62 106 112 170 Q178 73 229 166 Q294 91 420 159 V330H0Z"}/>
  <path className="world-ground-art" d="M0 218 Q96 193 194 222 Q303 191 420 219 V330H0Z"/>
  {world===0&&<><path className="world-prop-art" d="M28 231 Q55 188 81 231Z M317 229 Q344 179 374 229Z"/><path className="world-prop2-art" d="M116 229 Q151 208 184 229Z"/></>}
  {world===1&&<><path className="world-prop-art" d="M50 252 L76 206 L96 252 M321 252 L346 199 L370 252"/><path className="world-prop2-art" d="M0 273 Q72 245 130 275 Q188 249 240 276 Q326 242 420 272"/></>}
  {world===2&&<><path className="world-prop-art" d="M48 250 L69 188 L86 250 M329 250 L349 177 L369 250"/><path className="world-prop2-art" d="M125 249 L145 214 L161 249 M252 250 L271 207 L289 250"/></>}
  {world===3&&<><path className="world-prop-art" d="M55 256 L75 176 L97 256 M318 256 L343 165 L368 256"/><path className="world-prop2-art" d="M128 256 L145 208 L166 256 M254 256 L272 198 L292 256"/></>}
  {world===4&&<><path className="world-prop-art" d="M45 258 V196 H64 V258 M351 258 V188 H370 V258"/><path className="world-prop2-art" d="M121 253 L138 202 H159 L176 253 M249 253 L267 211 H288 L305 253"/></>}
  {world===5&&<><path className="world-prop-art" d="M53 260 Q66 201 90 172 Q83 228 103 260 M320 260 Q341 202 367 177 Q354 228 374 260"/><path className="world-prop2-art" d="M196 248 L210 188 L224 248"/></>}
 </svg>
}

export function AdventureEnemyPlaceholder({boss=false,room="battle",mode="dungeon"}:{boss?:boolean;room?:string;mode?:string}){
 return <svg className={"code-art adventure-enemy-art room-art-"+room+" mode-art-"+mode+(boss?" adventure-boss-art":"")} viewBox="0 0 210 190" aria-hidden="true">
  <ellipse className="art-shadow" cx="105" cy="176" rx="66" ry="9"/>
  {boss&&<><path className="adv-horn" d="M73 61 L50 16 L88 48Z"/><path className="adv-horn right" d="M137 61 L160 16 L122 48Z"/></>}
  <path className="adv-cloak" d="M61 85 Q105 49 149 85 L161 165 Q105 187 49 165Z"/>
  <path className="adv-head" d="M69 58 Q105 30 141 58 L137 104 Q105 125 73 104Z"/>
  <path className="adv-mask" d="M78 68 Q105 52 132 68 L127 94 Q105 108 83 94Z"/>
  <path className="adv-eye" d="M87 73 L100 78 L88 84Z"/><path className="adv-eye right" d="M123 73 L110 78 L122 84Z"/>
  <path className="adv-arm" d="M60 91 Q35 116 44 151 L68 140Z"/><path className="adv-arm right" d="M150 91 Q175 116 166 151 L142 140Z"/>
  {room==="treasure"?<path className="adv-treasure" d="M76 133 H134 L130 166 H80Z M78 132 Q82 112 105 111 Q128 112 132 132Z"/>:<path className="adv-weapon" d="M151 73 L172 56 L143 139 L132 147Z"/>}
  <path className="adv-rune" d="M97 122 L105 110 L113 122 L105 135Z"/>
 </svg>
}
export function RelicPlaceholder({kind="warSigil"}:{kind?:string}){
 const shape=kind==="lifeSeed"?"seed":kind==="fortuneIdol"?"idol":kind==="skillPrism"?"prism":kind==="adventureCrown"?"crown":"sigil";
 return <svg className={"code-art relic-art relic-"+shape} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="relic-halo" cx="50" cy="50" r="39"/>
  {shape==="seed"?<><path className="relic-main" d="M50 16 Q80 42 65 70 Q50 92 35 70 Q20 42 50 16Z"/><path className="relic-detail" d="M50 35 V72 M50 53 Q36 46 31 36 M50 57 Q66 49 71 38"/></>:shape==="idol"?<><path className="relic-main" d="M32 20 H68 L77 42 L68 82 H32 L23 42Z"/><circle className="relic-detail-fill" cx="50" cy="45" r="13"/><path className="relic-detail" d="M38 70 H62"/></>:shape==="prism"?<><path className="relic-main" d="M50 12 L78 38 L66 83 H34 L22 38Z"/><path className="relic-detail" d="M50 13 V82 M23 38 L66 83 M78 38 L34 83"/></>:shape==="crown"?<><path className="relic-main" d="M20 66 L25 31 L43 49 L51 20 L62 49 L79 31 L82 66Z"/><path className="relic-detail" d="M22 67 H81 V79 H22Z"/></>:<><path className="relic-main" d="M50 12 L82 50 L50 88 L18 50Z"/><path className="relic-detail" d="M50 27 L67 50 L50 73 L33 50Z"/></>}
 </svg>
}
export function ShopItemPlaceholder({kind="chest"}:{kind?:string}){
 return <svg className={"code-art shop-art shop-"+kind} viewBox="0 0 110 100" aria-hidden="true">
  <ellipse className="art-shadow" cx="55" cy="91" rx="35" ry="6"/>
  {kind==="key"?<><circle className="shop-key-ring" cx="38" cy="42" r="17"/><path className="shop-key" d="M50 54 L82 82 M67 67 L77 57 M74 74 L85 64"/></>:kind==="potion"?<><path className="shop-bottle" d="M43 20 H67 V35 Q82 49 75 76 Q55 92 35 76 Q28 49 43 35Z"/><path className="shop-liquid" d="M36 58 Q55 48 74 58 L72 75 Q55 85 38 75Z"/></>:kind==="material"?<><path className="shop-crystal" d="M55 11 L82 43 L68 87 H41 L26 43Z"/><path className="shop-detail" d="M55 12 V86 M27 43 L68 87"/></>:<><path className="shop-chest" d="M22 47 H88 L84 84 H26Z"/><path className="shop-chest-lid" d="M25 46 Q29 21 55 20 Q81 21 85 46Z"/><path className="shop-band" d="M49 45 H62 V85 H49Z"/></>}
 </svg>
}

export function SkillPlaceholder({kind="slash"}:{kind?:string}){
 return <svg className={"code-art skill-art skill-art-"+kind} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="skill-disc" cx="50" cy="50" r="43"/>
  {kind==="slash"?<><path className="skill-slash-a" d="M20 70 Q43 31 80 19 Q59 48 34 80Z"/><path className="skill-slash-b" d="M27 77 Q52 52 76 44"/></>:<><circle className="skill-core" cx="50" cy="50" r="17"/><path className="skill-orbit" d="M13 50 Q50 13 87 50 Q50 87 13 50Z"/><path className="skill-ray" d="M50 8 V27 M50 73 V92 M8 50 H27 M73 50 H92"/></>}
 </svg>
}
export function WeaponPlaceholder({name=""}:{name?:string}){
 const axe=name.includes("Axt"),staff=name.includes("Stab")||name.includes("Fokus"),bow=name.includes("Bogen"),dagger=name.includes("Dolche");
 return <svg className="code-art weapon-art" viewBox="0 0 110 110" aria-hidden="true">
  {axe?<><path className="weapon-handle" d="M34 94 L72 22"/><path className="weapon-metal" d="M67 19 Q93 13 95 37 Q76 43 62 33Z"/></>:staff?<><path className="weapon-handle" d="M37 96 L66 22"/><circle className="weapon-gem" cx="69" cy="20" r="12"/><path className="weapon-metal" d="M56 29 L47 12 M76 31 L88 17"/></>:bow?<><path className="weapon-bow" d="M29 14 Q91 55 31 96"/><path className="weapon-string" d="M29 14 L55 55 L31 96"/><path className="weapon-arrow" d="M17 55 H89"/></>:dagger?<><path className="weapon-metal" d="M25 75 L55 26 L63 35 L37 82Z"/><path className="weapon-metal" d="M51 80 L76 30 L85 38 L64 87Z"/></>:<><path className="weapon-metal" d="M24 88 L67 18 L80 25 L39 94Z"/><path className="weapon-guard" d="M27 73 L51 90"/></>}
 </svg>
}
export function WorldThumbnail({world=0}:{world?:number}){
 return <svg className={"code-art world-thumb-art wt-art-"+(world+1)} viewBox="0 0 100 100" aria-hidden="true">
  <circle className="wt-sky" cx="50" cy="50" r="46"/><circle className="wt-sun" cx="30" cy="27" r="10"/>
  <path className="wt-back" d={world===1?"M9 70 L29 31 L44 61 L62 22 L91 69 V91 H9Z":world===2?"M8 71 L31 29 L48 58 L66 18 L93 69 V92 H8Z":world===3?"M9 76 L27 43 L39 68 L53 24 L66 68 L81 35 L93 75 V92 H9Z":world===4?"M8 73 L27 58 L38 65 L51 38 L63 66 L78 45 L93 70 V92 H8Z":world===5?"M8 70 Q31 30 48 64 Q68 25 93 62 V92 H8Z":"M8 72 Q29 43 45 65 Q65 31 93 63 V92 H8Z"}/>
  <path className="wt-ground" d="M7 73 Q50 62 93 73 V93 H7Z"/>
 </svg>
}
