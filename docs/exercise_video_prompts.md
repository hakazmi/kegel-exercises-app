# Exercise video prompts (Google Flow / Veo)

17 exercises, one 5-second clip each. All clips share the same man, outfit,
studio, lighting and camera rules so they look like one set in the app.

## How to use in Google Flow

1. **Make the man once (Ingredients).** Generate one full-body reference image
   of the man with the "Character image prompt" below (or use
   `assets/images/onboarding/cutouts/welcome_man.png`). Add it as an
   *Ingredient* in every clip so his face and outfit stay the same.
2. **For each exercise:** paste the **Shared style block**, then the exercise
   prompt, then the **Negative prompt** (if your mode has a negative field,
   put it there; otherwise add it at the end as "Avoid: ...").
3. **Settings:** 16:9, 1080p, Veo highest quality. Veo makes 8 s clips:
   keep the first 5 s (each prompt is timed for 0–5 s) and trim the rest.
4. **Framing for the app:** keep the man centred with space around him, so
   the same clip can be cropped to a square or a circle in the app.
5. Generate 2–4 takes per exercise and keep the cleanest one (no extra
   fingers, no camera drift, correct movement).

---

## Character image prompt (make once)

```
Full-body studio photo of a fit man in his early 30s, light-brown tanned
skin, short dark brown hair styled slightly up, neatly trimmed full dark
beard, calm friendly expression, athletic but natural build. He wears a
plain fitted black short-sleeve crew-neck T-shirt with no logo, plain black
athletic shorts ending mid-thigh, and black trainers with white soles.
Standing relaxed, arms by his sides, facing the camera at a slight angle.
Bright minimal studio with an off-white wall with a faint lavender tint and
a light grey matte floor, soft diffused daylight from the left, gentle
natural shadows. Photorealistic, sharp, 4K.
```

## Shared style block (paste at the start of every clip)

```
Photorealistic fitness instruction video, 5 seconds. The same man in every
clip: early 30s, light-brown tanned skin, short dark brown hair, neatly
trimmed full dark beard, calm focused face. Plain fitted black short-sleeve
T-shirt with no logo, plain black athletic shorts to mid-thigh, black
trainers with white soles. Bright minimal studio: off-white wall with a
faint lavender tint, light grey matte floor, a light grey yoga mat, soft
diffused daylight from the left, gentle realistic shadows. Locked-off
tripod camera: no zoom, no pan, no shake. The man stays fully in frame and
centred with space around him. Slow, smooth, controlled movement at real
speed. Calm and clinical, never sexual. Silent: no music, no voice, only
quiet room tone.

Visual cue for the pelvic floor (used only where the prompt says "glow"):
a soft, translucent green glow appears inside the lower pelvis, just above
the hips and below the navel, like a subtle X-ray highlight seen through
the clothes. It brightens and lifts slightly upward when he squeezes, and
fades when he relaxes. It never highlights the groin or genitals.
```

## Negative prompt (every clip)

```
text, captions, subtitles, labels, numbers, logos, watermark, brand names,
camera movement, zoom, pan, shaking, cuts, extra people, extra limbs, extra
fingers, distorted hands, morphing face, changing clothes, changing hair,
nudity, exposed skin beyond arms and legs, tight close-up of the groin,
genital detail, sexual pose, grimacing, straining, holding breath, red
face, sweating, gym machines, music, voice-over, blurry, low detail,
flicker, jitter
```

---

## 1. Slow hold — `slow_hold`

```
He lies on his back on the grey yoga mat, knees bent, feet flat and
hip-width apart, arms relaxed by his sides, head resting on the mat.
Camera: side view from his left, low at mat height plus 40 cm, full body
from head to feet in frame.
0–1 s: he lies still and breathes calmly; no glow.
1–1.5 s: the green glow brightens and lifts slightly upward in the lower
pelvis while his body stays completely still: no lifting of the hips, no
tightening of the buttocks or belly.
1.5–4 s: he holds; the glow stays steady and bright, and his chest rises
and falls gently with normal breathing.
4–5 s: the glow fades and drops back as he relaxes fully; his face stays
calm.
```

## 2. Quick squeeze — `quick_squeeze`

```
Same position as the slow hold: lying on his back on the yoga mat, knees
bent, feet flat, arms by his sides. Camera: side view from his left, low,
full body in frame.
0–0.5 s: relaxed, no glow.
0.5–1.5 s: a quick squeeze: the green glow flashes bright and lifts, then
fades fully.
1.5–2.5 s: relaxed, no glow.
2.5–3.5 s: a second quick squeeze: the glow flashes bright and lifts, then
fades.
3.5–5 s: fully relaxed and still, breathing calmly. His body never moves;
only the glow pulses.
```

## 3. Strong hold — `strong_hold`

