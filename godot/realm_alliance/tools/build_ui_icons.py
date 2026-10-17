"""Deterministic, original vector glyphs for the Work 6.1 native HUD."""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / 'assets/ui/work61'
paths = {
 'gold': '<circle cx="32" cy="32" r="24" fill="url(#gold)" stroke="#fff0a4"/><circle cx="32" cy="32" r="18" fill="none" stroke="#9d5b10"/><path d="M38 21h-9q-10 1-8 10q1 7 11 7q11 0 10-8q-1-6-12-5M32 17v30"/>',
 'gem': '<path d="m32 5 24 26-24 28L8 31Z" fill="url(#purple)"/><path d="m32 5-9 25 9 29 10-29ZM8 31h48" fill="none" stroke="#edbaff"/>',
 'shard': '<path d="m32 4 22 13v31L32 61 10 48V17Z" fill="url(#cyan)"/><path d="m32 4-9 18v23l9 16 9-16V22ZM10 17l13 5 18 0 13-5M10 48l13-3 18 0 13 3" fill="none" stroke="#b3faff"/>',
 'mountain': '<path d="m4 52 18-35 10 15L42 8l19 44Z" fill="url(#silver)"/><path d="m15 31 7-14 9 15-7-5-4 6ZM34 26l8-18 11 25-10-7-4 5Z" fill="#fff" stroke="none"/>',
 'swords': '<g fill="url(#silver)"><path d="m9 5 11 4 32 37-6 6L10 17Z"/><path d="m55 5-11 4L12 46l6 6 36-35Z"/></g><g stroke="#c09dff" stroke-width="6"><path d="m36 50 16-14M12 36l16 14"/></g><path d="m11 54 7-7m29 0 7 7" stroke="#d7aa62" stroke-width="7"/>',
 'map': '<path d="m6 15 17-7 18 7 17-7v43l-17 7-18-7-17 7Z" fill="url(#silver)"/><path d="M23 8v43m18-36v43" stroke="#486a90"/><path d="m28 33 6-8 5 8-5-2v12h-5V31Z" fill="#132a45" stroke="none"/>',
 'paw': '<g fill="url(#silver)"><ellipse cx="12" cy="22" rx="7" ry="10" transform="rotate(-20 12 22)"/><ellipse cx="27" cy="13" rx="7" ry="10"/><ellipse cx="43" cy="16" rx="7" ry="10"/><ellipse cx="55" cy="30" rx="6" ry="9" transform="rotate(20 55 30)"/><path d="M12 48q1-9 11-16q12-12 23 4q16 15 4 21q-7 4-17-1q-9 4-16 0q-6-2-5-8Z"/></g>',
 'chest': '<path d="M8 28h48v29H8Z" fill="#a66d31"/><path d="M8 29V18q0-10 24-10t24 10v11Z" fill="url(#gold)"/><path d="M8 32h48M18 9v47m28-47v47" stroke="#ffdc89" stroke-width="5"/><path d="M27 27h10v13H27Z" fill="#ffdb76"/><path d="M31 31h2v5h-2" stroke="#694516"/>',
 'grid': '<g fill="url(#silver)"><rect x="7" y="7" width="20" height="20" rx="3"/><rect x="37" y="7" width="20" height="20" rx="3"/><rect x="7" y="37" width="20" height="20" rx="3"/><rect x="37" y="37" width="20" height="20" rx="3"/></g>',
 'gear': '<path d="m25 5 14 0 2 9 8 4 9-1 5 12-7 7-1 8 4 8-11 8-9-4-9 1-7 5-11-8 3-9-3-8-8-6 4-13 9-1 6-5Z" fill="url(#silver)" transform="translate(0 -2) scale(.97)"/><circle cx="32" cy="32" r="10" fill="#10233d"/>',
 'mail': '<rect x="5" y="12" width="54" height="40" rx="6" fill="url(#silver)"/><path d="m6 15 26 22 26-22M6 51l18-19m34 19L40 32" fill="none" stroke="#52708c" stroke-width="2"/>',
 'flame': '<path d="M32 3q-7 18-14 25q-6-2-5-10q-19 30 4 40q17 10 31-4q15-17-2-36q3 14-5 17Q42 17 32 3Z" fill="url(#fire)" stroke="#ffdf73"/><path d="M31 27q-1 13-9 17q-3 16 10 15q17-5 5-22q1 9-6 12q5-15 0-22Z" fill="#fff6a4" stroke="none"/>',
 'shield': '<path d="m32 5 23 9-3 25q-4 13-20 21Q16 52 12 39L9 14Z" fill="url(#cyan)" stroke="#c8faff" stroke-width="3"/><path d="m32 13 15 6-2 18q-2 9-13 16Z" fill="#126ba9" stroke="none"/>',
 'rock': '<path d="m6 52 12-30L34 8l17 17 9 27Z" fill="url(#silver)"/><path d="m18 22 14 9 2-23m-2 23 19-6M6 52l26-21 10 21" fill="none" stroke="#56708b"/>',
 'lock': '<path d="M19 29V19a13 13 0 0 1 26 0v10" fill="none" stroke="#bfd0e5" stroke-width="6"/><rect x="12" y="28" width="40" height="31" rx="6" fill="url(#silver)"/><path d="M32 38v11" stroke="#18324f" stroke-width="6"/>',
 'star': '<path d="m32 4 8 18 20 3-15 15 4 20-17-10-17 10 4-20L4 25l20-3Z" fill="url(#gold)" stroke="#fff1ab"/>',
 'arrow': '<path d="m22 10 21 22-21 22" fill="none" stroke="#def2ff" stroke-width="7"/>',
 'heart': '<path d="M32 57S2 38 4 20Q8 0 32 15Q56 0 60 20q2 18-28 37Z" fill="url(#red)" stroke="#ffa7ba"/>',
 'eye': '<path d="M4 32Q32 1 60 32Q32 62 4 32Z" fill="url(#purple)" stroke="#ebaeff"/><circle cx="32" cy="32" r="13" fill="#e4b0ff"/><circle cx="32" cy="32" r="6" fill="#6721bc"/><path d="M32 4v10m0 36v10" stroke="#e4b0ff" stroke-width="4"/>',
 'crown': '<path d="m7 16 14 13L32 7l11 22 14-13-7 36H14Z" fill="url(#gold)" stroke="#fff1b0"/><path d="M15 45h34" stroke="#8e5219" stroke-width="4"/><circle cx="32" cy="35" r="4" fill="#b35afe"/>',
}
defs='''<defs><linearGradient id="silver" x2=".3" y2="1"><stop stop-color="#f4f8ff"/><stop offset=".5" stop-color="#b7c8e1"/><stop offset="1" stop-color="#627da4"/></linearGradient><linearGradient id="gold" x2=".3" y2="1"><stop stop-color="#fff2a0"/><stop offset=".45" stop-color="#ffbf3a"/><stop offset="1" stop-color="#b66e1b"/></linearGradient><linearGradient id="cyan" x2=".5" y2="1"><stop stop-color="#b3ffff"/><stop offset=".5" stop-color="#18ceff"/><stop offset="1" stop-color="#006acb"/></linearGradient><linearGradient id="purple" x2=".5" y2="1"><stop stop-color="#f1b0ff"/><stop offset=".5" stop-color="#b947ff"/><stop offset="1" stop-color="#5527b9"/></linearGradient><linearGradient id="fire" x2=".5" y2="1"><stop stop-color="#fff078"/><stop offset=".5" stop-color="#ff9b16"/><stop offset="1" stop-color="#f04419"/></linearGradient><linearGradient id="red" x2=".5" y2="1"><stop stop-color="#ff97ae"/><stop offset=".5" stop-color="#ff4e78"/><stop offset="1" stop-color="#bc1746"/></linearGradient></defs>'''
OUT.mkdir(parents=True, exist_ok=True)
for name, body in paths.items():
    (OUT / f'{name}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">{defs}<g stroke="#d1e5fb" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">{body}</g></svg>\n')
print(f'Wrote {len(paths)} native UI icons')
