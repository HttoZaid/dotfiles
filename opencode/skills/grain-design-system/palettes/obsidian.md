# Obsidian Palette

**Mood:** Dark · Dramatic · Developer tool · Night-first
**Best for:** Code editors, terminal tools, dev dashboards, dark-mode-first products
**Avoid for:** Consumer apps, wellness, food

## Color Ramp (Accent: Electric Cyan)

```
Cyan 50     #E8FFFE    Lightest tint (barely visible on dark)
Cyan 100    #B4F8F4    Badge bg
Cyan 200    #7AF0EA    Hover tint
Cyan 300    #3AE4DC    Light accent
Cyan 400    #0ECFC6    Secondary accent
Cyan 500    #00B8AE    ★ PRIMARY ACCENT
Cyan 600    #008C84    Hover state
Cyan 700    #006660    Text on dark bg
Cyan 800    #004440    Dark
Cyan 900    #002220    Deepest
```

## Dark Surface Ramp

```
Void 950    #0C0C0E    Page bg (near-black)
Void 900    #141418    Cards, panels
Void 800    #1E1E24    Subtle bg, inputs
Void 700    #2A2A34    Border default
Void 600    #3A3A48    Border strong
Void 400    #6E6E88    Text tertiary
Void 300    #9898B0    Text secondary
Void 100    #E0E0F0    Text primary
```

## CSS Custom Properties

```css
:root {
  --accent:         #00B8AE;
  --accent-hover:   #008C84;
  --accent-subtle:  #002220;
  --bg:             #0C0C0E;
  --bg-raised:      #141418;
  --bg-subtle:      #1E1E24;
  --border:         #2A2A34;
  --border-strong:  #3A3A48;
  --text-primary:   #E0E0F0;
  --text-secondary: #9898B0;
  --text-tertiary:  #6E6E88;
  --success:        #2ABA62;
  --success-subtle: #0A2418;
  --warning:        #E8A020;
  --warning-subtle: #241A04;
  --danger:         #E84040;
  --danger-subtle:  #240A0A;
  --info:           #00B8AE;
  --info-subtle:    #002220;
}
```

## Recommended Font Pairing

**Primary:** DM Serif Display + DM Sans + DM Mono (see `fonts/dm.md`)
**Alternative:** Zilla Slab + Lato + Source Code Pro (see `fonts/slab.md`)
