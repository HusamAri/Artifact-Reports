# ESPERA — Skill Sets & Directing Techniques (permanent, applied)

Power register (director's call): **FULL supernatural / VFX**. Placement: **BOTH** — the Mirror-Room
climax (SK16–19) escalates into a power beat, AND a separate dedicated action sequence is added.
Visual law for all power VFX: warm amber-GOLD only, volumetric haze, heavy 35mm grain, real gravity/physics,
**never neon, never clean-CG**. Gold = Federica (warm, living). Marble = Marmo (cold, double). Kintsugi (gold in
the cracks) is the shared motif that binds them.

---
## FEDERICA — "L'Oro / the Gold"  (source: Foglia d'Oro pendant, gold-leaf power)
Signature palette: molten gold, drifting gold leaves, amber shimmer against indigo/black.
- **Passive — Gilded Veins:** when power stirs, gold blooms beneath her skin; molten-gold veins trace up
  her neck and arms; the lapis in the pendant flares warm gold at its core.
- **Q / Signature — Gold Fall:** she opens her hand and a storm of razor gold leaves erupts and sweeps
  outward, catching light like blades.
- **W — Foglia Shield:** gold leaves spiral into a shimmering barrier/veil around her.
- **E — Midas Touch:** what she touches gilds and hardens to gold (the counter to Marmo's marble).
- **R / Ultimate — GOLD FALL: FINALE:** a vertical eruption of molten gold and a blizzard of leaves;
  the frame drowns in warm gold light and shard-leaves; the pendant blazes, then goes matte.
Prompt kit (paste when she uses power): "gold blooming beneath the skin, molten-gold veins glowing, a storm
of razor-edged gold leaves swirling with real weight and gravity, warm amber gold light, volumetric haze,
heavy 35mm film grain, never neon, never clean CG."

## MARMO — the Marble Double  (source: @Mirror-self 98969c27; Federica's reflection)
A pale carved WHITE-MARBLE version of Federica — same face, marble skin. Cold to Fede's warm.
- **Passive — Marble Form:** statue-still polished marble; animates with a stone grind; hairline cracks
  trace GOLD when struck (kintsugi link to Federica).
- **Q — Mirror Step:** dissolves into one mirror, emerges from another; travels through reflections.
- **W — Petrify:** gaze/touch turns flesh to pale marble, freezing motion.
- **E — Fracture:** marble limbs crack and reform, shedding marble shards.
- **R / Ultimate — SHATTER:** her marble body cracks along gold veins and bursts into a storm of marble
  shards and gold dust, then reforms inside a mirror.
Prompt kit: "a pale carved white-marble statue-woman with Federica's exact face, smooth polished marble skin,
hairline cracks traced with gold (kintsugi), marble dust, cold desaturated white-grey with warm-gold vein
accents, statue texture, never plastic, never neon."

## THE DUEL (theme)
Fede (warm living gold) vs Marmo (cold marble double) = two halves of one self. Their clash reads as
GOLD vs STONE; kintsugi gold in Marmo's cracks says they were always the same.

---
## DIRECTING TECHNIQUE MAP  (right technique → right shot)  [best-practice researched, 2026]
**Governing model:** the frame is where you direct PRECISION; the video model is where you direct MOTION.
Lock look/identity/VFX in a STILL (Nano Banana Pro / Soul Cinema), then hand Seedance a small, unambiguous
motion job. Every failure traces to asking the video model to invent what you should have baked into the frame.

**1. Consistency.** Soul ID anchors any recurring hero (locks identity, NOT wardrobe/props → pair with elements).
Nano Banana Pro multi-ref = one-off face lock, best at **≤6 clean refs** (more averages into "no one").
Priority when they conflict: **Soul > start_image > multi-ref > text.**

**2. Keyframe-first.** Nano/Soul-Cinema still → approve → Seedance **image-to-video** + one-line motion.
Text-to-video only for abstract inserts. Shot must ARRIVE at a target (transformation end / match-cut) →
give **first AND last frame**, model interpolates between locked endpoints.

**3. Coverage that cuts.** Prefer **separate gens from the SAME locked refs** over one mega multi-shot
(single-gen multi-shot degrades per-shot quality). Master + reverse + insert from one keyframe set. State
**screen direction** (who faces frame-left/right) or reverses flip eyelines and won't cut (180° line).

**4. Camera — ONE move per shot (iron rule).** static / slow push-in / dolly-out / pan / tilt / track / orbit /
crane — pick ONE, add speed+stabilizer ("slow 3s dolly in, gimbal, stabilized"). Static must be said
("locked-off, tripod, no camera movement"). Slow = clean; fast = warped faces/geometry. Hard move → feed a
**video reference** of the path, or `motion_control`. Our film: locked tripod; push-in only on Federica's face; one pan (SK21).

**5. Power VFX (Gold Fall / marble).** BAKE the effect into the start_image (gold veins glowing, leaves mid-air,
marble skin) → then animate. Describe **material + light physics**, not "magic": the effect must LIGHT its
surroundings ("gold glow spills warm onto her cheek and the wall"). Anchor "35mm, volumetric light, real-world
physics, practical in-camera"; forbid "neon, 3D-render/CG look, cartoon, plastic sheen." Big transformation →
**split across 2 clips** at a flash/whip/impact (one clip A→Z = mush). Hardest hero VFX → composite plate + effect
pass, then video-to-video to marry grain.

**6. Transitions.** Match cut / morph / flash = design the two ENDPOINTS to rhyme (shared shape/rotation/centroid),
cut in the edit — don't ask one gen to "do a transition." Hard optical: bake a white frame; next clip "continue from the white flash."

**7. Continuity.** Constants-lock (same descriptors + same elements every shot — continuity = sameness of inputs).
Negatives are **scalpels: 5–15 observed tokens**, never a 40-token block. Role-tag refs vs contamination. Direct
gaze positively; "looking at camera" negative only if it persists.

**8. Finish.** Upscale AFTER the edit locks (`upscale_video`; Topaz Astra). Author native 21:9, `reframe`/`outpaint`
DOWN to 9:16/1:1 (never up). ONE master grade + a SINGLE grain pass (~15–20) over the whole locked timeline.
Audio: `generate_audio` + lip-sync; specify accent/delivery; keep the mouth visible (front-3/4) on speaking lines.

### FAILURE → CAUSE → FIX
| Failure | Cause | Fix |
|---|---|---|
| Face drift | text identity / clip too long / big motion | Soul + start_image; shorten; cut before drift |
| Prop/wardrobe morph | described not locked | element every shot; bake into keyframe |
| Doubled figures | ambiguous count / big move | state exact count; negative `double,extra person`; slow camera |
| Wrong framing | trusting text for layout | author the frame in NBP; start_image (+end frame) |
| Burned-in text | hallucinated signage/labels | negative `text,watermark,subtitles`; NEVER put labels in the prompt |
| Camera drifts/nothing | no/too-many moves | one move + stabilizer; static = "locked-off tripod" |
| Neon/CG-cheap VFX | "magic"-level prompt | bake VFX in still; material+light physics; regrain |
| Morph mush | endpoints share no geometry | rhyme start/end; split across 2 clips |
| Subject stares at lens | model default | direct gaze positively; negative only if persists |
| Shots don't feel like one film | per-shot grade/grain | one master grade + single grain pass on locked timeline |

**Caveats:** single-gen multi-shot degrades quality (prefer separate gens from shared refs for clean cuts);
vendor numeric caps shift between versions — verify in-tool. Principles are stable, numbers are not.
