# From sketch to Bundle

The manifest field reference in `secant bundle docs` is the authority on every field's name and type. This file holds what the guide leaves out: what each field means for the user, which ones to fill silently or offer, how to improvise, and the runtime checks `validate` cannot make.

## What Secant can do

Steps run strictly in order. The only control flow is a repeat over a run of Steps; there is no branch, no parallel Step, no repeat inside a repeat, and no jump back. Rejecting an approval ends the Run as failed. A decision Step cannot sit inside a repeat. Commands time out after ten minutes. Model and harness are chosen when a Run is launched, never in the Bundle.

## Each sketch Step

| Sketch | Bundle |
| --- | --- |
| `who: ai` | `kind: agent`. Gives text only. |
| `who: ai-chat` | `kind: interactive-agent`, with `entryTurn: true`. Gives nothing: when the chat must hand something on, follow it with an `agent` Step in the same `session` that writes it. Runs only in the terminal UI. |
| `who: you`, `ask: approve` | `kind: human-gate`, `shape: approve-reject`, `message`. Gives nothing. |
| `who: you`, `ask: answer` | `kind: human-gate`, `shape: free-text`, `message`, optional `suggestions`, and exactly one `produces` of type `text`. |
| `who: script` | `kind: command`. `command.executable` is a bare program name on PATH; `arguments` are separate strings with no shell, so pipes and `&&` need a script asset. Set `workingDirectory: "."`. Gives `verdict` (exit 0 is pass) and or `text` (its output). An `{ "artifact": <name> }` in `arguments` or `env` passes that value's text; a `file` launch input passes its absolute path. Write Node scripts as `.cjs`, since a parent `package.json` may make `.js` a module. Whether a Windows `.cmd` program such as `npm` runs as a bare `executable` is not documented, so run such tools from a script asset. |
| `loop.by: verdict` | `{ "repeat": { "until": <verdict>, "reviewCheckpoint": { "interval", "message" }, "steps" } }`. `interval` has no default: ask, with a recommended number. |
| `loop.by: you` | `{ "repeat": { "control": "human", "steps" } }`, holding exactly one `interactive-agent` Step. |
| `gives` type `pass/fail` | `verdict` |
| `inputs` type `files`, `pass/fail` | `file-set`, `verdict` |

A decision Step shows its `message`, or one artifact through `prompt: { "artifact": <name> }` instead; when both are set, `message` wins.

## Fill silently

- `formatVersion: 1`, `bundle.version: "0.1.0"`, and `bundle.name` and `bundle.description` drawn from the sketch. Keep the `com.example.<name>` id `init` derived from the folder name; it works on this machine, and only a Bundle shared with others needs an id the user owns. When `validate` warns `installed-identity-differs`, another Bundle already holds that id: choose a different name.
- `platforms: ["windows", "macos", "linux"]` when there is no command. With commands, list the systems the commands run on, and ask when you cannot tell; a script that must run on Windows needs a twin under `command.platforms.windows`.
- Every Step's `session` is its own `id`, unless the sketch gives it a `conversation`.
- `requires` is exactly the set of `{{artifact:name}}` slots its prompt uses. Each prompt is an asset at `prompts/<step id>.md`.
- `entryTurn: true` on every `interactive-agent` Step.
- A command or input that produces a repeat's `until` verdict before the repeat starts, and a Step inside it that produces the verdict again.
- `reviewCheckpoint.message` written from the loop's purpose.
- Every file in `bundle/` is declared in `assets`.
- `retry: 0` on an `agent` Step with outside effects such as committing, publishing or pushing, so a retry cannot do it twice; note it on the sketch Step ("Tried once only: a second try could make a second commit"). Otherwise every Step of every kind gets two retries, and only a failed attempt retries: a command retries when it cannot run or times out, never because it exited non-zero.
- `prerequisites: ["git-worktree-root"]` on a Step that needs a git repository; Secant checks it at launch, so a Run refuses to start in the wrong folder. Note it on the sketch Step.

## Worth offering

The user cannot guess these exist. Offer each where it fits a Step, saying what it saves them.

