# Roadmap del MVP

> Desglose de ingeniería para llegar al MVP jugable. Ver `docs/GDD.md` sección 1.4 para el
> alcance de alto nivel; este documento detalla milestones, archivos y criterios de "hecho".

Bucle objetivo: labrar → plantar → regar → crecer → cosechar → vender → dormir → siguiente día,
con un gancho narrativo inicial y al menos un NPC.

Orden recomendado: M0 y M1 en paralelo → M2/M3 → M4 → M5/M6 en paralelo → M7 → M8 (opcional).

## M0 — Decisiones de diseño mínimas

**Sin código.** Define en `docs/GDD.md`: elevator pitch (1.1), 3-4 pilares de diseño (1.2),
premisa en 1-2 frases (2.1), 1 NPC con nombre/rol (2.4), 3-5 líneas de diálogo inicial.

Bloquea a M4 y M6 — el sistema de diálogo no se puede probar con contenido real sin esto.

## M1 — Arreglar el guardado (inventario + farmland)

**Objetivo:** recargar una partida no pierde progreso.

- `Inventory` (`src/systems/inventory/inventory.gd`): añadir `to_dict()`/`from_dict()`.
- `GameState.to_dict()`/`from_dict()` (`src/globals/game_state.gd`): incluir el inventario.
- `SaveManager.save_game()`/`load_game()` (`src/globals/save_manager.gd`): invocar también
  `FarmlandSystem.to_dict()`/`from_dict()` (ya existen, líneas 223-243 de
  `farmland_system.gd`, nadie los llama hoy). Requiere localizar la instancia activa, p. ej.
  vía grupo `"farmland"`.
- `farm.gd`: no repartir ítems iniciales si se está cargando una partida existente.

**Hecho cuando:** labrar/plantar/regar, guardar, cerrar el juego, recargar → todo intacto.

## M2 — Energía/estamina y dormir manualmente

**Objetivo:** terminar el día por decisión del jugador, no solo esperando al reloj.

- Nueva señal `energy_changed` en `EventBus`.
- `GameState`: `energy`, `max_energy`, `spend_energy()`, `restore_energy()`.
- `Player._try_use_tool()` (`player.gd`): gastar energía al usar herramientas.
- `TimeManager.start_day()`: restaurar energía.
- `HUD`: barra de energía.
- Acción de "dormir" (interactuar con la cama/casa, o UI dedicada) que llama a
  `TimeManager.end_day()`.

**Depende de:** M1. **Hecho cuando:** se puede dormir voluntariamente y la energía se refleja
en el HUD.

## M3 — Pulir el bucle de cultivo

**Objetivo:** los cultivos se marchitan si no se riegan; el regrowth funciona; hay feedback de
temporada incorrecta.

- `farmland_system.gd`: usar `CropData.regrowth_days` (campo ya existe, ignorado hoy en
  `try_harvest()`); añadir marchitamiento por días sin riego.
- Conectar por fin `crop_planted`, `crop_watered`, `crop_harvested` (declaradas en `EventBus`,
  nunca conectadas) a feedback visual/sonoro.
- Mensaje claro cuando `try_plant()` falla por temporada incorrecta.

**Hecho cuando:** un cultivo sin riego muere visualmente; uno con `regrowth_days > 0` puede
cosecharse más de una vez.

## M4 — Primer NPC y sistema de diálogo

**Objetivo:** interactuar (E) con el NPC de M0 abre un cuadro de diálogo con su texto.

- `src/entities/npc/npc.gd` (nuevo): extiende `Interactable`
  (`src/entities/interactable.gd`, hoy sin nada que la use).
- `src/resources/dialogue_data.gd` (nuevo `Resource`, siguiendo el patrón de `ItemData`/`CropData`).
- `src/ui/components/dialogue_box.gd`/`.tscn` (nuevo, carpeta hoy vacía).
- Reutilizar `dialogue_requested`, `dialogue_finished`, `interaction_started`, `game_paused`
  (las 4 declaradas en `EventBus`, ninguna conectada hoy).
- Requiere sprite placeholder para el NPC (no hay ninguno en `assets/sprites/`).

**Depende de:** M0. **Hecho cuando:** acercarse al NPC y pulsar E muestra su diálogo y pausa
el juego mientras dura.

## M5 — Economía básica: vender cosechas

**Objetivo:** vender turnips al NPC de M4, el oro sube.

- `src/systems/economy/shop_system.gd` (nuevo).
- `src/ui/menus/sell_menu.gd`/`.tscn` (nuevo, carpeta hoy vacía).
- Reutiliza `gold_changed` e `inventory_changed` (ya conectadas al HUD).

**Depende de:** M4. **Hecho cuando:** vender un turnip descuenta del inventario y suma oro
visible en el HUD.

## M6 — Gancho narrativo inicial

**Objetivo:** diálogo de apertura automático al empezar partida nueva (GDD 2.5, marcado como
prioridad de MVP).

- Casi solo contenido: reutiliza la infraestructura de M4.
- `main.gd`/`farm.gd`: disparar `dialogue_requested` con el diálogo de intro en la primera carga.

**Depende de:** M0 + M4.

## M7 — Menús: pausa, guardar/cargar, inicio

**Objetivo:** dejar de arrancar siempre en partida nueva.

- `main.gd` hoy llama incondicionalmente a `_start_new_game()` — necesita pantalla de inicio
  que ofrezca "Nueva partida" / "Cargar" (usa `SaveManager.has_save()`).
- Menú de pausa: la acción `pause` (ya en el input map de `project.godot`) no tiene handler en
  ningún script hoy. Emitir `EventBus.game_paused` (ya conectada en `TimeManager`, sin emisor).
- `src/ui/menus/` (hoy vacía salvo `.gitkeep`).

**Depende de:** M1 + M2.

## M8 — Pulido sensorial (opcional / stretch)

No bloqueante para considerar el MVP jugable.

- Música y SFX (carpetas `assets/audio/` vacías, `AudioManager` ya implementado y sin usar).
- Animación de usar herramienta (`player_actions.png` existe, sin configurar).
- Toasts para `notification_requested` (declarada, sin consumidor).
