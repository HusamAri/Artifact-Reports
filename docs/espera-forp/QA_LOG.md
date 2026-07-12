# ESPERA — QA LOG (every generation audited against its Shot Contract, then recorded)
Protocol per generation: ffprobe (fps/res/dur) → extract first/mid/last + interior frames → check EACH Constants-Lock item → name Error-Ledger code → root-cause to SOURCE (pixel vs text) → verdict → fold the lesson back into template/playbook.

| # | Job ID | Shot | Model | Verdict | Key findings (frame-checked) | Root cause → fix |
|---|--------|------|-------|---------|------------------------------|------------------|
| 1 | f0c17a74 | SK1 v0 720p | seedance | reject | pendant generic oval | Soul can't bind pendant → element pipeline |
| 2 | e2632ea9→7f876117 | SK1 wrong keyframe | seedance | reject | laurel + phantom passenger | E11 animated wrong start_image |
| 3 | 27147697 | SK1 master | seedance | partial | face real ✓, pendant generic oval | needs pendant element swap |
| 4 | a9a93299 | SK1 swap-edit (LOCKED) | seedance | ✅ lock | real Federica + real Foglia d'Oro held 0–8s | pendant element swap works |
| 5 | d6a2eac8 | card (text-to-video) | seedance | reject | blonde face (E14), dome ON + İSTANBUL neon (E12), wide framing | weak elem b429aafb + @araba pixels → Soul keyframe + drop @araba |
| 6 | 45051426 | G-A1 (video-to-video) | seedance | approvable | face real ✓ (Federica-Final), pendant ✓, dome off ✓, framing ✓; multi_shots was OFF → 1 continuous take; faint bg sign | turn Multi-shots ON + separate shot fields; drop @araba |
| 7 | e9ed4a6d F1 Taksi | card | ⚠ redo | pendant+coat+noir ✓; FACE not Federica (user), hair too thick | single weak reference → train Federica-Combined Soul; hair THIN in prompt |
| 8 | 7f942ac3 F2 Ballroom | card | ⚠ redo | pendant ✓; wardrobe=leopard corset not gown (E17); face off | Couture-gown elem pixels; face same as #7 |
| 9 | 9f2c070b F3 Şile | card | ⚠ redo | tattoo+leopard+coast ✓; scene-label TEXT burned in (E16) | remove labels from prompt |
| 10 | f5477bf0 / fee28e8d / 0a0019d6 | H1/H2/H3 Husam | ⚠ redo | from-behind, headphones, grade all ✓; label TEXT burned in (E16) | remove labels; faces hidden so identity N/A |

