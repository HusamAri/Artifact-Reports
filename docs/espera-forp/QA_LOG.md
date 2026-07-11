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

## OPEN FIXES CARRIED FORWARD
- Face master: **Federica-Combined Soul eab233e4** (training) — re-run cards on it once verified.
- Hair: always "fine THIN, not voluminous."
- Never put scene labels/titles in an image prompt (E16).
- Multi-shot = separate shot fields + toggle ON, each shot re-describes subject from zero.
- @araba stays off on interiors until @araba-v2 clean plate exists.
