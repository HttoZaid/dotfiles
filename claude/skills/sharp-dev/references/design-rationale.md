# Design rationale

Each section of the prompt exists because research says it works, not because it sounds good. Citations below.

## `<role>` — no biography, just scope

The EMNLP 2024 paper *"When 'A Helpful Assistant' Is Not Really Helpful: Personas in System Prompts Do Not Improve Performances of Large Language Models"* (arXiv:2311.10054) tested 162 personas across 2,410 factual questions and 4 LLM families. Result: adding a persona did not improve performance; some personas mildly hurt accuracy. Confirmed by arXiv:2508.19764 (2025).

So: no "20 years of experience" backstory. Just scope ("systems code, protocols, backend, frontend, infra, tooling") and voice ("sharp friend at a coffee shop"). Behavior over biography.

## `<voice>` — positive framing, show-don't-tell

Two research threads merge here:

1. **Anthropic's prompting best practices** explicitly say to tell the model what to do instead of what not to do. Negative-only instructions have the "pink elephant" problem — mentioning the forbidden token activates it.

2. **The leaked GPT-5.4 system prompt** contains this clause: *"CRITICAL: ALWAYS adhere to 'show, don't tell.' NEVER explain compliance to any instructions explicitly... if your response is concise, DO NOT say that it is concise."* This is the fix for ironic-violation patterns where the model says "Sure, keeping it casual:" and then produces a conference talk.

So the `<voice>` section leads with positive framing ("open with substance", "close when done") and enforces show-don't-tell.

## `<response_shape>` — conditional rules, not universal ones

From Anthropic's 2026 docs: *"Claude should not use bullet points or numbered lists for reports, documents, explanations... its prose should never include bullets, numbered lists, or excessive bolded text anywhere."* The production Claude 4 system prompt (Simon Willison, May 2025) enforces this with per-reply-type carve-outs.

So the section teaches a decision function ("match shape to question") instead of a universal rule ("always use headers" or "never use headers"). Both extremes are wrong — the right answer is conditional.

## `<research_discipline>` — explicit trigger list, not vibes

Three papers force this section to be aggressive:

1. **Package hallucination study** (Spracklen et al., USENIX 2024, arXiv:2406.10279): 19.7% of generated package names don't exist; 43% of hallucinations are reproducible across runs, enabling the "slopsquatting" supply-chain attack.
2. **OpenAI's BrowseComp benchmark** (arXiv:2504.12516): GPT-4o without browsing scored 0.6%. With browsing enabled but not mandated, 1.9%. Giving a model a search tool is not the same as making it use it.
3. **Vectara 2026 hallucination leaderboard**: Claude Sonnet 4.5, GPT-5, and Gemini 3 Pro all exceed 10% hallucination on the harder 7,700-article slice.

So the section enumerates explicit trigger categories (version numbers, "current best practice" claims, install commands, etc.) rather than saying "search when appropriate." Ambiguity here is expensive.

## `<tools_and_environment>` — autonomy without jailbreak

OpenAI's GPT-5 Prompting Guide ships the standard autonomy block verbatim: *"You are an agent — please keep going until the user's query is completely resolved... Never stop or hand back to the user when you encounter uncertainty — research or deduce the most reasonable approach and continue."*

The section combines this with a "tool calls are free" framing — removing the instinct to announce tool use or ask permission for reversible actions. That instinct is a trained-in politeness behavior that wastes tokens and user time.

## `<pushback>` — evidence requirement, not stubbornness

The SycEval paper (Fanous et al., arXiv:2502.08177, FAccT 2025) is the key citation. Measured sycophancy rates across frontier models: overall 58.19%, Gemini highest at 62.47%, Claude-Sonnet 57.44%, ChatGPT 56.71%. Two findings drive the section's design:

1. *"Preemptive rebuttals cause more sycophancy than in-context ones"* — 61.75% vs 56.52%. So the section bans preemptive "many people wrongly think X" framing.
2. *"Once a model has capitulated, the wrong position persists 78.5% of the time in the same conversation."* So the section requires naming the piece of evidence that causes any update — quiet capitulation is a worse failure than stubbornness.

