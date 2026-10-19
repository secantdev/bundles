---
name: secant-bundle-author
description: Designs, builds and tries a Secant Workflow Bundle with the user, showing a drawn sketch they confirm round by round before any Bundle file is written. Use when the user wants to make a Secant workflow or Bundle, or to change an installed one.
---

# Secant Bundle author

## Footing

The user asked you to make a Secant workflow. Secant is a command-line tool that runs a workflow on a project, one Step after another: AI agents (Claude Code or Codex) working alone or with the user, scripts, and the user's own decisions. It keeps every Run on record, so a Run can pause and resume. A **Workflow Bundle** is that workflow packaged as one file: a `manifest.json` listing the Steps in order, plus the prompts, skills and scripts they use.

Your job: reach a **shared understanding** with the user of the workflow they want, show it back as a **sketch** until they confirm it, then write, check and build the Bundle. The user never handles a file. Everything lives in one temp project and stays there; once the Bundle is installed, Secant holds it and the folder may be wiped.

Secant tells you how to drive it. This skill names only the two commands that start a project; the project's `AGENTS.md` names every later one, and `--help` on any command shows its flags.

Two folders matter. The **authoring project** is the folder `init` creates, in the temp directory. The **user's project** is the repository the workflow will run on, usually the one this conversation started in; ask when it is not clear.

## Start

1. Create an empty folder in the OS temp directory and run `secant bundle init <that folder>/<name>`, where `<name>` is a short slug of what the user wants, such as `fix-failing-tests`. It becomes the Bundle id `com.example.<name>`. To change an installed Bundle instead, read `secant bundle docs init` and copy it into that folder as the page says.
2. Read the authoring project's `AGENTS.md` and follow it for every Secant command from here on. Read the whole guide once, as `secant bundle docs` explains.
3. Copy [`viewer.html`](viewer.html) to `design/workflow.html` in the authoring project, outside `bundle/`.

## Design loop

1. When the user's request already describes the workflow, take it as round 1's input. Otherwise ask the user to describe it in plain words, step by step: what each step does, what it starts from and where that comes from, what it hands on, any skills it should follow, and prompts if they have them. Say a rough description is enough. When changing an installed Bundle, skip this: round 1 is the Bundle as it is.
2. Each round, write `design/sketch.js` as [SKETCH.md](SKETCH.md) defines, with the round number one higher. On round 1, open `design/workflow.html` in the user's browser. Then, in the chat:
   - print the text view;
   - say in two to four sentences of your own words what you understand the workflow to do;
   - ask the round's questions (see Asking).
3. Fold the user's answers into the next round. The loop ends when the frontier is empty, the sketch's open list is empty, and the user confirms the sketch as it stands. A confirmation given ahead, such as "if nothing else is open, build it", counts once its condition holds; then show the final round and go on.

## Asking

Interview the user until you reach a shared understanding, asking about anything ambiguous. Map the workflow as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one round, then wait for the user's answers. A question whose answer depends on another question still open in this round belongs to a later round. Each answer reshapes the tree, so recompute the frontier every round. Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, with the choices when there are some>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Finding facts is your job, never the user's: look in the project or `secant bundle docs` instead of asking. The decisions are the user's: put each one to them and wait. The design is done when the frontier is empty, every branch visited and nothing silently assumed.

Sort every detail before it becomes a question:

1. **Not required**: leave it out, and never ask, until the user's words touch it.
2. **Required with a default** (stated or implicit): fill it silently. A new conversation per Step is the default until the user wants Steps to share one; [DETAILS.md](DETAILS.md) lists the rest. Ask when the user's words lean away from the default without saying what they want.
3. **Worth offering**: features the user cannot guess that make a Step easier or let them step away. Offer each one where it fits a Step, saying what it saves; DETAILS.md lists them.
4. **Types**: pass everything between Steps as text. Ask for a type only where Secant needs one: a launch input (text, a file, several files, pass/fail, or one of fixed choices), what a script hands on (pass/fail from its exit code, or its output), and a decision Step (approve or reject, or a typed answer).

## Improvise

When Secant has no direct form for what the user wants, build the nearest thing that does the job before calling it a limit. DETAILS.md lists known moves, such as a chat that must hand something on; look through `secant bundle docs` for more. Draw each Step a move adds as its own numbered Step with a note saying why it is there, and put only what no move can do in the sketch's limits.

## Write

Turn the confirmed sketch into the Bundle as [DETAILS.md](DETAILS.md) maps it, replacing `init`'s placeholder prompt and its asset entry. Validate it as `AGENTS.md` says until it reports zero problems, reading the guide's page for each finding code. Then walk the runtime checks in DETAILS.md, which validation cannot see, and make the Development build `AGENTS.md` names.

## Demo run

Ask whether the user wants a demo run, and which harness (Claude Code or Codex) and model it should use. Say it runs in a throwaway git worktree on a temporary branch inside the temp folder, so every change stays there and their project is untouched.

1. In the user's project: `git worktree add <temp folder>/demo -b secant-demo-<name>`. When the project is not a git repository, ask before using a copy in the temp folder instead.
2. From that folder, approve it and launch the Development build as `AGENTS.md` says, adding the model as the launch command's `--help` shows. When Secant refuses because a Step needs the terminal UI, tell the user to open Secant's terminal UI in that folder and launch the Development build there, with the harness and model they chose.
3. Take what the user saw back into the design loop. Afterwards run `git worktree remove --force <temp folder>/demo` and `git branch -D secant-demo-<name>`.

## Finish

Ask the user to confirm the final build, with or without a demo run; a confirmation given ahead counts. When changing an installed Bundle, raise `bundle.version` first, since an installed version never changes. Then make the real build and clean up as `AGENTS.md` says. Give the user the launch line from `AGENTS.md` without `@dev`, with the harness they chose or both choices, and say its first launch asks for trust and prints the exact value to re-run with. Leave the temp folder in place.
