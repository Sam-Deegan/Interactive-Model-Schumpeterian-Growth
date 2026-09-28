# Changelog

All notable changes to this app. Versions follow [Semantic Versioning](https://semver.org/):
MAJOR for a change to the model or its notation, MINOR for new features
(a stage, a worked example, a figure), PATCH for fixes and wording.
Each release is tagged in git as `vX.Y.Z` and shown in the app footer.

## [1.0.7] - 2026-09-28

### App
- The notes under the figures are rewritten as short plain prose: no bold
  lead-in sentences, one point per paragraph.

## [1.0.6] - 2026-09-28

### App
- Card headers in the blue used for headings, not body grey.

## [1.0.5] - 2026-09-28

### App
- Cards have no border or header rule: figures, equations and stories sit
  on the page separated by whitespace alone.

## [1.0.4] - 2026-09-28

### App
- Cards, panels, tiles and buttons are square with no shadow: they organise
  the page rather than decorate it.

## [1.0.3] - 2026-09-28

### App
- The QR code returns to the foot of the sidebar, with the name and site
  address, alongside the small one in the title bar.

## [1.0.2] - 2026-09-28

### App
- No figure carries a title or subtitle inside the image; the card header
  and the caption under it name and explain the figure (CONVENTIONS.md 6).
- Figures are drawn on a white ground, so the image sits flat in its card
  instead of showing as a tinted tile.

## [1.0.1] - 2026-09-28

### App
- The In Words tab lays out its three columns at fixed widths, so an
  equation no longer collapses to one term per line beside its note.
- The preset card no longer doubles the word "Stage" in front of a stage
  name that already carries it.

## [1.0.0] - 2026-09-28

First public release as a standalone repository.

### Model
- Step-by-step quality ladder following Aghion, Bloom, Blundell, Griffith
  and Howitt (2005): two firms a sector, competition erodes the profit of
  level firms only, effort proportional to the gain from innovating.
- Closed forms for the two efforts, the sector mix, the aggregate innovation
  rate I(c) = 4kc(1-c)/(1+c), its peak at sqrt(2) - 1, growth I(c)(gamma - 1)
  and the value of a lead.
- Two reduced forms: an incumbent's response to the threat of entry by
  distance to the frontier, and a country's growth from inventing and
  copying by distance from the world frontier.

### App
- Five stages that add one layer of the model at a time.
- Six worked examples, one or two a stage, each with a one-paragraph story.
- Equations, Notation and In Words tabs that track the model at each stage.
- Six figures: the quality ladder, the two effects, the inverted U, entry
  and distance, growth by source, and growth-maximising competition by
  distance.
- Ghost curves showing the loaded worked example alongside the live sliders.
- Readout tiles for growth, the life of a lead, who is trying harder, the
  peak, the share of level sectors and the best competition for the country.
