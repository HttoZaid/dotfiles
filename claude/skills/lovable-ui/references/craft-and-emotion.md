# Craft and emotion: turning "fine" into "lovable"

Read this for Stage 2 — what to add once the design is fluent. Craft is the felt sum of hundreds of fluency-respecting microdecisions.

## Norman's three levels of emotional design

Design for all three at once; lovable products refuse to trade them off.

- **Visceral** — immediate, subconscious gut reaction to appearance. This is where the 50ms impression and the aesthetic-usability halo live. Materiality, restraint, "want to touch it."
- **Behavioral** — the felt experience of *use*: usability, performance, responsiveness, a sense of control and competence.
- **Reflective** — the slowest, most personal layer: meaning and identity. What does using this say about me? ("I use Linear → I have taste.") This is what creates belonging, not just utility.

## Kahneman: System 1 / System 2

System 1 = fast, automatic, emotional, runs the vast majority of judgments. System 2 = slow, effortful, lazy. First impressions and "this feels trustworthy" are System 1 outputs — which is why visceral design dominates initial perception, and why a confusing UI that forces System 2 effort feels unpleasant. Design the System 1 path to be effortless; reserve deliberate effort for moments that deserve it.

## Cognitive load laws (why simplicity feels good)

- **Sweller's Cognitive Load Theory** — intrinsic (task difficulty), extraneous (imposed by bad design), germane (productive). Slash extraneous load.
- **Hick's Law** — decision time grows with number/complexity of options. Fewer choices per step; progressive disclosure.
- **Miller's Law** — working memory ~4 reliable chunks. Chunk and categorize.
- **Jakob's Law** — users expect your site to work like the others they know. Predictability lowers vigilance and builds trust; inconsistency forces re-learning (extraneous load) and signals carelessness.

## Peak-end rule

Memory of an experience is dominated by its emotional **peak** and its **ending**, not its average (Kahneman & Fredrickson cold-pressor studies). So deliberately engineer: one genuine delight peak (a celebratory success state, an Easter egg, a beautiful empty state) and a graceful ending (satisfying completion, considerate error/empty states). Onboarding that ends on a high (Arc's membership card) is remembered fondly regardless of the middle.

## Microinteractions (Saffer)

Small, single-purpose moments: a toggle's animation, a like, pull-to-refresh, a hover state, the confirmation pulse. They make primary actions feel alive and responsive, and they're where delight and craft concentrate. Stripe injecting the developer's real API key into doc samples is a microinteraction that says "a human thought about you."

## Motion timing (why eased motion feels natural)

Real objects accelerate/decelerate; biological-motion perception expects inertia, so eased motion feels right and linear feels robotic. Synthesized from Material/HIG + practitioners:

- Most UI transitions: **200–500ms**. <100ms reads instantaneous; >1s reads as lag.
- Hover/feedback: ~100–300ms.
- **Entering** elements: ease-out (decelerate to rest). **Exiting**: ease-in (accelerate away). **Moving between states**: ease-in-out.
- Reserve overshoot/bounce for genuine delight moments only.
- Stagger related elements ~40–120ms (Gestalt common fate / Disney "overlapping action").
- Motion should *clarify* (show where things come from and go), not decorate. Always honor `prefers-reduced-motion`.

Disney's 12 principles (Johnston & Thomas, *The Illusion of Life*, 1981) — slow-in/slow-out, arcs, anticipation, staging, follow-through — are the canonical source for natural motion and translate directly to UI.

## The "less but better" lineage

- **Dieter Rams' ten principles** — good design is innovative, useful, aesthetic, understandable, unobtrusive, **honest**, long-lasting, thorough, environmentally friendly, and **as little design as possible**. Two matter most for trust: *honest* (no manipulation) and *as little as possible* (restraint). Braun T3 radio → iPod is the visible lineage.
- **Apple HIG** distills this to **clarity** (legibility, precision, "Send Payment" > "Submit"), **deference** (UI recedes so content leads), **depth** (layers/motion convey hierarchy).
- **The through-line**: Bauhaus → Ulm School → Rams/Braun → Apple (via Ive).
- **Japanese aesthetics** run in parallel: *Ma* (間, active negative space as a living interval that lets elements and the mind breathe), *wabi-sabi* (beauty in imperfection/restraint), *shibui* (understated elegance). Whitespace is a designed element signaling confidence and quality — not absence.

## Honest design vs. dark patterns

Deceptive patterns (Brignull, 2010; deceptive.design) work in the short term — drip-pricing field experiments showed buyers spent ~21% more and were ~14% likelier to complete a purchase — but they corrode the trust that fluency and beauty build, and are increasingly illegal. Durable love is built on transparency. The same behavioral levers (variable reward, loss aversion, streaks) can serve the user's real goal (genuine habit, competence) or exploit them; aim them at the user, not against them.