```
He sits upright on a simple light wooden chair with no armrests, feet flat
on the floor hip-width apart, hands resting on his thighs, back tall but
relaxed, shoulders down. Camera: three-quarter front view from his right
at chest height, full body including the chair and feet.
0–1 s: he sits still and takes a calm breath; no glow.
1–1.5 s: the green glow brightens strongly and lifts upward in the lower
pelvis.
1.5–4.5 s: he holds the strong glow steady while sitting tall and still,
breathing normally, face relaxed and focused: no grimace, no shoulder
lifting.
4.5–5 s: the glow fades as he lets go fully.
```

## 4. Standing and walking holds — `standing_walking_holds`

```
He stands tall on the grey studio floor, feet hip-width apart, arms
relaxed. Camera: side view from his left at waist height, wide enough that
he can take three slow steps and stay fully in frame.
0–1 s: he stands still; the green glow brightens and lifts in the lower
pelvis.
1–4 s: keeping the glow steady, he walks three slow, natural steps forward
across the frame, posture upright, arms swinging lightly, breathing calmly.
4–5 s: he stops, stands still, and the glow fades as he relaxes.
```

## 5. Bridge with hold — `bridge_with_hold`

```
He lies on his back on the yoga mat, knees bent, feet flat hip-width
apart, arms by his sides with palms down. Camera: side view from his left,
low at mat height, full body in frame with room above the hips.
0–1 s: the green glow brightens and lifts in the lower pelvis.
1–2 s: he slowly lifts his hips until his shoulders, hips and knees form a
straight line; the glow stays bright.
2–3.5 s: he holds the bridge still, breathing calmly, glow steady.
3.5–4.5 s: he slowly lowers his hips back to the mat.
4.5–5 s: the glow fades as he relaxes.
```

## 6. Squat with coordination — `squat_with_coordination`

```
He stands with feet shoulder-width apart, toes slightly out, hands clasped
loosely in front of his chest. Camera: three-quarter front view from his
right at hip height, full body including feet, with room for the squat.
0–2 s: he slowly squats down, hips back, chest up, knees over toes, to a
comfortable depth; the green glow stays soft and dim (relaxed) on the way
down.
2–2.5 s: at the bottom, the glow brightens and lifts.
2.5–4.5 s: he slowly stands back up while the glow stays bright.
4.5–5 s: standing tall, the glow fades as he relaxes.
```

## 7. Sit-to-stand with squeeze — `sit_to_stand_squeeze`

```
He sits on the light wooden chair, feet flat and slightly behind his
knees, hands resting on his thighs. Camera: side view from his left at
waist height, full body with room to stand up.
0–1 s: seated and relaxed; the green glow brightens and lifts just before
he moves.
1–2.5 s: he leans slightly forward and stands up smoothly without using his
hands; the glow stays bright as he rises.
2.5–3.5 s: he stands tall for a moment, glow steady.
3.5–4.5 s: he sits back down slowly and with control.
4.5–5 s: seated, the glow fades as he lets go.
```

## 8. The Knack — `the_knack`

```
He stands relaxed on the studio floor, feet hip-width apart. Camera:
three-quarter front view from his right at chest height, full body.
0–1 s: standing still, breathing normally; no glow.
1–1.5 s: the green glow brightens and lifts in the lower pelvis, a moment
before he moves.
1.5–3 s: he turns his head slightly and gives one natural, light cough into
the crook of his elbow; the glow stays bright and steady through the cough.
3–4 s: he lowers his arm and stands tall, glow still on.
4–5 s: the glow fades as he relaxes.
(Silent: show the cough as a natural movement only, with no sound.)
```

## 9. Pillow squeeze with lift — `pillow_squeeze_lift`

```
He lies on his back on the yoga mat, knees bent, feet flat, with a small
plain white cushion held between his knees, arms by his sides. Camera:
three-quarter view from his left side at knee height, slightly above, full
body and the cushion clearly visible.
0–1 s: relaxed; no glow.
1–1.5 s: his knees gently press inward into the cushion (small, soft
movement) while the green glow brightens and lifts.
1.5–4 s: he holds the gentle press and the glow steady, breathing calmly.
4–5 s: the knees soften, the cushion relaxes back, and the glow fades.
```

## 10. Diaphragmatic breathing — `diaphragmatic_breathing`

```
He lies on his back on the yoga mat, knees bent, feet flat, one hand
resting on his chest and the other on his belly, eyes softly closed.
Camera: side view from his left, low at mat height, full body.
For this clip the glow is a soft light blue instead of green, meaning
"letting go".
0–2.5 s: a slow breath in through the nose: the belly hand rises clearly
while the chest hand barely moves; the soft blue glow in the lower pelvis
gently widens and settles downward.
2.5–5 s: a slow breath out through the mouth: the belly falls, the blue
glow softens and stays calm. His whole body looks heavy and relaxed.
```

## 11. Reverse Kegel — `reverse_kegel`

