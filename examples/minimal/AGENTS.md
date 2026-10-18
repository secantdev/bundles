Run `secant bundle docs` to read the authoring guide for the Secant you run, and `secant bundle docs <topic>` for one topic or finding code.
Run `secant bundle validate ./bundle --strict` until there are zero problems.
Try each edit with `secant bundle build ./bundle --dev`.
In the intended Workspace, run `secant workspace approve` once, then `secant run launch com.example.minimal@dev --harness <harness>`, choosing `claude-code` or `codex`.
Then run `secant bundle build ./bundle` for a real build.
Finally run `secant bundle clean` to remove the Development builds no Run still needs.
