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
