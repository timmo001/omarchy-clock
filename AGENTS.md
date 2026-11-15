# Clock for Omarchy

A compact clock and calendar that replaces Omarchy's built-in clock as the
`timmo.clock` bar widget. It's an Omarchy plugin, not a package: no `package.json`,
no build and no CLI.

## Stack

- `manifest.json` is the Omarchy plugin manifest. Its settings schema is the
  source for the settings table in `README.md`, so keep the two in step.
- `BarWidget.qml`, `Panel.qml`, `PanelFlickable.qml` and `WorldClocks.qml` are
  the QML. `Model.js` holds the date and progress maths.
- Qt 6's `qmllint` and the `omarchy` command come from the system. Everything
  else is pinned in `mise.toml` and locked in `mise.lock`.
- Prettier formats the Markdown, JSON, YAML and JavaScript. `.prettierignore`
  skips this file, synced skills and lock files.

## Checks

- `mise run check` before committing. It validates the plugin with
  `omarchy plugin validate`, lints the QML with `qmllint`, and checks formatting.
- `mise run format` writes formatting and `mise run lint` runs `qmllint` alone.
- `hk check --all` runs the shared Markdown, YAML, Actions and shell lints from
  `timmo001/workflows`. The pre-push hook runs those and `mise run lint`.

## Rollout

- Work on `main`. Commit each change on its own, and push once `mise run check`
  passes.
- Users get changes by updating the plugin from this repository, so `main`
  should always pass `mise run check`.
- `.agents/skills/` and `skills-lock.json` are synced from `timmo001/skills`.
  Change them there, not here.