- **The AI ends its own chat Step.** Offer it on every `ai-chat` Step: the user no longer has to end each chat by hand. `agentCompletion: ["step"]`, with `stepDoneWhen` saying when, in the user's terms. Inside a `control: "human"` repeat, `agentCompletion: true` also lets the AI end the whole loop, with `stageDoneWhen`.
- **A shared conversation** (`session`) between Steps, so a later Step remembers an earlier one instead of being told again.
- **A skill**: copy the user's skill folder to `bundle/skills/<name>/`, declare it as a `skill` asset, and list it in the Step's `uses`.
- **Quick answers**, `suggestions`, on a typed-answer decision.
- **An output saved into the project**, `produces[].home: "workspace"` together with `path`.

## Improvising

Each move adds or reshapes Steps the user did not ask for. Draw every added Step in the sketch as its own numbered Step, with a note saying why it is there ("Added so the chat's result gets written down").

| The user wants | Build |
| --- | --- |
| A chat that ends in something written down | The `interactive-agent` Step, then an `agent` Step in the same `session` that writes it as its output. |
| Several things done at once | One `agent` Step told to split the work across sub-agents, when the harness has them; or a `command` Step whose script runs the jobs together. |
| "If X, do this, otherwise that" | One Step whose prompt handles both cases, or a script that checks X and acts. |
| "If I reject, go back" | A `control: "human"` repeat around an `interactive-agent` Step: each round the AI redoes the work with the user, and the user ends the loop when happy, so the Run goes on. |
| A decision inside a loop | Nothing direct: a repeat's `reviewCheckpoint` only offers keep going or stop, and stopping fails the Run. Let the user steer from inside an `interactive-agent` Step instead. |
| An AI chat that hands something to a script | The writer Step above, whose text output the script takes as an argument. |
| An AI working alone that ends a verdict loop | The `agent` Step gives a text output, such as a report starting `STUCK`, and the script that makes the verdict reads it and passes. The alternative, a `control: "human"` repeat with `agentCompletion: true`, makes the user sit in a chat. |

## Prompts

Write each prompt in the user's voice to the AI, with the artifacts it uses as `{{artifact:name}}` slots and `{{run:working-area}}` for the Run's own scratch folder. A Step where the AI works alone is one turn: say plainly it cannot ask the user anything, and say what counts as done. A Step that gives an output says to record it in the output named below it; Secant appends where to write it. A bundled skill that tells the AI to load another skill by name needs a line in the prompt: read that skill's `SKILL.md` from its bundled path instead.

## Runtime checks

`validate` checks that the manifest is well formed and that its parts refer to each other correctly: every name used is made earlier, every type matches, every file is declared. It cannot tell what a field does once a Run starts, so some manifests pass it and still fail mid-Run or silently drop something. After `validate` is clean, check each of these by hand:

| Passes `validate`, but | What happens in a Run | Fix |
| --- | --- | --- |
| A typed-answer decision has no `text` output | Secant refuses the user's answer: it has nowhere to go, so the Run waits on a question nobody can answer. | Give it exactly one `produces` of type `text`. |
| A Step after a verdict repeat uses a name only a Step inside it makes | When the verdict already passes, the repeat runs zero times, the name is never made, and the later Step fails. | Use a name made before the repeat as well, or make it in a Step after the repeat. |
| An approval decision has `produces` | Approving gives nothing, so a later Step that uses that name fails. | Leave `produces` off; when a later Step needs the user's words, use a typed-answer decision. |
| A decision's prompt asset holds `{{artifact:…}}` slots | The user sees the raw braces; slots are never filled there. | Use `message`, or `prompt: { "artifact": <name> }` to show one artifact. |
| A name is in `requires` with no slot in the prompt | The AI never sees it: a slot is the only way a value reaches a prompt. | Put `{{artifact:<name>}}` in the prompt for every name in `requires`. |
| An `interactive-agent` Step lacks `entryTurn: true` | The user faces a blank chat; the prompt, its slots and its skills are never sent. | Set `entryTurn: true`. |
| `uses` lists a `resource` asset or an artifact | Nothing is delivered; only `skill` assets in `uses` reach the AI. | Pass artifacts through slots and resources to scripts. |
| `home: "workspace"` has no `path` | The output stays inside Secant and never lands in the project. | Add `path`. |
| A `choice` input has an empty `choices` | No launch can ever satisfy it. | List the choices. |
| No Step inside a verdict repeat produces its `until` again | The verdict never changes, so the loop runs to every checkpoint. | Have a Step inside produce the same verdict name, usually the script that re-checks. |
| `platforms` is left out | The Bundle builds for this machine's system only. | List every system it should run on. |
