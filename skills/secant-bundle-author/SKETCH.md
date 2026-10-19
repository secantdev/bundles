# The sketch

The sketch is what the user confirms. `design/sketch.js` holds it as one call, `secantSketch({...})`, so the page next to it can re-read the file every second without a server. Rewrite the whole file each round. Keep each Step's and each loop's `id` across rounds: the page marks them new, changed or removed by `id`, compared with the round before.

## Format

```js
secantSketch({
  "sketch": 1,
  "round": 2,
  "title": "Fix failing tests",
  "summary": "Plain-words account of the whole workflow, as the user would tell it.",
  "inputs": [
    { "name": "goal", "type": "text", "says": "What you want fixed" }
  ],
  "flow": [
    { "id": "test", "who": "script", "does": "Runs your tests once.", "run": "npm test",
      "gives": [{ "name": "tests-pass", "type": "pass/fail" }, { "name": "test-output", "type": "text" }],
      "notes": ["Each test run must finish within ten minutes."] },
    { "id": "fix-loop", "loop": { "by": "verdict", "until": "tests-pass", "checkEvery": 3 },
      "steps": [
        { "id": "fix", "who": "ai", "does": "Fixes the code.", "needs": ["test-output"], "conversation": "fixer",
          "prompt": "The tests fail with:\n{{artifact:test-output}}\nFix the code. Do not commit." },
        { "id": "retest", "who": "script", "does": "Runs your tests again.", "run": "npm test",
          "gives": [{ "name": "tests-pass", "type": "pass/fail" }, { "name": "test-output", "type": "text" }] }
      ] },
    { "id": "approve", "who": "you", "ask": "approve", "does": "You read the test results and approve the fix.", "needs": ["test-output"] },
    { "id": "commit", "who": "ai", "does": "Commits the fix.", "conversation": "fixer",
      "notes": ["Tried once only: a second try could make a second commit."] }
  ],
  "limits": ["What the user asked for that Secant cannot do, and the nearest thing it can."],
  "open": ["What is still undecided, one line each."]
})
```

| Field | Values |
| --- | --- |
| `who` | `ai` (AI works alone), `ai-chat` (AI works with the user), `you` (the user decides), `script` (a command runs) |
| `ask` | On `you` only: `approve` (approve or reject; rejecting ends the Run) or `answer` (a typed answer), with optional `suggestions` |
| `loop.by` | `verdict` (repeat until `until` passes, asking the user every `checkEvery` rounds, 1 to 100) or `you` (repeat until the user ends it; holds exactly one `ai-chat` Step) |
| `inputs[].type` | `text`, `file`, `files`, `pass/fail`, or `choice` with `choices` |
| `gives[].type` | `text`, or `pass/fail` from a script's exit code |
| `conversation` | Only when Steps share one conversation; omitted means a new one |
| `run` | The command as the user knows it, even when a bundled script runs it |
| `skills`, `prompt`, `notes` | Only when known; `prompt` uses `{{artifact:name}}` for each name in `needs` |

Use the user's words in `does` and `summary`. `limits` holds only what the user asked for that Secant cannot do; a Secant behaviour the user should know, such as a timeout, goes in the `notes` of the Step it touches. Write `limits` and `open` as plain sentences the user can answer.

## Text view

Print this in the chat every round, so a user without the page sees the same sketch, numbered the way the page numbers it. From round 2 on, mark each Step or loop line `new` or `changed` against the round before, count both in the header, and list removed ones last. Round 1 has no marks. Put a line's notes after ` · `. The user names Steps by number; map the number back to its `id`.

```
Round 2 · Fix failing tests · since round 1: 3 new, 2 changed
1. Script: runs your tests once → tests pass (pass or fail), test output · ten-minute limit   new
   Repeat 2–3 until tests pass comes back pass · every 3 rounds, keep going or stop        new
2.   AI: fixes the code · uses test output (step 1 or 3) · conversation shared with step 5  changed
3.   Script: runs your tests again → tests pass, test output                               new
4. You decide: approve or reject the fix; rejecting ends the run · uses test output (step 1 or 3)
5. AI: commits the fix · same conversation as step 2 · one try                             changed
Limits: none
Open: none
Removed: none
```