```
He sits upright on the light wooden chair, feet flat, hands resting on his
thighs, shoulders relaxed. Camera: three-quarter front view from his right
at chest height, full body including the chair.
For this clip the glow is a soft light blue (release, not squeeze).
0–1 s: still and calm; a faint blue glow in the lower pelvis.
1–3.5 s: he breathes in slowly; his belly softens and expands, and the blue
glow gently widens and drops slightly downward, as if the pelvic floor is
lengthening. No straining, no pushing, face completely relaxed.
3.5–5 s: he breathes out slowly; the glow settles back to its resting
size.
```

## 12. Child's pose — `childs_pose`

```
He kneels on the yoga mat, knees apart, big toes touching, sitting upright
on his heels. Camera: side view from his left at mat height plus 50 cm,
full body.
0–2 s: he slowly folds forward from the hips, sliding his hands forward
along the mat until his arms are stretched out and his forehead rests on
the mat; his hips stay back on his heels.
2–5 s: he rests completely still in the pose and breathes slowly: his
lower back and belly visibly rise and fall with each breath. Calm and
heavy. No glow.
```

## 13. Happy baby — `happy_baby`

```
He lies on his back on the yoga mat. He brings his knees towards his
armpits, knees wide, shins vertical, and holds the outer edges of his
trainers with both hands; head and shoulders stay relaxed on the mat.
Camera: side view from his left, slightly elevated, at the level of his
shoulders and looking along his body from the side: never from the feet
end. Keep framing tasteful and neutral.
0–1 s: he settles into the pose.
1–4 s: he gently rocks a little from side to side, slow and soft,
breathing calmly.
4–5 s: he comes to rest in the middle, still and relaxed. No glow.
```

## 14. Supported back-lying release — `supported_back_release`

```
He lies on his back on the yoga mat in front of a plain light grey sofa,
his calves resting up on the sofa seat so his hips and knees are both at
about 90 degrees, arms relaxed out to the sides with palms up, eyes
closed. Camera: side view from his left at mat height plus 50 cm, showing
his whole body and the sofa.
0–5 s: he lies completely still and relaxed, breathing slowly into his
belly: the belly rises on each breath in and falls on each breath out.
Shoulders soft, face peaceful. No glow.
```

## 15. After-dribble squeeze — `after_dribble_squeeze`

```
A clean, bright, modern bathroom with white tiles and a white sink with a
mirror; the toilet is out of frame. He is fully dressed in the same black
T-shirt and shorts and stands relaxed in front of the sink, as if he has
just finished in the bathroom. Camera: three-quarter view from behind his
right shoulder at chest height, showing him from head to knees and the
sink. Nothing private is shown.
0–1 s: he stands still and relaxed.
1–1.5 s: a firm green glow flashes in the lower pelvis and lifts upward
(one firm squeeze).
1.5–3 s: he holds it for a moment, standing tall, face neutral.
3–3.5 s: the glow fades as he lets go fully.
3.5–5 s: he turns on the tap and starts washing his hands.
```

## 16. Urge-control squeeze — `urge_control_squeeze`

```
A bright, tidy home hallway with a front door, light walls and a wooden
floor. He has just stepped in through the front door, keys in one hand,
and has a sudden urge to go to the toilet. Camera: three-quarter front view
from down the hallway at chest height, full body, static.
0–1 s: he stops completely and stands still instead of rushing; his
shoulders drop and he takes a slow breath.
1–3 s: three gentle soft green pulses glow and lift in the lower pelvis,
one after another, while he stays still, breathing slowly, face calm and
in control.
3–4 s: the glow fades; he relaxes, puts the keys down on a side table.
4–5 s: he walks calmly (not rushing) down the hallway and out of frame.
```

## 17. Brisk walking — `brisk_walking`

```
A quiet, green park path on a bright morning with soft sunlight, trees and
grass, no other people. He walks briskly along the path with an upright
posture, arms swinging naturally, purposeful pace, light confident
expression. Camera: smooth side-on tracking shot at chest height that moves
with him so he stays centred in frame (this is the only clip where the
camera moves). Full body visible.
0–5 s: steady brisk walking, natural arm swing, even pace. No glow.
```

---

### Notes

- **Glow colours:** green = squeeze and lift; light blue = relax and let go
  (diaphragmatic breathing, reverse Kegel). Stretch and walking clips have
  no glow. This matches the colours used in the app.
- **If the glow lands in the wrong place:** add "the glow is centred just
  above the hip bones, below the navel, never lower".
- **If Veo adds sound or music:** say "completely silent video" at the
  start of the prompt as well.
- **If the man changes between clips:** re-attach the same character image
  as an Ingredient and repeat the exact outfit sentence.
- **Habits (15–16) are tasteful on purpose:** after-dribble is shown at the
  sink, fully dressed, with no toilet or private parts in view; urge control
  is shown in the hallway. This keeps the app store-safe.
- **For the app:** export MP4, then send them to me. I'll compress them
  (about 100–200 KB each), cut them to exactly 5 s, and add them to the
  exercise info sheets and session screens.
