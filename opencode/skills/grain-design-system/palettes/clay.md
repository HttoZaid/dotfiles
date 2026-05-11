# Clay Palette

**Mood:** Warm · Earthy · Confident · Human
**Best for:** SaaS products, productivity apps, dashboards, general-purpose apps
**Avoid for:** Healthcare (too warm), finance (too casual), dark-mode-first tools

## Color Ramp

```
Name        Token       Hex         RGB              Use
────────────────────────────────────────────────────────────────────
Clay 50     clay-50     #FDF3EA     253, 243, 234    Accent bg tint
Clay 100    clay-100    #FAE2C8     250, 226, 200    Badge bg, active nav
Clay 200    clay-200    #F5C99A     245, 201, 154    Hover tint
Clay 300    clay-300    #EFA868     239, 168, 104    Decorative accent light
Clay 400    clay-400    #E48540     228, 133, 64     Secondary accent
Clay 500    clay-500    #D97530     217, 117, 48     ★ PRIMARY ACCENT
Clay 600    clay-600    #B85C20     184, 92, 32      Hover state
Clay 700    clay-700    #8F4416     143, 68, 22      Text on light bg
Clay 800    clay-800    #66300F     102, 48, 15      Dark text on clay
Clay 900    clay-900    #3D1C08     61, 28, 8        Deepest dark
```

## Neutral Ramp (Stone)

```
Stone 50    stone-50    #F7F6F3     247, 246, 243    Page bg
Stone 100   stone-100   #EEECEA     238, 236, 234    Subtle bg
Stone 200   stone-200   #E0DDD7     224, 221, 215    Border default
Stone 300   stone-300   #C8C4BB     200, 196, 187    Border strong
Stone 400   stone-400   #A09B8E     160, 155, 142    Text tertiary
Stone 500   stone-500   #7A756A     122, 117, 106    Text secondary
Stone 600   stone-600   #5C5850     92, 88, 80       —
Stone 700   stone-700   #3D3B35     61, 59, 53       —
Stone 800   stone-800   #28261F     40, 38, 31       —
Stone 900   stone-900   #1C1A16     28, 26, 22       Text primary
Stone 950   stone-950   #0F0E0B     15, 14, 11       Deepest (dark mode bg)
```

## CSS Custom Properties

```css
:root {
  /* Palette identity */
  --accent:         #D97530;
  --accent-hover:   #B85C20;
  --accent-subtle:  #FDF3EA;

  /* Surfaces */
  --bg:             #F7F6F3;
  --bg-raised:      #FFFFFF;
  --bg-subtle:      #EEECEA;

  /* Borders */
  --border:         #E0DDD7;
  --border-strong:  #C8C4BB;

  /* Text */
  --text-primary:   #1C1A16;
  --text-secondary: #7A756A;
  --text-tertiary:  #A09B8E;

  /* Semantic */
  --success:        #3A8F54;
  --success-subtle: #EEF6F1;
  --warning:        #B87C08;
  --warning-subtle: #FDF4E0;
  --danger:         #BE3030;
  --danger-subtle:  #FDEEEE;
  --info:           #2E5CA0;
  --info-subtle:    #EBF0F8;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg:             #0F0E0B;
    --bg-raised:      #1C1A16;
    --bg-subtle:      #28261F;
    --border:         #3D3B35;
    --border-strong:  #5C5850;
    --text-primary:   #F7F6F3;
    --text-secondary: #A09B8E;
    --text-tertiary:  #7A756A;
    --accent-subtle:  #3D1C08;
  }
}
```

## Recommended Font Pairing

**Primary:** DM Serif Display + DM Sans + DM Mono (see `fonts/dm.md`)
**Alternative:** Fraunces + Nunito + Jetbrains Mono (see `fonts/humanist.md`)

## Accent Color Psychology

Clay is burnt orange — warm, grounded, confident. It reads as "human" and "approachable"
without being playful. It pairs naturally with warm stone neutrals.
Avoid using it for medical or financial products where orange can signal caution.
