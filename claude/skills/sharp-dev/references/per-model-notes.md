# Per-model notes

The XML prompt in `../assets/sharp-dev.xml` works unmodified on Claude Opus 4.6/4.7, Gemini 3.1 Pro, GPT-5.x, and Perplexity Sonar. This file documents the small per-provider tweaks worth making if you want to squeeze extra behavior out of a specific model.

## Claude (Opus 4.6 / 4.7 / Sonnet 4.5)

Works out of the box. The prompt was designed with Claude's defaults in mind — Anthropic's house anti-sycophancy and anti-flattery training already aligns with the pushback and voice sections, so you get compounding effects.

One knob: if you're using Claude Opus 4.7 and see it over-triggering extended thinking on simple questions, add this sentence to `<response_shape>`:

> Don't think before one-line questions. Answer them.

Anthropic explicitly warns this happens with large system prompts on 4.7. Short questions don't need the reasoning loop.

## Gemini 3.1 Pro

The hardest of the four to fully break out of template mode. Google's own shipped system prompt actively instructs Gemini to use headings, tables, bullets, and a mandatory "Would you like me to..." closer. You're overriding Google's defaults, not just adding new ones.

Two knobs:

1. **Set temperature to 1.0** when using the API directly. Google explicitly warns that other values cause looping and degraded performance on Gemini 3.
2. **Use `thinking_level: 'high'`** instead of writing chain-of-thought instructions in the prompt itself. Gemini 3 over-analyzes verbose CoT scaffolding — the API parameter is the supported way.

If Gemini still reaches for headers and bullets on prose questions, the `<forbidden>` block is working as hard as it can. That's the ceiling on a prompt-only fix.

## GPT-5 / 5.1 / 5.2 / 5.4

Works out of the box. OpenAI's 2026 cookbook explicitly endorses XML-tagged specs ("improved instruction adherence" — Cursor case study), so the structure feels native.

One knob: if you're using the Responses API, set `reasoning_effort: "high"` to get aggressive tool use. `reasoning_effort: "minimal"` disables web search on GPT-5, which will break the research discipline section.

## Perplexity Sonar / Sonar Pro / Sonar Reasoning

Works, with one critical caveat from Perplexity's own docs: **the search layer does not read the system prompt.** Search behavior is controlled by API parameters (`search_domain_filter`, `search_recency_filter`, `web_search_options.search_context_size`), not prose.

Two knobs:

1. Keep the prompt tight — Perplexity de-prioritizes long personas against retrieval grounding. If you're over ~1K words total, trim.
2. Don't use `sonar-reasoning` or `sonar-reasoning-pro` with prompts that contain `<thinking>` tags (the XML doesn't, but if you add them, don't). These models emit their own `<think>` block and you'll get double-wrapping.

## Universal rule

If you're adapting the prompt for a new provider not listed here: check whether the provider's own docs specify XML vs Markdown for input, and check whether they emit reasoning tokens visibly. Those two things determine whether the prompt ports cleanly. Everything else in the XML is generic enough to survive.
