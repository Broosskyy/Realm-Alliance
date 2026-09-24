import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { enemies } from "./data/content";
import {
  advanceEnemy,
  applyVictory,
  loadState,
  playerDamage,
  resetSave,
  saveState,
  type GameState,
} from "./game/state";
import "./styles/app.css";

function App() {
  const [started, setStarted] = useState(false);
  const [state, setState] = useState<GameState>(() => loadState());
  const [message, setMessage] = useState("Der Grünhain wartet.");
  const enemy = enemies[state.enemyIndex];
  const damage = useMemo(() => playerDamage(state), [state]);

  useEffect(() => {
    saveState(state);
  }, [state]);

  function strike() {
    if (state.enemyHp <= 0) return;

    setState((current) => ({ ...current, enemyPose: "attack" }));
    window.setTimeout(() => {
      setState((current) => {
        const nextHp = Math.max(0, current.enemyHp - playerDamage(current));

        if (nextHp === 0) {
          setMessage(`${enemies[current.enemyIndex].name} besiegt — Beute gesichert.`);
          return applyVictory({ ...current, enemyHp: 0, enemyPose: "defeated" });
        }

        setMessage(`Treffer: ${playerDamage(current)} Schaden`);
        return { ...current, enemyHp: nextHp, enemyPose: "hit" };
      });

      window.setTimeout(() => {
        setState((current) =>
          current.enemyHp > 0 ? { ...current, enemyPose: "idle" } : current,
        );
      }, 170);
    }, 80);
  }

  function nextEncounter() {
    setState((current) => advanceEnemy(current));
    setMessage("Ein neuer Gegner tritt aus dem Grün.");
  }

  function equip(itemId: string) {
    setState((current) => {
      const item = current.inventory.find((entry) => entry.id === itemId) ?? null;
      return { ...current, equipped: item };
    });
  }

  function reset() {
    resetSave();
    const fresh = loadState();
    setState(fresh);
    setStarted(false);
    setMessage("Der Grünhain wartet.");
  }

  if (!started) {
    return (
      <main className="splash">
        <section className="splash__card">
          <div className="brandmark">RA</div>
          <p className="eyebrow">WEB FIRST · QUICK PLAY</p>
          <h1>REALM ALLIANCE</h1>
          <p className="lead">
            Direkt in den Grünhain. Kein Download. Kein Pflichtkonto vor dem ersten Kampf.
          </p>
          <button className="primary" onClick={() => setStarted(true)}>
            Spielen
          </button>
          <span className="save-note">Fortschritt wird auf diesem Gerät gespeichert.</span>
        </section>
      </main>
    );
  }

  const hpPercent = Math.max(0, (state.enemyHp / enemy.maxHp) * 100);

  return (
    <main className="game">
      <header className="topbar">
        <div>
          <span className="eyebrow">GRÜNHAIN</span>
          <strong>Level {state.level}</strong>
        </div>
        <div className="currencies">
          <span>{state.gold} Gold</span>
          <span>{state.xp}/{state.xpToNext} XP</span>
        </div>
      </header>

      <section className="arena">
        <div className="forest forest--back" />
        <div className="mist" />
        <div className="encounter-copy">
          <span>Begegnung {state.enemyIndex + 1}</span>
          <h2>{enemy.name}</h2>
          <p>{enemy.subtitle}</p>
        </div>

        <button
          className={`monster monster--${state.enemyPose}`}
          onClick={strike}
          disabled={state.enemyHp <= 0}
          aria-label={`${enemy.name} angreifen`}
        >
          <span className="monster__ears">◆ ◆</span>
          <span className="monster__face">
            <i />
            <i />
          </span>
          <span className="monster__body">✦</span>
          <span className="monster__shadow" />
        </button>

        <div className="enemy-hud">
          <div className="hp-row">
            <span>HP</span>
            <strong>{state.enemyHp}/{enemy.maxHp}</strong>
          </div>
          <div className="bar">
            <div className="bar__fill" style={{ width: `${hpPercent}%` }} />
          </div>
        </div>
      </section>

      <section className="controls">
        <div className="message">{message}</div>

        {state.enemyHp > 0 ? (
          <button className="attack" onClick={strike}>
            <span>ANGRIFF</span>
            <small>{damage} Schaden · Tippen</small>
          </button>
        ) : (
          <button className="primary" onClick={nextEncounter}>
            Nächste Begegnung
          </button>
        )}

        <section className="loot">
          <div className="section-heading">
            <div>
              <span className="eyebrow">AUSRÜSTUNG</span>
              <h3>Gefundene Beute</h3>
            </div>
            <strong>Power +{state.equipped?.power ?? 0}</strong>
          </div>

          {state.inventory.length === 0 ? (
            <p className="empty">Besiege deinen ersten Gegner, um Beute zu erhalten.</p>
          ) : (
            <div className="items">
              {state.inventory.map((item) => (
                <button
                  key={item.id}
                  className={`item item--${item.rarity} ${
                    state.equipped?.id === item.id ? "item--equipped" : ""
                  }`}
                  onClick={() => equip(item.id)}
                >
                  <span className="item__icon">✦</span>
                  <span>
                    <strong>{item.name}</strong>
                    <small>{item.rarity} · +{item.power} Power</small>
                  </span>
                  <b>{state.equipped?.id === item.id ? "Aktiv" : "Anlegen"}</b>
                </button>
              ))}
            </div>
          )}
        </section>

        <button className="reset" onClick={reset}>Entwicklungsstand zurücksetzen</button>
      </section>
    </main>
  );
}

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
