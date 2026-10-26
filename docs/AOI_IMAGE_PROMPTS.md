# Aoi Bite · Prompts de las ilustraciones

Modo: herramienta integrada `image_gen`. Las imágenes seleccionadas se copian a `assets/aoi/` y se incluyen localmente en Flutter. No se utiliza la API ni el CLI de generación.

Los PNG originales conservan el canal alfa y no se retocan mediante scripts. Los recortes de rostro se realizan únicamente al mostrarlos en la interfaz.

Las cuatro expresiones añadidas para primer error, acierto, pista y final de curso se documentan con sus prompts exactos en [AOI_EMOTION_PROMPTS.md](AOI_EMOTION_PROMPTS.md).

## Variantes con identidad conservada

Referencia utilizada: `assets/aoi/aoi-smirk-v1.png`.

### explain

```text
Use case: identity-preserve. Edit target: the provided Aoi Bite portrait. Create ONE new transparent PNG expression asset for the same adult 25-year-old anime cyborg waifu tutor, not a different character. Preserve the exact character identity from the reference: same adult human facial structure, short messy midnight-blue bob with ivory forelock, same amber natural eye and thin teal cybernetic iris, beauty mark and small temple implant in the exact same positions as image, same high-neck dark opaque top, navy jacket with mint piping, worn brushed-metal prosthetic LEFT arm and shoulder. Preserve organic hand-inked variable line quality, painterly muted shading, subtle blush, skin warmth and imperfections, hair flyaways, cool scratched metal and matte cloth. This is the same Aoi Bite expressing a different mood, with a natural human face and intelligent lively eyes. Square bust portrait, chest-up, complete head and hair inside canvas with breathing room, shoulder/upper prosthetic arm visible, hand gesture only if anatomically clear. Face large and very readable as a game dialogue avatar. No text, no captions, no watermark, no frames, no collage, no multiple figures. Actually transparent alpha background with clean silhouette edges, NO colored background, NO black backdrop, NO atmospheric painted halo. Not photorealistic, not 3D, not plastic skin. No sexualized framing, no juvenile appearance. Change pose and expression only as requested below.
Expression: attentive explanation. Aoi is slightly leaning toward the viewer, mouth gently open mid-explanation, eyebrows engaged, focused warm amber eye contact, a restrained knowing half-smile. Her human right hand makes a relaxed small open-palm explanatory gesture near shoulder height. She looks like an intelligent teasing tutor taking a real interest, not a smiling customer service bot. A slight sideways tilt gives her personal confidence.
```

### skeptic

```text
Use case: identity-preserve. Edit target: the provided Aoi Bite portrait. Create ONE new transparent PNG expression asset for the same adult 25-year-old anime cyborg waifu tutor, not a different character. Preserve the exact character identity from the reference: same adult human facial structure, short messy midnight-blue bob with ivory forelock, same amber natural eye and thin teal cybernetic iris, beauty mark and small temple implant in the exact same positions as image, same high-neck dark opaque top, navy jacket with mint piping, worn brushed-metal prosthetic LEFT arm and shoulder. Preserve organic hand-inked variable line quality, painterly muted shading, subtle blush, skin warmth and imperfections, hair flyaways, cool scratched metal and matte cloth. This is the same Aoi Bite expressing a different mood, with a natural human face and intelligent lively eyes. Square bust portrait, chest-up, complete head and hair inside canvas with breathing room, shoulder/upper prosthetic arm visible, hand gesture only if anatomically clear. Face large and very readable as a game dialogue avatar. No text, no captions, no watermark, no frames, no collage, no multiple figures. Actually transparent alpha background with clean silhouette edges, NO colored background, NO black backdrop, NO atmospheric painted halo. Not photorealistic, not 3D, not plastic skin. No sexualized framing, no juvenile appearance. Change pose and expression only as requested below.
Expression: sharp skeptical teasing. One eyebrow lifted asymmetrically, eyelids a little narrowed, mouth in a small dry crooked smirk with one corner pulled sideways, head turned a few degrees but eyes meeting the viewer. Her human fingertips lightly touch her own chin as if she has caught an obvious mistake. She is mischievous and attractive, playfully unimpressed, never cruel or vacant; warm human microexpression.
```

### exasperated

