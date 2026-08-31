---
name: using-nashe
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are NASHE's most common process skills, but the rule holds for any of them.

- "Let's build X" → nashe:brainstorming first, then implementation skills.
- "Fix this bug" → nashe:systematic-debugging first, then domain skills.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## NASHE Ground Rules

These hold for every task, in every skill. They are not negotiable and they are not skill-specific.

**Branches.** Code work starts on a fresh branch cut from an up-to-date main, in an isolated worktree — never directly on the branch your human partner is standing on. Branch names are `feat/<something>`. The `nashe:starting-a-development-branch` skill does this; invoke it before the first edit.

**Commits.** Commits carry your human partner's authorship and nothing else. Never add `Co-Authored-By`, never add "Generated with", never add a tool emoji, never name Claude, Claude Code, or NASHE in a commit message, branch name, or PR body. The repository must read as ordinary human work.

**Documents.** Specs and plans go to `docs/specs/` and `docs/plans/`. Whether those files are tracked in git is your human partner's call, asked once per repository — see `skills/using-nashe/references/document-publishing.md` before writing the first one.

**Finishing.** Work ends with a pull request or with the branch left alone. NASHE never merges to main for you.

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, GEMINI.md, etc, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.
