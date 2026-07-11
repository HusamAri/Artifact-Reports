# Kling 3.0 — Prompting & Directing Guide (ESPERA, applied)
Verified against official Kling docs + practitioner guides, 2026. Model in Higgsfield: `kling3_0_turbo`
(720p/1080p, 3–15s, start_image, 16:9/9:16/1:1). NOTE: full Kling 3.0 also has Native Audio+lip-sync and
Multi-Shot; the Higgsfield **Turbo** variant may not expose them — verify in-tool before relying on audio/multishot.
**No 21:9** in Kling → master 16:9, reframe to 21:9 in the edit.

## PROMPT FORMULA (cinematic prose, NOT comma-tag salad)
Order Kling obeys: **Camera (framing + ONE move) → Subject anchor → Action (physics verbs + weight/contact +
staged emotion) → VFX (material + reflected light + volumetric) → Lighting/mood → Time (how it unfolds + END-STATE).**
- **Text-to-video: 30–60 words.** **Image-to-video: 15–40 words, MOTION ONLY** — never re-describe what's already
  in the start_image (the image is a hard anchor; re-describing reintroduces drift).
- Always give an **end-state** ("…then settles and holds") or renders hang at 99%.

## CAMERA — ONE move per shot (hard limit)
Two moves in one clip warps. To change angle WITHIN one flowing take → use ONE traversing move:
"slow dolly-in that drifts from a wide two-shot into a tight close-up as she turns, then holds." Temporal
connectors: as / while / until it settles / then holds. For genuinely different ANGLES → Multi-Shot (≤6, one move
each) but those are CUTS, not one uncut take. Vocabulary (one per shot): static / slow push-in / pull-out / dolly
L-R / track / tilt / pan / handheld drift / crane / orbit (**≤30°**). Avoid "fast", whip-pan, crash-zoom, combined moves.

## BODY / MOTION / PHYSICS
One primary action per clip; hero performance **5–10s** (15s only for simple low-morph motion). Describe mechanics
not labels ("foot lands heel-first, rolls forward"). **Anchor hands to objects** ("hand gripping the railing") —
free-floating hands are the #1 morph trigger. Stage emotion in phases ("brow lifts, barely at first, then more").

## VFX / POWERS (Gold Fall, marble) — the "not cheap CG" rules
1. **Bake the effect into the start_image** (glowing veins, cracked marble already present) → prompt Kling only to
   ANIMATE/intensify it. Biggest quality lever.
2. Name **material physics**: "molten gold, liquid-metal specular, subsurface glow; polished marble veining;
   hairline fractures spreading under stress."
3. **Effect must LIGHT its surroundings**: "gold veins cast warm reflected light onto the marble and drifting dust,
   volumetric shafts." (Pasted-on = no cast light = CG look.)
4. Kinetic verbs: pulse, rush, spread, shatter, tumble, swirl, drift.
5. **Transformations → Start + End (tail) frame** (intact marble → full gold kintsugi); Kling interpolates. (Locks
   out Multi-Shot for that clip.) **Split** big transforms across 2 clips at a beat; slow the effect down.

## DIALOGUE / ACCENTS
Full Kling 3.0 = **Native Audio + true lip-sync**, languages **English & Spanish** (+ ZH/JA/KO), accents
prompt-driven. Syntax: action FIRST, then line — `[action]; [Speaker], in a [accent/tone] voice, says "[short line]"`.
Short simple lines sync best; keep the speaking face visible; single speaker <7s. For a PRECISE/consistent accent
across many clips → generate silent + dub in post (ElevenLabs) + lip-sync. **Our lines:** ES "Ya casi. Espérame." =
Spanish (Spain/Castilian); Federica = Italian-accented; Husam = Turkish (NOT a native Kling language → dub Husam's
Turkish lines in post).

## NEGATIVES (separate field, bare comma tags, 6–12, top term weighted most)
Base: `blur, distort, low quality, warping fingers, frozen lips, jittery eyes`
Body: `+ deformed hands, extra fingers, rubber limbs, morphing body parts, sliding feet`
VFX/marble: `+ cheap CG, plastic look, flickering, geometric distortion, floating debris`

## SETTINGS  (Higgsfield full `kling3_0`, verified in-tool)
mode = **std / pro / 4k** (4k = highest quality — director prefers 4k). medias = **start_image + end_image**. Aspect
16:9/9:16/1:1 → NO 21:9 (16:9 4k output came ~4424×1872 ≈ 2.36:1 anyway; reframe to true 21:9 in edit). **5–10s**,
one move, one action, VFX baked into start_image.
- **SOUND = `on` — DIRECTOR RULE (always, "ne olur ne olmaz").** Do NOT render silent even for wordless VFX beats;
  Kling's native audio comes along "just in case" and we still do a master pass in post. (Earlier silent default was WRONG.)
- **MULTI-SHOT: when a scene has more than one shot, ENABLE multi-shot** (`multi_shots: true` + separate `multi_prompt`
  shot fields, one move each) — never cram multiple shots into one prose field. Single continuous beat = single shot, no multishot.

## FAILURE → FIX
hang@99% → add end-state · morph/rubber → anchor hands+lean negative+5–10s · warp on move → one slow move, orbit ≤30°
· cheap-CG VFX → bake in frame + reflected light + start/end frame · face morph → stage emotion in phases · prompt
ignored → 30–60 words, fixed labels · bad lip-sync → face visible, short lines, single speaker.

## WORKED EXAMPLE (i2v power scene, start+end frame)
Start=intact marble, End=full gold kintsugi. Prompt (~40w): "Static locked-off shot, faint handheld drift. Hairline
fractures spread across the marble with weight, shards trembling; molten gold rushes along the cracks and pulses
with light, casting warm reflected glow onto the marble and drifting dust in volumetric shafts. Slow, epic, cinematic."
Negative: `cheap CG, plastic look, flickering, geometric distortion, floating debris, blur, distort, low quality`.
