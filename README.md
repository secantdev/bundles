# Secant Bundle examples

Four small Workflow Bundles to copy when you write your own. Each one is a project made by `secant bundle init`: its `AGENTS.md` and `CLAUDE.md`
point your agent at the authoring loop, and `bundle/` holds the Bundle itself.

| Example                                           | What it shows                                                                                           |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [`minimal`](examples/minimal)                     | One Agent step with one prompt.                                                                         |
| [`agent-and-command`](examples/agent-and-command) | An Agent step, then a Command step that runs a script asset, with a PowerShell twin on Windows.         |
| [`verdict-repeat`](examples/verdict-repeat)       | A Repeat that runs until a test verdict passes, an Agent session shared across steps, and a human gate. |
| [`interactive-skill`](examples/interactive-skill) | An interactive Agent step with an Entry Turn and a skill asset.                                         |

## Requirements

The examples need the first Secant release after v0.2.0. Secant v0.2.0 has no `bundle init`, `bundle validate` or `bundle docs`.

## Use an example

1. Copy an example's folder.
2. Change `bundle.id` in `bundle/manifest.json` from `com.example.*` to a reverse-domain id you own, and the id in `AGENTS.md`'s `run launch` line
   to match.
3. Read the authoring guide for the Secant you run with `secant bundle docs`.
4. Run `secant bundle validate ./bundle --strict` until it reports zero problems.

## Checks

[`validate.yml`](.github/workflows/validate.yml) installs `@secantdev/secant@latest` from npm on Linux, macOS and Windows, prints `secant --version`,
and runs `secant bundle validate examples/<name>/bundle --strict` on every example. While the latest release is v0.2.0 or older it skips validation
with a notice naming that version.

## License

[MIT](LICENSE).
