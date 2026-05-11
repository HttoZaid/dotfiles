# Slate Palette

**Mood:** Cool · Professional · Trustworthy · Focused
**Best for:** B2B SaaS, dashboards, enterprise tools, data products, finance
**Avoid for:** Consumer apps (too cold), wellness (too clinical)

## Color Ramp

```
Slate 50    #EBF0F8    Cool sky tint — accent bg
Slate 100   #CCDBF0    Badge bg, active nav
Slate 200   #9DBAE0    Hover tint
Slate 300   #6E98CE    Light accent
Slate 400   #4878BA    Secondary accent
Slate 500   #2E5CA0    ★ PRIMARY ACCENT
Slate 600   #234880    Hover state
Slate 700   #1A3460    Text on light bg
Slate 800   #112248    Dark text on slate
Slate 900   #0A1530    Deepest dark
```

## Neutral Ramp (Cool Gray)

```
Gray 50     #F4F5F7    Page bg (slightly cool)
Gray 100    #E8EAED    Subtle bg
Gray 200    #D3D6DC    Border default
Gray 300    #B0B5BF    Border strong
Gray 400    #8B909A    Text tertiary
Gray 500    #676D78    Text secondary
Gray 700    #393E47    —
Gray 900    #1A1D22    Text primary
Gray 950    #0D0F12    Dark mode bg
```

## CSS Custom Properties

```css
:root {
  --accent:         #2E5CA0;
  --accent-hover:   #234880;
  --accent-subtle:  #EBF0F8;
  --bg:             #F4F5F7;
  --bg-raised:      #FFFFFF;
  --bg-subtle:      #E8EAED;
  --border:         #D3D6DC;
  --border-strong:  #B0B5BF;
  --text-primary:   #1A1D22;
  --text-secondary: #676D78;
  --text-tertiary:  #8B909A;
  --success:        #1E7A40;
  --success-subtle: #E8F5EE;
  --warning:        #9A6400;
  --warning-subtle: #FEF8E8;
  --danger:         #C02020;
  --danger-subtle:  #FCEAEA;
  --info:           #2E5CA0;
  --info-subtle:    #EBF0F8;
}
```

## Recommended Font Pairing

**Primary:** Plus Jakarta Sans + Inter + IBM Plex Mono (see `fonts/geometric.md`)
**Alternative:** Work Sans + Manrope + Roboto Mono (see `fonts/neutral.md`)
