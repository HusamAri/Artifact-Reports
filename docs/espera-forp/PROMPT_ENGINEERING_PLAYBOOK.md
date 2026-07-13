# ESPERA — Seedance 2.0 Prompt-Engineering Playbook (v2)
_Last updated after auditing jobs 27147697 (soul master), d6a2eac8 (element card), a9a93299 (pendant swap = locked SK1)._

## HARD RULE #-1 — WRITE FOR A MODEL THAT KNOWS NOTHING & REMEMBERS NOTHING
The generator does NOT know who Federica or Husam are, does not remember past shots or the previous
prompt, and will not infer unstated traits from a Soul/element alone. Describe EVERY physical detail
explicitly, from scratch, in EVERY prompt — as if briefing a stranger who has never seen her.
- **NEVER** write "the same woman", "as before", "as the start frame", "she" without first re-introducing
  the full descriptor. Sequential prompts (Shot 1 / Shot 2, or card #2 after card #1) each repeat the
  FULL canonical descriptor from zero — no back-references, ever.
- The only cross-prompt continuity that works is the attached Soul/element + the repeated written descriptor.

## HARD RULE #-2 — DIALOGUE MUST NAME THE ACCENT/LANGUAGE
If a shot has spoken dialogue, state the language AND the accent so the voice sounds natural, e.g.
"spoken in Spanish with a Castilian Spain accent", "Turkish, native Istanbul accent",
"English with a soft Italian accent". Federica = Italian; the man (ES) = Spanish (specify Spain vs Latin);
Husam = Turkish. Never leave a line's accent unspecified.

## CANONICAL PHYSICAL DESCRIPTORS (paste verbatim into every prompt)
**FEDERICA:** early-30s Italian woman; long **fine, THIN dark-brown hair — sparse and flat, NOT thick,
NOT voluminous, no big bouncy volume**, center-parted; thick dark near-joining eyebrows; hazel-green eyes;
freckles scattered across nose and cheeks; lean athletic build; olive-fair Mediterranean skin with real
pores; small mole below the left collarbone. Natural, un-retouched.
**HUSAM:** early-30s man; dark hair short at the sides, longer textured on top; **FULL dark beard**
(not light stubble — real reference is a full beard); olive Mediterranean skin, real pores; lean build.
Wardrobe: plain black t-shirt, over-ear headphones. Canon = face only from behind/silhouette, BUT this rule
is LIFTED for the current video (director's call) — his face MAY be shown. Face-shown → Nano Banana Pro +
his real face photos (7b56878a, 20bd2277, 76e3fe2c, d5a7a1fa) or Husam Soul 76fab95a.

## HARD RULE #0 — @HANDLES GO INLINE IN THE PROMPT BODY (I keep forgetting this)
Every attached element MUST be written by its exact `@handle` **inside the prompt text, at the
exact spot the element appears** — not only in the attachment list. Pendant sentence → `@Necklage-of-Fede`.
Coat sentence → `@Consigliera-palto`. If an element is attached but its handle is not inline, the
prompt is INCOMPLETE — rewrite before sending. (Missed on d6a2eac8-followup and G-A1 v1.)

## HARD RULE #-5 — NO EYE CONTACT WITH THE LENS
Characters must NOT look at the camera. Gaze stays inside the scene — out the window, at the other
character, downward, or off to the side. Direct-to-lens eye contact breaks the film's grammar
(Aronofsky "Mother": half-profile, absorbed, never addressing the camera). Write it in every prompt:
"she/he does NOT look at the camera; gaze directed within the scene, never eye contact with the lens."

## CANON — FEDERICA & HUSAM = PLATONIC BEST FRIENDS (never romantic)
Their bond is a deep, trusting FRIENDSHIP — never a romance. In every Fed+Husam shot stage them as
close friends / allies: side by side, companionable, brotherly-sisterly, shared history, sometimes
confrontational — but NEVER a couple. No romantic gaze, no leaning-in intimacy, no hand-holding, no
lovers' framing. Write "platonic close friends, not a couple, no romantic subtext" in every two-hander.

## CANON — MARMO = MARBLE DOUBLE
Marmo (Federica's mirror-double / reflection in the Mirror Room) is rendered as a MARBLE figure —
a pale carved-marble statue-like version of Federica's face and body, not a normal flesh reflection.
Every Mirror-Room reflection/double = marble. **ATTACH the Marmo element `@Mirror-self` (98969c27)** in
those shots (via <<<98969c27>>> or as a Nano reference) — don't just describe it. Marble finish + Federica's face.

## CANON — ACT V "DOUBLE DEATH" (SK17–21) + THE SURPRISE (SK27)  — from the screenplay, LOCKED
This is NOT a tragic loss and NOT a romance. It is the **death of the OLD selves** so the renewed ones live.
Federica & Husam are platonic — the grief is loyalty, not love.
- **SK17 İzin:** Federica lets go of Marmo's hand, walks to the Venetian mirror. Both face the same way.
  In the mirror world waits **OLD HUSAM** — tired, silent, shoulders down, eyes low (his former, defeated self).
- **SK18 Marmo crosses:** Marmo (marble double) steps forward; the glass accepts her; she passes INTO the mirror
  world and approaches old Husam.
- **SK19 The gesture = PETRIFY (cause of death, director-confirmed):** Marmo places her hand on old Husam's
  **FOREHEAD** (mercy, not violence — not throat, not heart). She uses **Petrify**: his flesh turns to pale marble
  from the point of contact. **His FACE IS VISIBLE this one time** (face-hide rule lifted for the death beat) and
  shows RELEASE/relief — a burden lifting. He kneels, then falls. The petrified body will crumble toward dust.
  On THIS side of the glass a single **gold drop** falls on real Federica's cheek — it does NOT flow, it stops.
  Federica, broken, in Spanish (Spain): *"¡Espera! ¡No!"*
  **→ REVISED ENDING (director, supersedes the old on-screen aftermath):** the moment Federica screams, **HARD CUT
  TO BLACK.** We do **NOT** show what she lived through in that room afterward (Marmo dissolving, real Federica
  emerging, old Husam turning to dust) — it happens off-screen, implied. Scream → black. That is the end of Act V.
- **SK20–21 (old on-screen revelation) = CUT.** Do not build/animate the mirror-room aftermath as shots. The renewal
  is inferred; Husam simply reappears renewed in Şile.
- **Act VI Şile coda (weeks later) — REVISED, song = "Un Segundo Después":**
  · Federica sits alone at the Şile / Black-Sea coast, silent, for a while.
  · Then **Husam (renewed) sits down beside her.**
  · **HUSAM (English + Spanish, "Un Segundo Después" line):** *"You taught me that — sorrow tiene su compás."*
    (verify exact wording with director.)
  · **FEDERICA replies in an ITALIAN accent** — a meaningful line from the song's **FINAL BRIDGE**
    (⚠ lyrics owned by director; DO NOT fabricate — insert the exact line once provided).
  · They **laugh, drink their mojitos** — warm, platonic, alive. End on that.
  (Old coda used "Mar Adentro" + "Aspetta. Sempre aspetta." — treat Un Segundo Después as the new closing song
  unless the director keeps Mar Adentro as the Act VI opener.)
- **THE SURPRISE — SK27 after-credits (never forget):** black. The mirror surface appears, EMPTY, no one, just glass.
  A **hairline crack**. From the crack a single **gold drop** seeps, descends slowly — **does NOT flow, it stops**
  (rhymes exactly with the gold drop on Federica's cheek in SK19). Then SK28 hard cut to black — SON. Meaning: the
  gold (the power / Marmo) is not fully gone; a seed remains. Keep this sting — it is the film's last image.
Keyframe note: Petrify = flesh→pale marble spreading from the forehead contact, then marble→dust; warm-gold vein
accents in the cracks (kintsugi link); real Husam face visible on the death beat only; never neon, never clean-CG.

## HARD RULE #-4 — SOUL ⊕ ELEMENTS: mutually exclusive in the SOUL IMAGE pipeline ONLY
The Soul IMAGE pipeline (`text2image_soul_v2` / soul_2) IGNORES `<<<element>>>` injection and INVENTS the prop
(proof: 0b241cc9 → wreath pendant; 4d2bd1b2 → giant flower brooch — both wrong, from a perfect Soul face).
So in a **soul_2 image** gen you cannot bind elements — use **Nano Banana Pro** + the Soul's OWN real training
photos as face refs (medias) + elements via `<<<id>>>` (winning taksi keyframe 652324a8).
**KLING 3.0 VIDEO — soul_id is accepted at SUBMIT but NOT reliably applied in the RENDER.** Test 91a62b06 passed
`params.soul_id` (eab233e4) + `<<<pendant>>>`; the submit echoed a `soul_reference`, BUT the completed job dropped
soul_id and produced a GENERIC face (not Federica) + a wrong round-medallion pendant. **Conclusion: do NOT trust
Kling text-to-video for identity or precise props.** The reliable route stays **keyframe-first**: bake face+pendant
into an approved Nano keyframe, then animate it as Kling `start_image` (Shots 1 & 2 = perfect face+pendant proof).
Elements can still HELP as reinforcement alongside a start_image, but never as the sole identity/prop source.

## HARD RULE #-3 — PENDANT ON SCREEN ⇒ @Necklage-of-Fede ATTACHED, ALWAYS
Any shot where the pendant is visible MUST attach the `@Necklage-of-Fede` element (74930eee).
Text description alone (or a Soul-only render) makes the model INVENT a wrong pendant — proven by
job 0b241cc9 (Soul, no element → generic wreath medallion). Soul gives the face; the element gives
the pendant. A pendant-visible shot without the element attached is INVALID — do not send it.
⇒ For prop-bearing keyframes use Nano Banana Pro (real face photos + @Necklage-of-Fede + @Consigliera-palto),
NOT Soul-only. Soul-only is fine only when the pendant is out of frame.

## THE ONE LAW THAT OVERRIDES EVERYTHING
**Text negatives cannot beat reference pixels.** Whatever is baked into a reference image
(dome light on, legible neon, blonde hair, wide framing) WILL copy through, no matter how
loudly the prompt says "no." So the fix is never a stronger negative — it's a cleaner source
image. Control the pixels, not the words.

## HERO PIPELINE (mandatory for every hero shot) — face must follow the real uploads
1. **Consistency card (keyframe)** = generate a photoreal HERO STILL with **`nano_banana_2`** (Nano Banana Pro,
   photorealistic, 21:9, 2K/4K, multi-reference). Attach the REAL-PHOTO identity element(s) so the face is
   locked to the uploaded photos. Prompt must demand: "face IDENTICAL to reference photos, real skin texture
   with pores, no smoothing, no beauty retouch, no CGI look."
2. **AUDIT the card** face-to-face against the uploaded reference photos. Approve ONLY if it matches; if not,
   add more real reference photos / rebuild the identity element. This audit is the guarantee.
3. **Animate** the approved card with Seedance 2.0 as `start_image` (+ @Necklage-of-Fede etc.).
Never animate straight from text — the face must be proven in a still first.

## LAYER ARCHITECTURE — where each thing must come from (proven by audit)
| Layer            | Source that WORKS                              | Source that FAILED (never repeat)                    |
|------------------|------------------------------------------------|------------------------------------------------------|
| FACE / identity  | **start_image** keyframe PRIMARY + **@Federica-Clean** (14c961c3, strong) inline to reinforce through motion | weak **`Federica Clean`** (b429aafb, space, 1 photo) → blonde stranger, whole take |
| PENDANT          | element **@Necklage-of-Fede** (74930eee)        | text description alone → generic oval, morphs         |
| COAT             | element **@Consigliera-palto** (d5db280f) OR baked into start_image | — reliable either way |
| CAR interior     | baked into **start_image**, described in text   | element **@araba** (3d6a5b40) → dome ON, İSTANBUL neon legible, framing dragged wide |
| Continuity shot  | previous locked shot's **last clean frame** as start_image | fresh text-to-video → face/set drift |

**Rule of thumb:** face + set come from a *keyframe*; hero props come from *elements*;
environments are NEVER attached as elements on a close-up.

## ELEMENT ID REGISTRY (use exact IDs; never guess)
- `@Necklage-of-Fede`  = `74930eee-cbb5-4c62-9a5b-f11526b736b9`  (prop, RELIABLE — always attach when pendant is on screen)
- `@Consigliera-palto` = `d5db280f-63fb-4166-8473-e680e251d68d`  (coat)
- `@Federica-Clean`    = `14c961c3-0b0f-4012-9d33-0a52afbaf177`  (STRONG character identity, real photos, locked dark-brown hair — reference her face inline by this handle; the ONE correct Federica element)
- `@araba`             = `3d6a5b40-1c94-436c-87cc-ca6a31b99acd`  (environment — EXTERIOR/WIDE ONLY; forbidden on interior CU until @araba-v2 exists)
- `Federica Clean` (b429aafb, WITH A SPACE) = **BANNED** weak single-photo twin of the name. Easy to grab by mistake — always verify the ID is 14c961c3, not b429aafb.
- (Alt identity: `Federica-Final` = c4ddb81e — newer character element; @Federica-Clean stays the canonical handle we write.)

## CANON LOCKS (apply to every prompt)
- **NO gold choker** — struck from the entire film. Do not mention it ever again.
- Bare head — no laurel, no crown, no headband, nothing in hair.
- She rides **ALONE** — no driver, no passenger, no second person in frame.
- Pendant = Foglia d'Oro: royal-blue lapis cabochon in an **openwork gold leaf-cage with rib veins**,
  thin gold chain. **Non-emissive** — matte stone lit only by ambient; never brightens, never morphs
  to a plain oval bezel. (d6a2eac8 over-brightened it → describe as "unlit / no internal glow.")
- Grade: Kodak Vision3 500T pushed +1 (Acts I–II), tungsten amber key, cold blue window fill, deep negative fill.
- Camera law (Aronofsky "Mother"): locked tripod; slow push-ins ONLY on Federica's face; exactly one pan in the whole film (SK21). No handheld, no zoom, no whip.

## PROMPT SKELETON (order matters — camera first, negatives last)
1. **CAMERA & FILM** — body, lens, T-stop, filtration, fps, anamorphic character (oval bokeh, blue streak flare).
2. **FRAMING & MOVE** — eye-line, shot size, the single move, "otherwise locked."
3. **LIGHTING PLOT** — motivated key, fill, what's OFF, negative fill.
4. **SUBJECT** — reference face via keyframe (not a text element); who/where/action, ALONE.
5. **WARDROBE** — @Consigliera-palto (or "as in start frame").
6. **PROP (hero)** — @Necklage-of-Fede inline where the pendant sits; describe non-emissive leaf-cage.
7. **PERFORMANCE (motion budget)** — the 2–3 micro-movements allowed; "nothing else moves."
8. **BACKGROUND** — defocused, no legible text/signage, rain behaviour.
9. **NEGATIVE** — short; only things pixels can't already prevent.

## MULTISHOT RULES
- Declare "N shots, X seconds" up front, then Shot 1 / Shot 2 beats of 2–3 sentences each.
- Combine only same set + same cast + same light. Heroes and big prop-state changes stay solo.
- A phone screen changing (blank→"F") is a fine 2-shot beat; a location change is not.

## PRODUCTION WORKFLOW — two passes, then edit (we were only shooting single masters)
**PASS 1 — MASTERS.** Build + approve the master (hero angle) of each sequence — the spine of the film.
**PASS 2 — COVERAGE & INSERTS ("ara sahneler"), added AFTER the master is locked.** For every key beat, go back and add:
  - alt angle(s) of the SAME moment (reverse / profile / over-shoulder), matched to the master's Contract;
  - inserts / cutaways (pendant CU, hands, phone screen, eyes, rain-on-glass, object detail).
  All coverage shares the master's Constants Lock (identity, makeup, wardrobe, light, grade); only camera changes → clean intercut.
**EDIT.** Assemble master + coverage + inserts into the cut; inserts hide joins and control rhythm.
This is standard film grammar (masters → coverage → inserts → edit) — no beat ships on one angle again.

## MAKEUP = part of costume, director-driven, identity-safe
Makeup is a STYLING layer the director sets per scene; it changes the surface (eye, brow grooming, skin
finish, lip, condition) but NEVER the bone structure, face shape, freckles, or identity — those stay real
(the Soul). Write makeup explicitly in every prompt (Contract §5). Default arc: Act I composed power look →
Acts III–V eroding/tear-worn → Act VI Şile bare. Husam: realistic skin only, no cosmetic makeup.

## STANDING QA LOOP (mandatory every cycle)
1. Write prompt ONLY by filling `SHOT_CONTRACT_TEMPLATE.md` — every Constants-Lock slot filled, nothing forgotten.
2. Deliver prompt + attach list to user; user generates.
3. On the returned video/card: run the frame-teardown audit below, check EVERY Constants-Lock item.
4. Record the result as a new row in `QA_LOG.md` (job id, verdict, findings, root cause, fix).
5. Fold any new failure into the Error Ledger + descriptors so it can't recur. Then ask the user before locking.
Never skip step 4. "Whatever must not drift MUST be in the prompt" — the Contract is how we guarantee it.

## AUDIT PROTOCOL (how I approve)
- ffprobe for fps/res/duration vs Shot Contract.
- Extract first / mid / last + 3 interior frames; read each.
- Diff pendant against @Necklage-of-Fede reference (leaf-cage + veins, not oval).
- Check identity is dark-haired real Federica, dome OFF, no legible signage, ALONE, no choker.
- Name the Error Ledger code, root-cause it to a SOURCE (pixel vs text), then fix the source.

## ERROR LEDGER (live)
- **E11** animated wrong keyframe → verify start_image ID against approved keeper before render.
- **E12** environment element contamination (dome ON + İSTANBUL neon from @araba pixels) → drop @araba on CUs; build @araba-v2 clean.
- **E13** card rewrite dropped "long dark-brown hair" identity line → keep identity descriptors verbatim.
- **E14** wrong/weak character element (b429aafb) → face from Soul keyframe only; b429aafb banned.
- **E15** pendant over-brightened → describe pendant as non-emissive, "no internal glow."
- **E16** scene labels ("FEDERICA SCENE 1 — TAKSI") in a Nano Banana prompt render as burned-in on-image TEXT → never put titles/labels/captions in the image prompt; keep shot names out of the prompt body.
- **E17** wardrobe element pixels override text: `Couture-gown` (c7264fce) renders as a leopard/snake corset, not a plain gown → if you want a specific garment, the element must actually contain it; text alone won't override.

## SOUL IDS (trained identities — best face fidelity, use with soul_2 / soul_cinema_studio)
- **Federica-Combined** = `eab233e4-16c2-4d6c-8594-4d62f8007f70` (soul_2) — NEW master, 14 real photos (all clean uploads combined). Face-guarantee source once verified.
- Husam = `76fab95a-f542-47a4-9bbe-937981c52fef` (soul_2) — his consistency-test / hero identity.
- (older, not used: Federica Zintu 3ec2c83b, Hüsam-legacy 3d2745b3, Baver 8087ed13 soul_cinematic)

## MODEL IDS (image)
- Hero consistency cards → **`nano_banana_pro`** (photoreal, 21:9, 2K/4K, element injection). NOTE: passing `nano_banana_2` silently downgrades to `nano_banana_flash` — always use `nano_banana_pro`.
- Federica identity element that WORKED on the cards: **Federica-Final `c4ddb81e`** (freckles + brows matched the real upload). @Federica-Clean 14c961c3 is the alt.