```text
Use case: identity-preserve. Edit target: the provided Aoi Bite portrait. Create ONE new transparent PNG expression asset for the same adult 25-year-old anime cyborg waifu tutor, not a different character. Preserve the exact character identity from the reference: same adult human facial structure, short messy midnight-blue bob with ivory forelock, same amber natural eye and thin teal cybernetic iris, beauty mark and small temple implant in the exact same positions as image, same high-neck dark opaque top, navy jacket with mint piping, worn brushed-metal prosthetic LEFT arm and shoulder. Preserve organic hand-inked variable line quality, painterly muted shading, subtle blush, skin warmth and imperfections, hair flyaways, cool scratched metal and matte cloth. This is the same Aoi Bite expressing a different mood, with a natural human face and intelligent lively eyes. Square bust portrait, chest-up, complete head and hair inside canvas with breathing room, shoulder/upper prosthetic arm visible, hand gesture only if anatomically clear. Face large and very readable as a game dialogue avatar. No text, no captions, no watermark, no frames, no collage, no multiple figures. Actually transparent alpha background with clean silhouette edges, NO colored background, NO black backdrop, NO atmospheric painted halo. Not photorealistic, not 3D, not plastic skin. No sexualized framing, no juvenile appearance. Change pose and expression only as requested below.
Expression: theatrical comic exasperation. Her human right hand does a small forehead/temple facepalm without covering the eyes. Eyebrows knit dramatically and asymmetrically, eyes half-closed with one eye peeking at the viewer, mouth open in a small exasperated half-laugh/complaint. A hint of warm blush and a loose hair strand across her cheek. Exaggerated human comic timing, still unmistakably the same attractive adult Aoi Bite, not angry abuse, not crying, no stylized drawn symbols or sweat icons.
```


## Imagen principal: sonrisa pícara

```text
Use case: stylized-concept.
Asset type: finished half-body character portrait for an offline Spanish cybersecurity learning app, a transparent PNG game dialogue character.
Primary request: Design Aoi Bite, an original adult anime waifu cybersecurity tutor, age 25, half cyborg, flirtatious, spoiled, smart, sharp tongued, teasing and playfully exasperating, with mischievous comic-villain confidence and real emotional warmth in her eyes. Her appeal comes from expression and presence.
Subject: one adult woman, waist-up three-quarter pose, looking directly at viewer, chin-length tousled midnight-blue hair with one ivory forelock, uneven flyaway strands, slightly asymmetrical expressive amber-brown eyes with a very thin cyan interface ring in her cybernetic left eye, a tiny beauty mark below her right eye. Face overwhelmingly human: soft cheek warmth, subtle under-eye shading, slight smile creases, natural uneven eyebrows and one small healed eyebrow nick. Small mechanical panel at left temple, left shoulder and left arm convincingly prosthetic, brushed graphite/steel joints, hairline seams, tiny screws and lived-in scratches. Her right hand is human, naturally posed, five fingers; mechanical hand rests casually at hip. Dark navy practical jacket with restrained mint/cyan piping worn over an opaque high-neck top; no logos. Confident relaxed shoulders, head slightly tilted, raised eyebrow, a small crooked knowing smirk that says she has already noticed your mistake.
Style/medium: beautiful mature anime character illustration, hand-inked organic variable-weight line art, painterly gouache-like color shading, carefully designed human facial anatomy; subtle deliberate imperfections and asymmetry. Not photorealism, not 3D, not glossy generic AI art, not an android doll. Tasteful adult waifu character, not sexualized.
Composition/framing: isolated single character, full head and hair and both shoulders and hands comfortably inside frame, waist-up, substantial visible human face readable at small sizes. Tall portrait composition, no props, no scene, no panels.
Lighting/mood: warm soft light on human skin, cool restrained teal reflected light on cold metal, gentle matte cloth texture and micro scratches; make the skin feel warm and the metal cool. No neon haze.
Background: genuinely transparent alpha, no background or painted backdrop.
Text: none.
Avoid: words, watermarks, UI, speech bubbles, extra people, duplicate faces, extra fingers, cropped head, sterile perfect symmetry, porcelain/plastic skin, chrome-all-over face, blank robotic eyes, enormous chest, cleavage, lingerie, juvenile or schoolgirl appearance.
```
