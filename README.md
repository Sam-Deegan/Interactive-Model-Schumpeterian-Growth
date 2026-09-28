# Interactive Model: Schumpeterian Growth

A Shiny app for teaching Schumpeterian growth: the quality ladder, creative
destruction, and the inverted-U relationship between competition and
innovation. Built by [Sam Deegan](https://sam-deegan.com) for ECON42550
Macroeconomics, University College Dublin.

**Try it in the browser (nothing to install):**
https://sam-deegan.com/toy-models/schumpeter/

Current version: **1.0.1** (see [CHANGELOG.md](CHANGELOG.md)). The version
is shown in the app footer; releases are tagged `vX.Y.Z`.

## What it does

The stage selector adds one layer of the model at a time:

| Stage | What is added |
|---|---|
| 1 | The quality ladder: productivity as a staircase, each step a firm displaced, and the value of a lead |
| 2 | The two effects of competition on research effort: escape competition and the Schumpeterian effect |
| 3 | The inverted U: aggregate innovation against competition, and where it peaks |
| 4 | Firm dynamics: turnover at the top, and the threat of entry by distance to the frontier |
| 5 | Appropriate growth policy: inventing and copying, and the growth-maximising competition by distance from the world frontier |

Each stage opens on a worked example (big steps rarely, a comfortable
monopoly, cut-throat competition, the top of the U, the threat of entry, a
country far behind). Every slider has a box beside it for an exact value.
Move a slider and a faded copy of each figure stays behind at the settings
you started from, so you can see what your change did. The Equations,
Notation and In Words tabs show the model as it stands at the chosen stage
and flag what that stage added.

## Run it locally

1. Install [R](https://cran.r-project.org/) (4.1 or later) and, ideally,
   [RStudio](https://posit.co/download/rstudio-desktop/).
2. Install the three packages once:

   ```r
   install.packages(c("shiny", "bslib", "ggplot2"))
   ```

3. Open `app.R` in RStudio and click **Run App**, or from R in this folder:

   ```r
   shiny::runApp()
   ```

Equations are typeset with MathJax from a CDN, so they need an internet
connection; everything else runs offline.

## Files

```
app.R          the app: settings and text (section B), figures (D),
               interface (E), server (F)
R/model.R      the model: effort by type of firm, the sector mix, the
               aggregate innovation rate, growth, the peak, the value of a
               lead, entry, policy, readouts. Sources on its own, so slides
               can reuse it.
R/toolkit.R    layout and helpers shared with the other toy-model apps
www/           logo and QR code
README.md      this file
CHANGELOG.md   version history
CONVENTIONS.md how the figures and worked examples are laid out
LICENSE        CC BY-NC-ND 4.0
```

All text on screen (worked examples, prompts, equations, notation) is in
section `B_03` of `app.R`, so it can be edited without touching the rest.

## The model

Schumpeterian growth theory, from Aghion and Howitt (1992), makes growth the
outcome of innovations that displace incumbents: creative destruction. The
app uses the step-by-step version of Aghion, Bloom, Blundell, Griffith and
Howitt (2005), in which competition has two opposite effects on the
incentive to innovate and their sum is an inverted U. Periods are years.

Each sector has two firms. An innovation multiplies productivity by `γ > 1`
and moves the innovator one step up the ladder, so a sector is either neck
and neck, with the two firms level, or unlevelled, with a leader and a
laggard one step behind. Competition `c` erodes the profit of a firm that is
level with its rival, and not that of a firm with a lead.

```
Ladder:     A_{t+1} = γ A_t  on each innovation
Profits:    π_leader = π_0,   π_neck = π_0 (1 − c),   π_lag = 0
Research:   max_n  λ n Δ − ½ ψ n²   ⇒   n = λ Δ / ψ
Escape:     n_neck = k c,           k = λ π_0 / ψ
Schumpeter: n_lag  = k (1 − c)
Mix:        ω_neck = n_lag / (n_lag + 2 n_neck)
Innovation: I(c) = 4 k c (1 − c) / (1 + c)
Peak:       c* = √2 − 1 ≈ 0.414
Growth:     g = I(c) (γ − 1)
Lead:       V = π_0 / (ρ + n_lag),   expected lead = 1 / n_lag
Entry:      n(d, e) = k [ (1 − d) + β e (1 − 2d) ]
Policy:     g(c, D) = [ (1 − D) I(c) + D m (1 − c) ] (γ − 1)
```

**Research** costs `ψ n² / 2` and succeeds with probability `λ n`, so a firm
sets its effort in proportion to the gain `Δ` from innovating. All that
differs between firms is what that gain is.

**Escape competition.** The gain to a level firm is `π_0 c`, which rises
with competition: level firms innovate to get away from a rival that is
taking their profit. **The Schumpeterian effect.** The gain to a laggard is
`π_0 (1 − c)`, which falls with competition: the prize it is chasing has
been competed away. The two lines cross at `c = 0.5`.

**The mix of sectors.** In steady state sectors leave the level state as
fast as they arrive, so the share of level sectors `ω_neck` falls as
escape-competition effort rises. **Aggregate innovation** is the weighted
sum of the two efforts, zero at both ends of the range and positive in
between: the inverted U. Maximising it gives `c² + 2c − 1 = 0`, so the peak
is at `√2 − 1` whatever `k` and `γ` are. **Growth** is the innovation rate
times the size of a step; output is the sum of sector outputs, so a step
counts as `γ − 1` (Aghion and Howitt 1992 write `ln γ`, which is close for
small steps).

**The value of a lead** is the rent, discounted, and eroded by the rate at
which laggards innovate, so leadership of an industry lasts `1 / n_lag`
years on average.

**Entry and policy** are two reduced forms on top of the model. An
incumbent at distance `d` from the frontier adds `k β e (1 − 2d)` to its
effort when the threat of entry is `e`: positive near the frontier, negative
far from it, with the sign flipping at `d = 1/2`. A country at distance `D`
from the world frontier grows partly by inventing and partly by copying at
rate `m`; competition helps the first and hinders the second, so the
growth-maximising `c*(D)` rises as the country approaches the frontier.

Everything is in closed form except `c*(D)`, which is read off a grid.

**What the five stages show with it**

- *1* Growth as a staircase. The step height is `γ` alone; the tread is the
  waiting time `1 / I(c)`, set by the cost of research, the rent and
  competition. Every riser is an incumbent being displaced.
- *2* The two effects of competition, side by side. Neither reverses:
  escape-competition effort rises in `c` over the whole range and laggard
  effort falls over the whole range.
- *3* The inverted U. The turn comes from composition: as `c` rises the
  share of unlevelled sectors rises, moving weight from the rising line to
  the falling one. The height of the U moves with `ψ`, `π_0` and `γ`; the
  peak does not.
- *4* Two predictions about firms: continual turnover at the top of each
  industry, and a threat of entry that raises innovation near the frontier
  and lowers it far behind. Averaging the two can find almost nothing.
- *5* Appropriate growth policy. The competition that maximises growth is
  the top of the inverted U at the frontier and much lower far behind it,
  because catch-up growth comes from copying, and copying needs rents.

**Where it departs from the textbook.** The two-firm, one-step ladder and
the profit schedule follow Aghion, Bloom, Blundell, Griffith and Howitt
(2005); growth is `I(c)(γ − 1)` rather than the `ln γ` of Aghion and Howitt
(1992), because output is summed across sectors. The entry response and the
inventing-and-copying growth rate are reduced forms chosen to reproduce the
sign patterns the lectures teach, not solutions of the step-by-step model.
`c*` maximises the aggregate innovation rate and `c*(D)` maximises measured
growth; neither is a welfare optimum. The model has no labour market, no
capital and no consumer, and competition `c` is a parameter rather than the
outcome of a pricing game.

## References

- Aghion, P. and Howitt, P. (1992). A Model of Growth through Creative
  Destruction. *Econometrica* 60(2).
- Aghion, P., Bloom, N., Blundell, R., Griffith, R. and Howitt, P. (2005).
  Competition and Innovation: An Inverted-U Relationship. *Quarterly
  Journal of Economics* 120(2).
- Aghion, P., Akcigit, U. and Howitt, P. (2014). What Do We Learn from
  Schumpeterian Growth Theory? In *Handbook of Economic Growth*, vol. 2.

## Licence

© Sam Deegan. Released under
[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/):
free to use and share for teaching with attribution; not for commercial use
or redistribution in modified form.
