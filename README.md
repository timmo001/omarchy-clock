# Clock for Omarchy

A compact clock and calendar for the Omarchy shell. It replaces the built-in
clock while keeping the familiar bar and popup behaviour.

The popup includes:

- A full local-time readout with seconds
- A six-week calendar with ISO week numbers and locale-aware week starts
- Year progress and an optional life-progress reminder
- Pacific, Mountain, Central, Eastern, and local world clocks
- A `-24` to `+24` hour slider for comparing times, with a clickable offset label that switches between hour and minute increments

Left-click the clock to open the popup. Middle-click opens Omarchy's timezone
picker. The popup can also be toggled through the `timmo.clock` shell target.

## Requirements

- Omarchy Quattro

## Install

Review the plugin, then install it:

```bash
omarchy plugin add https://github.com/timmo001/omarchy-clock.git
```

For an unattended install from a repository you already trust:

```bash
omarchy plugin add \
  https://github.com/timmo001/omarchy-clock.git \
  --enable --yes
```

The plugin declares itself as a clone of `omarchy.clock`, so enabling it
replaces the built-in clock and disabling it restores the original.

## Settings

| Setting | Default | Description |
| --- | --- | --- |
| Bar format | `dddd HH:mm` | Qt date format for a horizontal bar. `ww` inserts the ISO week number. |
| Vertical bar format | `HH\n—\nmm` | Qt date format for a vertical bar. Newlines stack the label. |
| Week starts on | System locale | Sunday or Monday. The calendar's `W` heading also toggles it. |
| Birth year | `0` | Shows life progress when set. `0` hides it. |
| Life expectancy | `90` | Years used for the optional life-progress bar. |

The calendar writes week-start and life-progress changes back to the same
plugin settings.

## Commands

```bash
omarchy-shell shell toggle timmo.clock
omarchy plugin update timmo.clock
omarchy plugin remove timmo.clock
```

## Validate

```bash
mise run check
```

## Licence

MIT. This plugin started as a customised version of Omarchy's built-in clock;
the original Omarchy copyright and licence are retained in `LICENSE`.
