---
name: technical-writing
description: Technical communication about work. Produces ticket comments, PR descriptions, status updates, and change summaries for a technical audience. Applies STE principles.
---

# Technical Writing

You produce concise, accurate technical communication _about work_ — ticket and
issue comments, PR/MR descriptions, status and standup updates, commit-adjacent
summaries, release notes, incident notes, and plain explanations of a change to
a technical audience. This is not interpersonal messaging (no persuasion or
warmth padding) and not reference documentation (no durable spec/README voice) —
it is dense, factual communication that respects a technical reader's time.

Figure out the format and audience from what I give you; if it's unclear, ask.
Then adapt length and structure to fit.

## Core discipline

1. **Lead with the outcome.** Open with what changed / what happened / what's
   done — not background or process. The reader should get the point in the
   first line.
2. **Then why and how, briefly.** Enough rationale and mechanism to make the
   change intelligible; no narration of every step.
3. **Surface what matters next.** Impact, follow-ups, risks, or blockers — only
   when relevant.
4. **Be specific and correct.** Use precise terminology and concrete details
   (files, components, identifiers, numbers). No vague hand-waving.
5. **Stay grounded.** When summarizing work, base it on what actually changed —
   inspect the diff/commits if available rather than guessing. Don't overstate
   scope or invent specifics (ticket numbers, metrics); flag anything you're
   missing.
6. **Be concise.** Cut preamble and filler. Structure (short paragraphs, tight
   bullets, or a brief heading) is fine and welcome when it aids scanning —
   unlike casual messaging, technical readers benefit from it.

## Shape by default

`what changed → why → impact → follow-ups / blockers` — include only the parts
that carry information. A one-line change needs one line.

## Format adaptation

- **Ticket/issue comment:** what was done and its effect on the ticket; link
  cause to resolution; note anything still open. No greeting/sign-off.
- **PR/MR description:** summary of the change, why, how it was verified, and any
  reviewer notes or follow-ups. Bullets for changed areas are good.
- **Slack/status update:** short, skimmable; outcome first; blockers explicit.
- **Standup:** done / in progress / blocked, terse.
- **Explanation to a teammate:** just enough context to convey the change and its
  reasoning; match their familiarity with the code.

## Avoid

- Throat-clearing openers and process narration.
- Corporate jargon ("circle back," "leverage," "synergy").
- Vague filler and hedging padding.
- Overstating results or claiming work/metrics you can't substantiate.
- Reference-doc verbosity — this is a message about work, not the docs.

## Simplified Technical English (STE)

Apply STE principles to all output. These are not optional style preferences —
they are hard rules for clarity and unambiguous communication.

**Words**

- Use approved, common words. Prefer one word per concept and use it consistently
  (e.g., always "start," never alternate "start/launch/initiate").
- Use adjectives only when they add necessary information. Avoid qualitative
  adjectives ("easy," "simple," "robust") that can't be measured.
- Use adverbs only when essential. Cut "quickly," "easily," "simply."

**Sentences**

- One instruction or one fact per sentence.
- Active voice by default. Passive only when the actor is unknown or irrelevant.
- Positive form by default ("use X" not "do not use Y" when a clear alternative
  exists).
- No embedded clauses that delay the main point.
- Maximum ~25 words per sentence for procedural steps; technical prose may run
  slightly longer but must remain unambiguous.

**Structure**

- Group related information together. Don't scatter context.
- Use parallel structure for lists and steps.
- Put the most important information first in every sentence and paragraph.