Sharma et al. (arXiv:2310.13548) showed *"the single phrase 'Are you sure?' reliably flips correct answers to wrong ones."* So the section explicitly names social-pressure phrases as not-evidence.

The evidence requirement (`new technical evidence, a constraint you didn't know about, a runnable counter-example, documentation you hadn't seen, a spec reference, an error trace`) comes from OpenAI's Model Spec: *"it may politely push back when asked to do something that conflicts with established principles or runs counter to the user's best interests."*

Critical note from the March 2026 Stanford/CMU paper (Cheng, Jurafsky et al.): obstinacy language ("never agree with me") creates contrarian theater and fails. "MUST state the reason before changing a previous position" is the verbal form that works.

## `<execution_tiers>` — tool-gated classification

Claude Code's plan mode proves this pattern works because the plan-mode system prompt doesn't just say "don't edit files" — it structurally removes edit tools. Armin Ronacher's analysis (lucumr.pocoo.org/2025/12/17): *"There are recurring prompts to remind the agent that it's in read-only mode... It has a little state machine going on to enter and exit plan mode."*

In a prompt-only setting without tool-gating, the best available substitute is explicit three-tier classification with concrete triggers. The rule of thumb from the 2026 research synthesis: *"If you can describe the exact diff in one sentence, skip the plan. If you can't, plan first."*

Also cited: arXiv:2603.26233 *"Ask or Assume?"* — a multi-agent scaffold that decouples underspecification detection from execution hit 69.40% resolve rate on underspecified SWE-bench Verified, significantly above single-agent baselines. In single-prompt form, this becomes the "one batched clarifying question" rule.

## `<autonomy>` — reversibility heuristic

Anthropic's published framing: *"You are encouraged to take local, reversible actions like editing files or running tests, but for actions that are hard to reverse, affect shared systems, or could be destructive, ask the user before proceeding."*

This converts "break out of the box" from a jailbreak-adjacent phrasing into a structured gradient. Reversible = free. Destructive = asks. No-bypass-safety is a separate clause because Simon Willison's "lethal trifecta" (private data + untrusted content + external communication) demonstrates how autonomy-grants get exploited by indirect prompt injection. The deny-list on `--no-verify` and `--force` matters.

## `<code_quality>` — Anthropic's over-engineering block

Ported nearly verbatim from Anthropic's official docs: *"Avoid over-engineering. Only make changes that are directly requested or clearly necessary... A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't need extra configurability. Don't add docstrings, comments, or type annotations to code you didn't change."*

The "mention adjacent problems in one sentence, don't fix them silently" line comes from the same doc section. This kills the drive-by-refactor pattern that Hacker News users specifically complained about on Gemini 3.

## `<output_format>` — Markdown because everyone emits Markdown

All four target models (Claude, Gemini 3.1, GPT-5.x, Perplexity) have Markdown as their preferred output format. Anthropic's docs explicitly suggest matching the prompt's register to the desired output — so the prompt is written in flowing prose, but declares Markdown as the output format because that's what will render correctly in the UIs people use.

## `<forbidden>` — negative constraints, placed last

Two reasons for position:

1. **Pink elephant problem**: listing forbidden phrases activates them. Every forbidden item in this section has a positive alternative already stated above, so the list is reinforcement, not primary guidance.
2. **Gemini 3 over-indexing**: Google's Gemini 3 prompting guide explicitly notes that the model over-indexes on negative constraints when they're placed early in the prompt. Putting them last is the documented workaround.

The specific forbidden items come from the leaked Claude Code prompt (*"Avoid over-the-top validation or excessive praise"*), the leaked Cursor system prompt (*"Refrain from apologizing all the time"*), OpenAI's post-GPT-4o-sycophancy fix (*"avoid ungrounded or sycophantic flattery"*), and Claude Code's anti-time-estimate clause.

## Why this skill has no numbered sections

Dogfood. The SKILL.md itself is written in the register the prompt demands — flowing prose, headers only where needed, no mandatory 01./02./03. template — because models mirror the register they're fed. A SKILL.md about anti-template behavior written as a numbered-section template would be self-defeating.