| 11 | c36d391b | Federica-Combined Soul front test | soul_v2 | ✅ pass | face = real Federica (brows, freckles, hazel eyes, thin flat hair) | Soul VERIFIED as face master |
| 12 | 652324a8 | G-A1 Taksi start_image | nano_banana_pro +5 real photos +pendant/coat | ✅ approve-pending | face real ✓, pendant Foglia d'Oro ✓, thin hair ✓, oxblood coat ✓, 3/4 21:9 noir ✓, alone ✓, no choker ✓ | WINNING recipe for prop-bearing keyframes |
| 13 | 0b241cc9 | G-A1 Taksi (Soul) | soul_v2 | reject as keyframe | face ✓ but pendant = generic wreath (Soul can't bind element), front-facing, 16:9 | use Nano for prop keyframes; Soul for pure face |

| 14 | 49f783d0 | G-A1 v2 video | seedance | REJECT | opens on EMPTY seat; dome ON + legible İSTANBUL neon + wide framing (E12 @araba); hair drifted slicked-back & lighter; multi_shots OFF → 1 take; prompt = OLD block + NEW blocks concatenated → "screen shows F" vs "no legible text" CONTRADICTION; no start_image; audio ON. Pendant+coat correct (elements held). | remove @araba; use start_image; Multi-shots ON w/ separate fields; delete old block (keep clean new blocks only); drop character element; audio OFF |

| 15 | 4d2bd1b2 | Soul+element test | soul_v2 | reject-method | face ✅ real Federica, but pendant = giant FLOWER BROOCH (Soul ignores `<<<element>>>`) | confirms Hard Rule #-4: soul⊕elements impossible in one gen |
| 16 | 1b7becd0 | Şile start_image | nano_pro +face refs +geisha-sirt +leopard | ✅ approve | from behind, geisha tattoo bound ✅, leopard coat ✅, Şile basalt+sea ✅, bare face ✅, thin dark hair ✅, no text ✅ | winning recipe holds for multi-element scenes |
| 17 | 84e6d1fe | Ballroom start_image | nano_pro +Couture-gown | ❌ NSFW-blocked | revealing Couture-gown element + pose tripped filter, no output | re-run with a covered high-neck gown described in text, drop the element |

| 18 | 387c0c8e | Ballroom start_image (re-run) | nano_pro +face refs +pendant, covered gown in text | ✅ approve | real Federica face ✅, high-neck burgundy velvet gown (covered, no NSFW) ✅, Foglia d'Oro pendant ✅, gothic ballroom+candelabra ✅, thin hair ✅, no text ✅ | NSFW fix: describe covered garment, drop revealing element |

| 19 | 74fc631c | Husam studio (face-shown) | soul_2 76fab95a | ✅ (off-script) | real Husam, full beard, black tee+headphones, console amber/cyan | Soul route perfect for Husam; but studio not in board |
| 20 | 937f0e90 | Eski Han corridor (SK5) | nano +Fed faces +Consigliera +pendant | ✅ approve | real face, oxblood coat, Foglia d'Oro, stone han corridor+lanterns |
| 21 | 4ed8e07f | Mirror Room SnakeSilk (SK20-21) | nano +Fed faces +SnakeSilk +pendant | ✅ approve | real face, mirror room+reflection, snake-silk dress, blue pendant |
| 22 | 9b7d2f14 | La Tavola Husam (SK7) | soul_2 76fab95a | ✅ approve | real Husam, dark suit, candlelit restaurant hall |
| 23 | 6c54bc75 | La Tavola Predator (SK10-13) | nano +Fed faces +Predator +obsidian | ⚠ redo | face+pendant ok but DOUBLED into twin Federicas | re-run forcing single figure, no twin/reflection |

| 24 | 1a7c27c4 | Eski Han (gaze-fix) | nano | ✅ approve | gaze off-camera now, coat+pendant+corridor good | Rule #-5 applied |
| 25 | c094b986 | La Tavola Husam (gaze-fix) | soul_2 | ✅ approve | gaze off-camera, real Husam, restaurant hall |
| 26 | 3b5d6861 | La Tavola Predator (single) | nano | ✅ approve | single figure (twin fixed), red fur + gold predator look, obsidian pendant; gaze slightly frontal |

## RULES ADDED THIS SESSION: #-5 no eye-contact-with-lens; Marmo = MARBLE double (attach @Mirror-self 98969c27); Fed+Husam = PLATONIC best friends, never romantic.

## TWO-HANDER START_IMAGES (Nano + both face refs + elements)
- SK9 La Tavola Fed+Husam = a4e6243c ✅ (face-assign correct, gaze off-cam)
- SK15 Fed+Marmo(marble) = 53f2432e ✅ (Marmo = white marble, perfect)
- SK14/18 Marmo+Husam = 30fceab6 ✅
- SK21 revelation Fed+Husam = 1f6eb2af ✅ (platonic, respectful distance)
- SK23-25 Şile Fed+Husam = 010264e7 ✅ (platonic, arm's length)
- SK27 gold-leaf mirror insert = 8f4fd9e2 ⚠ REDO — the real SURPRISE is EMPTY mirror + hairline CRACK + ONE gold drop that seeps from the crack, descends, does NOT flow, STOPS (rhymes with the gold drop on Federica's cheek in SK19). 8f4fd9e2 was gold-LEAF, not this. Rebuild as empty cracked mirror + single frozen gold drop.

## FEDERICA START_IMAGES — LOCKED SET (all via Nano Banana Pro + Soul face photos + scene elements)
- Taksi Act I  = 652324a8  (oxblood coat + pendant, noir)
- Ballroom     = 387c0c8e  (burgundy high-neck gown + pendant, gothic hall)
- Şile Act VI  = 1b7becd0  (geisha tattoo + leopard, from behind)

## POWER-VFX START_IMAGES (baked-VFX technique: effect in the still + material/light physics)
- Gilded Veins (awakening) = **fb7bd695** ✅ (clothed re-run; d3d06252 was NSFW-blocked) — gold veins on neck/hand, pendant blazes
- Marmo Shatter (marble+gold) = **347ef08a** ✅ (clothed re-run; 35ca3bc8 was NSFW-blocked) — kintsugi cracks, shards+gold dust
- (NSFW fix: add "fully clothed/covered, tasteful, no nudity" for power/marble shots)
- **Gold Fall (leaf storm) = 57082eae** ✅ real face, gold leaves swirl, veins glow, pendant blazes, gold lights the room, no neon/CG
- Marmo Shatter (marble+gold kintsugi) = 35ca3bc8
- **The Duel Gold vs Marble (SK16-19) = fed1697d** ✅ Fed gold-veined vs marble double w/ gold kintsugi cracks, both lit, off-cam
Technique win: bake VFX into still + "effect lights its surroundings" + short negatives = film-real power, not neon-CG.

## KLING 3.0 VIDEO PRODUCTION — BATTLE SECTION (i2v from approved keyframes; audit after each, ask user)
| # | Job ID | Beat | Model/mode | Verdict | Frame-checked findings |
|---|--------|------|-----------|---------|------------------------|
| V1 | 99f055ad | Battle Shot 1 — Awakening / Gilded Veins (start=fb7bd695) | kling3_0 · 4k · 5s · silent · 16:9→4424×1872 (~2.36:1) | ✅ PASS | Face=real Federica, held 5s no morph; pendant Foglia d'Oro correct; gold veins pulse+spread & LIGHT the scene (film-real, not neon/CG); gaze off-lens; hand fingers natural no morph; one slow push-in. Minor: pendant emits a strong horizontal gold flare-streak mid/late (anamorphic-ish, on-brand warm gold) — taste call, not a defect. |
| V1b | 37cb15e1 | Battle Shot 1 — Awakening, SOUND version (start=fb7bd695) | kling3_0 · 4k · 5s · **sound ON** | ✅ PASS | Visually equal/better than silent (tighter comp); face held, pendant+veins+light all correct, hand natural, gaze off-lens. Audio = AAC stereo 44.1k present (Kling native; master mix in post). Director rule: render sound ON henceforth. |
| V2 | f8c87754 | Battle Shot 2 — Gold Fall (start=57082eae) | kling3_0 · 4k · 5s · sound ON | ✅ PASS | Face=real Federica held 5s; pendant Foglia d'Oro correct (blazes→calms); gold-leaf storm erupts from hand & LIGHTS the mirror room, gold veins on forearm (GOLD=living palette); gaze off-lens; hands natural; locked cam; end-state settles+holds; audio present. Set in MIRROR ROOM → ties to Act IV. Minor: mid-storm reads fiery/molten (leaf definition lost); multiple mirror reflections (on-theme, but "many Federicas" if unwanted → isolate). |
| V2c | 91a62b06 | Battle Gold Fall — NO start_image, soul_id + pendant element (text-to-video test) | kling3_0 · 4k · 5s · sound ON | ❌ REJECT | (1) FACE not Federica — soul_id accepted at submit (echoed soul_reference) but DROPPED from the completed job params → generic model face. (2) Pendant element bound but Kling rendered a plain round gold medallion, NOT the Foglia d'Oro lapis leaf-cage. (3) Plain black studio, film world lost. VFX (leaves + arm veins) ok but arm veins read electric/CG. **Lesson: Kling text-to-video does NOT reliably carry a Higgsfield Soul identity nor a precise prop element — keyframe-first (start_image from an approved Nano keyframe) remains the only reliable route for identity+pendant.** Correction to the earlier #-4 note: submit-time acceptance ≠ applied in render. |
Kling 3.0 facts confirmed in-tool: full model = mode std/pro/4k + sound on/off + start_image/end_image; NO 21:9 (16:9 req → output came ~2.36:1 anyway); 4k mode renders 3840→4424 wide. Battle shots run SILENT (one master audio pass in post).

## ACT V DEATH-BEAT KEYFRAMES NEEDED (screenplay-locked, see Playbook CANON — DOUBLE DEATH)
- SK17 İzin — Fed releases Marmo's hand, walks to mirror; OLD Husam waiting in glass — NOT YET
- SK18 Marmo crosses INTO mirror toward old Husam — NOT YET
- SK19 PETRIFY — Marmo's hand on old Husam's FOREHEAD; his face VISIBLE, release; flesh→pale marble; gold drop frozen on Fed's cheek — NOT YET (hero VFX beat)
- SK20 Marmo dissolves → REAL Federica emerges; pendant back to blue lapis — NOT YET
- SK21 Revelation — old Husam→dust; NEW/renewed Husam beside real Fed (platonic) — partial (1f6eb2af is Fed+Husam platonic, but not the dust/renewal beat)
- SK22–26 Şile coda — renewed NEW Husam sits beside Fed (weeks later) — have 010264e7 (Şile Fed+Husam platonic); confirm "renewed" styling
- SK27 SURPRISE — empty cracked mirror + one frozen gold drop — REDO (see above)
Have already: fed1697d (Duel gold vs marble SK16-19), 53f2432e (Fed+Marmo SK15), 347ef08a (Marmo Shatter kintsugi).

## OPEN FIXES CARRIED FORWARD
- Face master: **Federica-Combined Soul eab233e4** (training) — re-run cards on it once verified.
- Hair: always "fine THIN, not voluminous."
- Never put scene labels/titles in an image prompt (E16).
- Multi-shot = separate shot fields + toggle ON, each shot re-describes subject from zero.
- @araba stays off on interiors until @araba-v2 clean plate exists.
