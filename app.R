################################################################################
## Project: ECON42550 Macroeconomics                                          ##
## Schumpeterian Growth: Interactive Shiny App                                ##
################################################################################

## Author:      Sam Deegan
## Affiliation: University College Dublin
## Email:       sam.deegan@ucdconnect.ie

## Usage:
##   Open app.R in RStudio and click Run App, or from this folder:
##     shiny::runApp()
##   Needs R 4.1 or later with shiny, bslib and ggplot2 installed. A hosted
##   copy runs in the browser at https://sam-deegan.com/toy-models/schumpeter/
##   The stage selector builds the model up one layer at a time:
##     1  the quality ladder, and what an innovation destroys
##     2  the two effects competition has on the incentive to innovate
##     3  the inverted U, and where it peaks
##     4  firm dynamics: entry, and distance to the frontier
##     5  appropriate growth policy
##   Periods are years. All text (scenarios, prompts, equations, notation)
##   lives in B_03.
##
## Inputs:
##   R/model.R (the model) and R/toolkit.R (shared layout and helpers),
##   both sourced automatically by Shiny.
##
## Outputs:
##   None. The app is interactive only.
##
## Packages:
##   shiny, bslib, ggplot2.
##
## Version:
##   B_03_14_version_chr; history in CHANGELOG.md; git tag vX.Y.Z.
##
## References:
##   Aghion, P. and Howitt, P. (1992). A Model of Growth through Creative
##     Destruction. Econometrica 60(2).
##   Aghion, P., Bloom, N., Blundell, R., Griffith, R. and Howitt, P.
##     (2005). Competition and Innovation: An Inverted-U Relationship.
##     Quarterly Journal of Economics 120(2).
##   Aghion, P., Akcigit, U. and Howitt, P. (2014). What Do We Learn from
##     Schumpeterian Growth Theory? Handbook of Economic Growth, vol. 2.

#-------------------------------- Script Begin --------------------------------#

################################################################################
## A: Table of Contents ########################################################
################################################################################
# Note: C (the model) is in R/model.R and T (the toolkit) in R/toolkit.R.
#
#   B: Setup
#     B_01  Packages
#     B_02  Settings
#     B_03  Soft-coded objects
#     B_04  Paths
#   C: Model (R/model.R)
#   T: Toolkit (R/toolkit.R)
#   D: Plots
#     D_01  The ladder and the two effects
#     D_02  The inverted U and firm dynamics
#     D_03  Policy
#   E: User Interface
#   F: Server
#   G: Run

################################################################################
## B: Setup ####################################################################
################################################################################
# Note: Packages, options and every soft-coded value.

#### B_01: Packages ############################################################
# Note: Shiny, bslib for the layout, ggplot2 for the figures.

###### B_01_01: Load Packages ##################################################
# Note: All three run under shinylive.

library(shiny)
library(bslib)
library(ggplot2)

###### B_01_02: Load the Model #################################################
# Note: Shiny sources R/ itself; this covers sourcing app.R by hand.

if (!exists("C_01_04_innovation_fn")) {
  source(file.path("R", "model.R"))
}

###### B_01_03: Load the Toolkit ###############################################
# Note: The shared palette, plot theme, CSS and builders.

if (!exists("T_01_01_palette_vec")) {
  source(file.path("R", "toolkit.R"))
}

#### B_02: Settings ############################################################
# Note: Standard options.

###### B_02_01: Global Options #################################################
# Note: No scientific notation; three digits in the console.

options(scipen = 999, digits = 3)

###### B_02_02: Seed ###########################################################
# Note: Nothing here is random; kept for consistency.

set.seed(42)

#### B_03: Soft-Coded Objects ##################################################
# Note: Calibration, stages, scenarios, controls, equations, text, version.

###### B_03_01: Input Defaults #################################################
# Note: Starting value of every control; Reset returns here. A five per
#   cent productivity step, research costly enough that the aggregate
#   innovation rate is about a quarter a year, and competition just below
#   the level that maximises it, c* = sqrt(2) - 1 (ABBGH 2005).

B_03_01_defaults_lst <- list(
  gamma    = 1.05,  # size of a productivity step
  lambda_r = 1,     # how reliably research produces an innovation
  profit   = 1,     # the rent a technological leader earns
  psi      = 2.5,   # cost of research effort
  comp     = 0.40,  # degree of product market competition
  rho      = 0.05,  # discount rate
  entry    = 0.30,  # threat of entry
  beta_e   = 1,     # how strongly firms respond to it
  distance = 0.30,  # distance from the world technological frontier
  imitate  = 0.35   # how easily a follower can imitate
)

###### B_03_02: Stages #########################################################
# Note: One layer of the model each, all within lecture 3.4.

B_03_02_stages_vec <- c(
  "Stage 1: The Quality Ladder"        = "1",
  "Stage 2: The Two Effects"           = "2",
  "Stage 3: The Inverted U"            = "3",
  "Stage 4: Firm Dynamics"             = "4",
  "Stage 5: Appropriate Growth Policy" = "5"
)

###### B_03_03: Scenarios ######################################################
# Note: Worked examples. Each sets a stage and overrides some defaults;
#   everything it does not name returns to its default when it loads. The
#   story is one paragraph and the prompt one line; see CONVENTIONS.md 2-5.
#   Two points of the model the stories make explicit (ABBGH 2005): the
#   inverted U comes from composition, since escape-competition effort rises
#   in c and laggard effort falls in c over the whole range and the share of
#   unlevelled sectors rises with c; and c* maximises the aggregate
#   innovation rate, not welfare, as does the growth-maximising c of stage 5.

B_03_03_scenarios_lst <- list(
  ladder = list(
    label  = "Big Steps, Rarely",
    stage  = "1",
    values = list(gamma = 1.25, psi = 8),
    story  = paste(
      "The size of a productivity step (γ = 1.25) is raised and the cost of",
      "research (ψ = 8) with it, so each innovation is worth more and firms",
      "buy fewer of them: the staircase gains taller risers and longer",
      "treads. On the vertical axis productivity (A) climbs a quarter at a",
      "time; on the horizontal axis the gap between jumps stretches to",
      "1/I(c) years, the reciprocal of the aggregate innovation rate. The",
      "smooth line is expected productivity, growing at g = I(c)(γ − 1): it",
      "runs a little above steps that arrive exactly on schedule, because",
      "real steps arrive at random. It can sit at almost the same slope as",
      "it would with small frequent steps. How tall a riser is depends on",
      "γ alone;",
      "how far apart the risers fall depends on ψ, on the rent to a leader",
      "(π<sub>0</sub>) and on competition (c), and every riser is an",
      "incumbent being displaced."
    ),
    prompt = paste(
      "Compare the staircase with the smooth line through it. Growth",
      "statistics report the line; the firms in the model live the",
      "staircase."
    )
  ),
  monopoly = list(
    label  = "A Comfortable Monopoly",
    stage  = "2",
    values = list(comp = 0.05),
    story  = paste(
      "Product market competition (c) is set almost to nothing (c = 0.05),",
      "so a firm level with its rival still keeps nearly the whole rent,",
      "π<sub>0</sub>(1 − c), and has almost nothing to escape from. On the",
      "competition axis the example sits at the far left; on the effort axis",
      "the marked point on the escape-competition line, n<sub>neck</sub> =",
      "kc, is just above zero, while the point on the laggard line,",
      "n<sub>lag</sub> = k(1 − c), is close to its highest. The firms with",
      "something to chase are the ones already behind. The height of both",
      "lines is set by k = λπ<sub>0</sub>/ψ, so the rent, the reliability",
      "of research (λ) and its cost (ψ) move them together; c alone",
      "decides how the effort is split between them, and the two lines cross",
      "at c = 0.5."
    ),
    prompt = paste(
      "The escape-competition line is on the floor. Now raise competition",
      "and watch it climb while the Schumpeterian line falls. Which one",
      "wins is what stage 3 is about."
    )
  ),
  cutthroat = list(
    label  = "Cut-Throat Competition",
    stage  = "2",
    values = list(comp = 0.95),
    story  = paste(
      "Competition (c) is pushed almost to its limit (c = 0.95), which",
      "leaves a level firm nearly no rent to defend and a laggard nearly no",
      "prize to chase. On the competition axis the example sits at the far",
      "right; on the effort axis the two marked points have swapped, with",
      "escape-competition effort (n<sub>neck</sub> = kc) near its maximum",
      "and laggard effort (n<sub>lag</sub> = k(1 − c)) near zero. Neither",
      "line turns around anywhere: escape competition rises in c across the",
      "whole range and the laggard effect falls across it. What makes the",
      "aggregate rate at stage 3 collapse at this end is composition —",
      "laggards barely innovate, so sectors almost never draw level, the",
      "share of level sectors (ω<sub>neck</sub>) is tiny, and nearly all the",
      "weight sits on the falling line."
    ),
    prompt = paste(
      "The two lines have swapped places. Look at the aggregate rate at",
      "stage 3: it is low at both ends and high in the middle, for two",
      "different reasons."
    )
  ),
  peak = list(
    label  = "At the Top of the U",
    stage  = "3",
    values = list(comp = 0.414),
    story  = paste(
      "Nothing about the curve changes here: competition (c) is moved to",
      "c = 0.414 = √2 − 1, the top of it. That is the marked point on the",
      "competition axis, and on the vertical axis the aggregate innovation",
      "rate I(c) = 4kc(1 − c)/(1 + c) is at its highest, taking growth",
      "g = I(c)(γ − 1) up with it. The curve turns over not because either",
      "effect reverses — level-firm effort rises in c throughout and laggard",
      "effort falls throughout — but because the share of unlevelled sectors",
      "(1 − ω<sub>neck</sub>) rises with c, shifting weight from the rising",
      "line to the falling one. The height of the peak moves with the cost",
      "of research (ψ), the rent (π<sub>0</sub>) and the step size (γ); its",
      "position does not, because c² + 2c − 1 = 0 contains no other",
      "parameter. It is the competition that maximises innovation, not a",
      "statement about welfare."
    ),
    prompt = paste(
      "Change the cost of research and the step size and watch the height",
      "of the U move while the peak stays put. What does that tell you about",
      "what the peak depends on?"
    )
  ),
  entry = list(
    label  = "The Threat of Entry",
    stage  = "4",
    values = list(entry = 0.5, beta_e = 1),
    story  = paste(
      "The threat of entry (e = 0.5) is raised and incumbents are made fully",
      "responsive to it (β = 1), which adds kβe(1 − 2d) to an incumbent's",
      "research effort. On the horizontal axis, a firm's distance from the",
      "frontier (d), the bars are positive to the left of d = 0.5 and",
      "negative to the right, so on the vertical axis the same policy raises",
      "effort for firms close to the frontier and lowers it for firms far",
      "behind. A firm near the frontier can hope to outrun the entrant and",
      "innovates to do it; one far behind cannot, so the expected gain from",
      "trying has fallen and it stops. How tall the bars are depends on e,",
      "on β and on the scale k; where the sign flips does not, and this",
      "expression is a reduced form chosen to reproduce that sign pattern,",
      "not one solved out of the step-by-step model."
    ),
    prompt = paste(
      "This is the firm-dynamics prediction to be able to state in an exam:",
      "the effect of entry on incumbent innovation depends on distance to",
      "the frontier, and changes sign."
    )
  ),
  behind = list(
    label  = "A Country Far Behind",
    stage  = "5",
    values = list(distance = 0.85, imitate = 0.5),
    story  = paste(
      "The country is placed a long way from the world frontier (D = 0.85)",
      "and imitation is made easy (m = 0.5), so in",
      "g(c, D) = [(1 − D) I(c) + D m (1 − c)](γ − 1) the inventing term",
      "shrinks and the copying term grows: the inventing curve flattens",
      "towards the axis while the downward-sloping copying line rises. On",
      "the competition axis the maximum of the total curve moves left; on",
      "the growth axis the total is now made mostly of copying, which",
      "competition erodes rather than encourages. The second figure traces",
      "that maximum against distance: at the frontier it is the top of the",
      "inverted U, √2 − 1, and far behind it is much lower. How much lower",
      "depends on D and on the ease of imitation (m) — and what is marked is",
      "the competition that maximises measured growth, not the level that is",
      "socially best."
    ),
    prompt = paste(
      "Slide the distance from 0.85 down to 0.05 and watch the best level of",
      "competition rise. Institutions that are right for catching up are not",
      "the ones that are right at the frontier."
    )
  )
)

###### B_03_04: Controls #######################################################
# Note: One entry per numeric control: label (HTML), slider range and step,
#   and the stage from which it appears.

B_03_04_controls_lst <- list(
  comp     = list(label = "Product Market Competition (c)",
                  min = 0.01, max = 0.99, step = 0.01, from = 1),
  gamma    = list(label = "Size of a Productivity Step (γ)",
                  min = 1.01, max = 1.5, step = 0.01, from = 1),
  psi      = list(label = "Cost of Research (ψ)",
                  min = 0.5, max = 12, step = 0.5, from = 1),
  profit   = list(label = "Rent to a Technological Leader (π)",
                  min = 0.2, max = 3, step = 0.1, from = 2),
  lambda_r = list(label = "Reliability of Research (λ)",
                  min = 0.2, max = 2, step = 0.1, from = 2),
  rho      = list(label = "Discount Rate (ρ)",
                  min = 0.01, max = 0.2, step = 0.01, from = 1),
  entry    = list(label = "Threat of Entry (e)",
                  min = 0, max = 1, step = 0.05, from = 4),
  beta_e   = list(label = "Sensitivity to Entry (β)",
                  min = 0, max = 2, step = 0.1, from = 4),
  distance = list(label = "Distance from the Frontier (D)",
                  min = 0, max = 0.95, step = 0.05, from = 5),
  imitate  = list(label = "How Easily One Can Imitate (m)",
                  min = 0.05, max = 1, step = 0.05, from = 5)
)

###### B_03_05: Parameter Explanations #########################################
# Note: What each control is and what raising it does.

B_03_05_help_lst <- list(
  comp = paste(
    "How hard it is to earn a rent when your rival is level with you. It",
    "does two opposite things at once, which is why the relationship with",
    "innovation is not monotonic."
  ),
  gamma = paste(
    "How much an innovation raises productivity. It sets the size of each",
    "step on the ladder, and so how much growth each innovation delivers."
  ),
  psi = paste(
    "How expensive research effort is. It scales every firm's effort and so",
    "the height of the inverted U, but not where the peak is."
  ),
  profit = paste(
    "What a firm earns while it holds a technological lead. The prize that",
    "makes research worth doing, and the monopoly rent that competition",
    "policy is usually trying to remove."
  ),
  lambda_r = "How reliably research effort turns into an actual innovation.",
  rho = paste(
    "How future rents are discounted. Together with the rate of creative",
    "destruction it decides what a lead is worth today."
  ),
  entry = paste(
    "How likely it is that a new firm appears. Raising it has opposite",
    "effects on firms near the frontier and firms far from it, which is the",
    "model's sharpest firm-level prediction."
  ),
  beta_e = "How strongly incumbents respond to the threat of entry.",
  distance = paste(
    "How far the country is from the world technological frontier. At 0 it",
    "is at the frontier and can only grow by inventing; at 1 it is far",
    "behind and can grow by copying."
  ),
  imitate = paste(
    "How easily a follower can adopt what others have invented. Imitation",
    "rests on incumbents with secure rents, so competition works against it."
  )
)

###### B_03_06: Prompts ########################################################
# Note: One "what to try" prompt per stage, shown above the figures.

B_03_06_prompts_lst <- list(
  "1" = paste(
    "Growth here is not smooth: it is a sequence of steps, each one the",
    "moment a firm is displaced. Raise the step size and lower the rate of",
    "innovation to keep growth the same, and look at what changes for the",
    "firms."
  ),
  "2" = paste(
    "Competition does two opposite things. It makes being level with a",
    "rival unprofitable, so level firms innovate to escape it; and it",
    "shrinks the prize a laggard is chasing, so laggards innovate less.",
    "Watch the two lines cross."
  ),
  "3" = paste(
    "Put the two effects together and innovation is highest at moderate",
    "competition. Change anything else you like: the peak stays at √2 − 1.",
    "That is the inverted U of Aghion and co-authors."
  ),
  "4" = paste(
    "Raise the threat of entry. Firms near the frontier respond by",
    "innovating harder; firms far behind give up. Being able to state that",
    "prediction, and say why, is what the exam question asks for."
  ),
  "5" = paste(
    "Slide the distance from the frontier and watch the growth-maximising",
    "level of competition move. The same policy is right for one country",
    "and wrong for another, which is the appropriate-institutions argument."
  )
)

###### B_03_07: The Model, Stage by Stage ######################################
# Note: The equations panel.

B_03_07_equations_lst <- list(

  # --- The model's equations --------------------------------------------------
  list(
    group = "model", label = "The Ladder",
    versions = list("1" = paste0("A_{t+1} = \\gamma A_t \\text{ on each",
                                 " innovation},\\ \\gamma > 1")),
    notes = list(
      "1" = paste("Productivity improves in discrete steps, each one the",
                  "work of a firm that has displaced another.")
    )
  ),
  list(
    group = "model", label = "Profits",
    versions = list(
      "1" = "\\pi_{leader} = \\pi_0",
      "2" = paste0("\\pi_{leader} = \\pi_0,\\quad \\pi_{neck} = \\pi_0",
                   "(1-c),\\quad \\pi_{lag} = 0")
    ),
    notes = list(
      "1" = "A technological lead is worth a rent while it lasts.",
      "2" = paste("Competition erodes the profit of a firm that is level",
                  "with its rival, and not that of a firm with a lead. That",
                  "asymmetry is the whole mechanism.")
    )
  ),
  list(
    group = "model", label = "Research",
    versions = list("2" = paste0("\\max_n\\ \\lambda n \\Delta - \\tfrac{1}",
                                 "{2}\\psi n^2 \\ \\Rightarrow\\ n =",
                                 " \\frac{\\lambda \\Delta}{\\psi}")),
    notes = list(
      "2" = paste("Effort is proportional to the gain from innovating. All",
                  "that differs between firms is what that gain is.")
    )
  ),
  list(
    group = "model", label = "Entry",
    versions = list("4" = "e \\text{ threat of entry}"),
    notes = list(
      "4" = paste("An outside firm may appear with the frontier technology.",
                  "What that does to an incumbent depends on whether the",
                  "incumbent could beat it.")
    )
  ),

  # --- Assumptions ------------------------------------------------------------
  list(
    group = "assumption", label = "Step by Step",
    versions = list("2" = "\\text{a laggard is one step behind}"),
    notes = list(
      "2" = paste("A firm cannot leapfrog: it must catch up before it can",
                  "lead. That is what creates neck-and-neck sectors, and",
                  "without them there is no escape-competition effect.")
    )
  ),
  list(
    group = "assumption", label = "Creative Destruction",
    versions = list("1" = "\\text{the innovator replaces the incumbent}"),
    notes = list(
      "1" = paste("Growth is not something that happens to firms; it",
                  "happens to them. Every innovation destroys a rent",
                  "somebody was earning.")
    )
  ),
  list(
    group = "assumption", label = "Rents Are Necessary",
    versions = list("2" = "\\pi_0 > 0"),
    notes = list(
      "2" = paste("Without monopoly rent nobody pays for research. This is",
                  "why competition policy and innovation policy pull against",
                  "each other, and why the answer is not simply more",
                  "competition.")
    )
  ),

  # --- Solved forms -----------------------------------------------------------
  list(
    group = "solved", label = "Escape Competition",
    versions = list("2" = "n_{neck} = k\\,c,\\qquad k = \\lambda\\pi_0/\\psi"),
    notes = list(
      "2" = paste("The gain to a level firm is π₀c, which RISES with",
                  "competition. Firms innovate to get away from a rival that",
                  "is taking their profit.")
    )
  ),
  list(
    group = "solved", label = "The Schumpeterian Effect",
    versions = list("2" = "n_{lag} = k\\,(1 - c)"),
    notes = list(
      "2" = paste("The gain to a laggard is π₀(1−c), which FALLS with",
                  "competition. The prize it is chasing has been",
                  "competed away.")
    )
  ),
  list(
    group = "solved", label = "The Mix of Sectors",
    versions = list("3" = paste0("\\omega_{neck} = \\frac{n_{lag}}",
                                 "{n_{lag} + 2 n_{neck}}")),
    notes = list(
      "3" = paste("In steady state sectors leave the level state as fast as",
                  "they arrive. More escape-competition effort means fewer",
                  "level sectors to do it.")
    )
  ),
  list(
    group = "solved", label = "Aggregate Innovation",
    versions = list("3" = "I(c) = \\frac{4kc(1-c)}{1+c}"),
    notes = list(
      "3" = paste("The two effects combined. Zero at both ends, positive in",
                  "between: the inverted U.")
    )
  ),
  list(
    group = "solved", label = "Where It Peaks",
    versions = list("3" = "c^* = \\sqrt{2} - 1 \\approx 0.414"),
    notes = list(
      "3" = paste("From c² + 2c − 1 = 0. It does not depend on the cost of",
                  "research, the size of a step or the rent: only on the",
                  "shape of the two effects.")
    )
  ),
  list(
    group = "solved", label = "Growth",
    versions = list("3" = "g = I(c)\\,(\\gamma - 1)"),
    notes = list(
      "3" = paste("How often productivity improves, times how much it",
                  "improves by. Output is the sum of sector outputs, so",
                  "a step counts as γ − 1; Aghion and Howitt (1992) write",
                  "ln γ, which is close for small steps.")
    )
  ),
  list(
    group = "solved", label = "The Value of a Lead",
    versions = list("1" = "V = \\frac{\\pi_0}{\\rho + n_{lag}}"),
    notes = list(
      "1" = paste("The rent, discounted, and eroded by the chance of being",
                  "overtaken. Creative destruction is a tax on the incumbent",
                  "and the engine of growth at the same time.")
    )
  ),
  list(
    group = "solved", label = "Entry and Distance",
    versions = list("4" = paste0("n(d, e) = k\\big[(1-d) + \\beta e",
                                 "(1 - 2d)\\big]")),
    notes = list(
      "4" = paste("A reduced form for the firm-level prediction: entry",
                  "raises innovation for firms near the frontier (d small)",
                  "and lowers it for firms far from it. The sign flips",
                  "half-way.")
    )
  ),
  list(
    group = "solved", label = "Appropriate Policy",
    versions = list("5" = paste0("g(c, D) = \\big[(1-D) I(c) + D\\,m",
                                 "(1-c)\\big](\\gamma - 1)")),
    notes = list(
      "5" = paste("A country grows partly by inventing and partly by",
                  "copying. Competition helps the first and hinders the",
                  "second, so the best level of it depends on how far behind",
                  "the country is.")
    )
  ),

  # --- Descriptors ------------------------------------------------------------
  list(
    group = "descriptor", label = "Firm Dynamics: Turnover",
    versions = list("4" = "\\text{expected lead} = 1/n_{lag}"),
    notes = list(
      "4" = paste("Leaders are displaced at the rate laggards innovate, so",
                  "the model predicts continual turnover at the top of each",
                  "industry — and more of it where laggards try hardest.")
    )
  ),
  list(
    group = "descriptor", label = "Firm Dynamics: Entry",
    versions = list("4" = paste0("\\frac{\\partial n}{\\partial e} > 0",
                                 " \\text{ near the frontier},\\ < 0",
                                 " \\text{ far from it}")),
    notes = list(
      "4" = paste("The second prediction the exam question asks for. It is",
                  "testable, and it has been tested on the entry of foreign",
                  "firms into UK industries.")
    )
  )
)

###### B_03_08: Equation Group Titles ##########################################
# Note: Group headings in the equations tabs.

B_03_08_groups_vec <- c(
  model      = "Model Equations",
  assumption = "Assumptions",
  solved     = "Solved Forms",
  descriptor = "Descriptors"
)

###### B_03_09: Notation Key ###################################################
# Note: Every symbol in the equations, with its group and first stage.

B_03_09_notation_lst <- list(
  list(grp = "var", sym = "A_t", txt = "productivity", from = 1),
  list(grp = "par", sym = "\\gamma", txt = "size of a productivity step",
       from = 1),
  list(grp = "par", sym = "\\pi_0", txt = "rent to a leader", from = 1),
  list(grp = "par", sym = "\\rho", txt = "discount rate", from = 1),
  list(grp = "var", sym = "V", txt = "value of a technological lead",
       from = 1),
  list(grp = "par", sym = "c", txt = "product market competition", from = 1),
  list(grp = "par", sym = "\\psi", txt = "cost of research effort", from = 2),
  list(grp = "par", sym = "\\lambda", txt = "reliability of research",
       from = 2),
  list(grp = "par", sym = "k", txt = "lambda pi over psi", from = 2),
  list(grp = "var", sym = "n", txt = "research effort", from = 2),
  list(grp = "var", sym = "\\omega_{neck}", txt = "share of level sectors",
       from = 3),
  list(grp = "flw", sym = "I(c)", txt = "aggregate innovation rate", from = 3),
  list(grp = "flw", sym = "c^*", txt = "competition that maximises it",
       from = 3),
  list(grp = "par", sym = "e", txt = "threat of entry", from = 4),
  list(grp = "par", sym = "d", txt = "a firm's distance from the frontier",
       from = 4),
  list(grp = "par", sym = "D", txt = "the country's distance from it",
       from = 5),
  list(grp = "par", sym = "m", txt = "ease of imitation", from = 5)
)

###### B_03_10: Notation Columns ###############################################
# Note: How the notation tab is split into columns.

B_03_10_nota_cols_lst <- list(
  "Variables"  = "var",
  "Parameters" = "par",
  "Results"    = "flw"
)

###### B_03_11: Full-Width Figure Height #######################################
# Note: Height in the browser of a figure that runs the full width of the
#   page.

B_03_11_tall_chr <- "410px"

###### B_03_12: Half-Width Figure Height #######################################
# Note: Height of a figure that shares a row with another. Taller, so a
#   two-line title, a long rotated axis title and a legend fit a narrow card.

B_03_12_square_chr <- "540px"

###### B_03_13: Recalculation Delay ############################################
# Note: Milliseconds to wait for further changes before recalculating.

B_03_13_debounce_ms_int <- 250L

###### B_03_14: Version ########################################################
# Note: Semantic version, shown in the footer; CHANGELOG.md has the history.

B_03_14_version_chr <- "1.0.2"

###### B_03_15: Source Repository ##############################################
# Note: The GitHub repo, linked from the footer.

B_03_15_repo_chr <- paste0("https://github.com/Sam-Deegan/",
                        "Interactive-Model-Schumpeterian-Growth")

#### B_04: Paths ###############################################################
# Note: The QR code only.

###### B_04_01: QR Code Source #################################################
# Note: Resolved by the toolkit; www/ first.

B_04_01_qr_src_chr <- T_07_04_qr_fn()

################################################################################
## D: Plots ####################################################################
################################################################################
# Note: Builders only; each returns a ggplot for the server to draw. Figure
#   conventions: see CONVENTIONS.md 6.

#### D_01: The Ladder and the Two Effects ######################################
# Note: What growth looks like from inside a firm, and what competition does
#   to the incentive to innovate.

###### D_01_01: The Quality Ladder #############################################
# Note: Productivity as a staircase, with the average growth rate drawn
#   through it. The first riser is marked as the waiting time 1/I(c).

D_01_01_ladder_fn <- function(par, ref = NULL) {
  rate <- C_01_04_innovation_fn(par)
  if (!is.finite(rate) || rate <= 0) {
    return(T_02_02_placeholder_fn(
      "Nobody is innovating at this level of competition."))
  }
  span  <- 40
  gap   <- 1 / rate
  steps <- floor(span / gap)
  times <- if (steps >= 1) gap * seq_len(steps) else numeric(0)

  grid <- seq(0, span, length.out = 600)
  lvl  <- vapply(grid, function(t) par$gamma^sum(times <= t), 0)
  avg  <- exp(C_01_05_growth_fn(par) * grid)

  df <- rbind(
    data.frame(t = grid, value = lvl, line = "Productivity"),
    data.frame(t = grid, value = avg, line = "Average Growth")
  )
  df$line <- factor(df$line, levels = c("Productivity", "Average Growth"))

  # Name the waiting time only when the label has room
  mark_gap <- gap >= span * 0.08 && gap <= span

  # Ghost: the same staircase and line at the reference settings
  ghost_lyr <- if (T_02_03b_ghost_off_fn(par, ref)) NULL else {
    g_rate <- C_01_04_innovation_fn(ref)
    if (!is.finite(g_rate) || g_rate <= 0) NULL else {
      g_gap   <- 1 / g_rate
      g_steps <- floor(span / g_gap)
      g_times <- if (g_steps >= 1) g_gap * seq_len(g_steps) else numeric(0)
      list(
        T_02_03a_ghost_line_fn(
          data.frame(t = grid,
                     value = vapply(grid, function(t) {
                       ref$gamma^sum(g_times <= t)
                     }, 0)),
          aes(x = t, y = value),
          colour = T_01_02_series_vec[["main"]], linewidth = 1.05),
        T_02_03a_ghost_line_fn(
          data.frame(t = grid, value = exp(C_01_05_growth_fn(ref) * grid)),
          aes(x = t, y = value),
          colour = T_01_02_series_vec[["compare"]], linewidth = 1.05,
          linetype = "22")
      )
    }
  }

  ggplot(df, aes(x = t, y = value, colour = line, linetype = line)) +
    (if (mark_gap) T_02_02_rest_fn(v = gap)) +
    ghost_lyr +
    geom_line(linewidth = 1.05) +
    scale_colour_manual(values = c(
      "Productivity"    = T_01_02_series_vec[["main"]],
      "Average Growth"  = T_01_02_series_vec[["compare"]]
    )) +
    scale_linetype_manual(values = c("Productivity" = "solid",
                                     "Average Growth" = "22")) +
    (if (mark_gap) T_02_02_mark_x_fn(gap, expression(1 / I(c)))) +
    labs(
      x = expression(bold("Year (" * t * ")")),
      y = expression(bold("Productivity (" * A[t] * ")")),
      caption = paste0(
        "Growth averages ", T_02_06_pct_fn(C_01_05_growth_fn(par), 2),
        " a year, but it arrives in steps, and every step is a firm being",
        " displaced."
      )
    ) +
    T_02_01_theme_fn(grid = "h")
}

###### D_01_02: The Two Effects ################################################
# Note: Research effort by type of firm across the range of competition,
#   each line named at its high end. The two cross at c = 0.5.

D_01_02_effects_fn <- function(par, ref = NULL) {
  df <- C_01_06_curve_fn(par, 300)

  long <- rbind(
    data.frame(comp = df$comp, value = df$escape,
               line = "Level Firms (Escape Competition)"),
    data.frame(comp = df$comp, value = df$schumpeter,
               line = "Laggards (Schumpeterian)")
  )
  long$line <- factor(long$line,
                      levels = c("Level Firms (Escape Competition)",
                                 "Laggards (Schumpeterian)"))
  eff   <- C_01_02_effort_fn(par)
  k     <- eff$scale
  x_lim <- c(0, 1)
  y_lim <- c(0, k * 1.18)

  # Ghost: both lines and both markers at the reference settings
  ghost_lyr <- if (T_02_03b_ghost_off_fn(par, ref)) NULL else {
    g_df  <- C_01_06_curve_fn(ref, 300)
    g_eff <- C_01_02_effort_fn(ref)
    list(
      T_02_03a_ghost_line_fn(
        data.frame(comp = g_df$comp, value = g_df$escape),
        aes(x = comp, y = value),
        colour = T_01_02_series_vec[["main"]], linewidth = 1.1),
      T_02_03a_ghost_line_fn(
        data.frame(comp = g_df$comp, value = g_df$schumpeter),
        aes(x = comp, y = value),
        colour = T_01_02_series_vec[["compare"]], linewidth = 1.1,
        linetype = "22"),
      T_02_03a_ghost_point_fn(ref$comp, g_eff$neck),
      T_02_03a_ghost_point_fn(ref$comp, g_eff$laggard,
                              T_01_02_series_vec[["compare"]], 2.8)
    )
  }

  ggplot(long, aes(x = comp, y = value, colour = line, linetype = line)) +
    T_02_02_rest_fn(v = 0.5) +
    ghost_lyr +
    geom_line(linewidth = 1.1) +
    T_02_03_point_fn(par$comp, eff$neck) +
    T_02_03_point_fn(par$comp, eff$laggard,
                     T_01_02_series_vec[["compare"]], 2.8) +
    scale_colour_manual(values = c(
      "Level Firms (Escape Competition)" = T_01_02_series_vec[["main"]],
      "Laggards (Schumpeterian)"         = T_01_02_series_vec[["compare"]]
    )) +
    scale_linetype_manual(values = c(
      "Level Firms (Escape Competition)" = "solid",
      "Laggards (Schumpeterian)"         = "22"
    )) +
    T_02_02_mark_x_fn(0.5, expression(c == 0.5)) +
    coord_cartesian(xlim = x_lim, ylim = y_lim, expand = FALSE) +
    # Names hang from the top of the panel, so k cannot push them off it
    annotate("text", x = x_lim[2], y = y_lim[2],
             label = "'Neck-and-neck  '*n[neck]",
             parse = TRUE, size = 3.2, hjust = 1, vjust = 1.5,
             colour = T_01_01_palette_vec[["muted"]]) +
    annotate("text", x = x_lim[1], y = y_lim[2],
             label = "'Laggard  '*n[lag]",
             parse = TRUE, size = 3.2, hjust = 0, vjust = 1.5,
             colour = T_01_01_palette_vec[["muted"]]) +
    labs(
      x = expression(bold("Product market competition (" * c * ")")),
      y = expression(bold("Research effort (" * n * ")")),
      caption = paste(
        "Competition raises the gain to a firm that is level with its rival",
        "and lowers the gain to one that is behind. The two cross at c = 0.5.",
        "Read this figure vertically, not as an area: at each level of",
        "competition what matters is which line is higher and by how much.",
        "The space between them is not a quantity of anything, because the",
        "aggregate rate at stage 3 is a WEIGHTED average of the two, and the",
        "weights are the shares of sectors that are level or unlevel, which",
        "themselves move with competition."
      )
    ) +
    T_02_01_theme_fn(grid = "none") +
    # Extra right margin so the last tick label keeps its final digit
    theme(legend.position = "none",
          plot.margin = margin(5.5, 14, 5.5, 5.5))
}

#### D_02: The Inverted U and Firm Dynamics ####################################
# Note: The aggregate result, and what it means for firms.

###### D_02_01: The Inverted U #################################################
# Note: Aggregate innovation against competition. c* and I(c*) are dotted
#   reference lines named on the axes; a short tangent marks the peak.

D_02_01_inverted_fn <- function(par, ref = NULL) {
  df   <- C_01_06_curve_fn(par, 300)
  peak <- C_01_07_peak_fn(par)
  now  <- C_01_04_innovation_fn(par)

  # Ghost: the whole U at the reference settings, with both markers
  ghost_on <- !T_02_03b_ghost_off_fn(par, ref)
  g_pk     <- if (ghost_on) C_01_07_peak_fn(ref) else NULL
  ghost_lyr <- if (!ghost_on) NULL else {
    list(
      T_02_03a_ghost_line_fn(C_01_06_curve_fn(ref, 300),
                             aes(x = comp, y = innovation),
                             colour = T_01_02_series_vec[["main"]],
                             linewidth = 1.2),
      T_02_03a_ghost_point_fn(g_pk$comp, g_pk$innovation,
                              T_01_02_series_vec[["compare"]], 5.2),
      T_02_03a_ghost_point_fn(ref$comp, C_01_04_innovation_fn(ref))
    )
  }

  # Window takes in both peaks, with headroom for the tangent's name
  y_top <- max(c(peak$innovation, g_pk$innovation)) * 1.24

  # Half-width of the tangent segment at the peak
  tan_half <- 0.16

  ggplot(df, aes(x = comp, y = innovation)) +
    T_02_02_rest_fn(h = peak$innovation, v = peak$comp) +
    ghost_lyr +
    geom_line(colour = T_01_02_series_vec[["main"]], linewidth = 1.2) +
    annotate("segment",
             x = max(peak$comp - tan_half, 0),
             xend = min(peak$comp + tan_half, 1),
             y = peak$innovation, yend = peak$innovation,
             colour = T_01_02_series_vec[["compare"]], linewidth = 1.1) +
    # Name runs rightwards from the end of the segment, clear of the c* line
    annotate("text", x = peak$comp + tan_half, y = peak$innovation,
             label = "'Tangent at '*c^'*'", parse = TRUE,
             size = 3.2, hjust = 0, vjust = -1.15,
             colour = T_01_01_palette_vec[["muted"]]) +
    # Peak marker larger than the live one, so both show when they coincide
    T_02_03_point_fn(peak$comp, peak$innovation,
                     colour = T_01_02_series_vec[["compare"]], size = 5.2) +
    T_02_03_point_fn(par$comp, now) +
    T_02_02_mark_x_fn(peak$comp, expression(c^"*")) +
    T_02_02_mark_y_fn(peak$innovation, expression(I(c^"*"))) +
    coord_cartesian(ylim = c(0, y_top)) +
    labs(
      x = expression(bold("Product market competition (" * c * ")")),
      y = expression(bold("Aggregate innovation rate (" * I(c) * ")")),
      caption = paste(
        "What is being maximised is the aggregate innovation rate, and so",
        "growth, which is that rate times the size of a step. The curve is",
        "level at c*, so a little more or less competition there costs",
        "nothing to first order. The open navy marker is where the sliders",
        "have you; the green one is the peak. Zero at both ends for two",
        "different reasons, and c* = 0.414 whatever the rest of the",
        "calibration."
      )
    ) +
    T_02_01_theme_fn(grid = "none")
}

###### D_02_02: Entry and Distance to the Frontier #############################
# Note: Change in an incumbent's research effort when entry threatens,
#   against its distance from the frontier. The sign flips at d = 1/2.

D_02_02_entry_fn <- function(par, ref = NULL) {
  df <- C_01_09_entry_fn(par, 300)
  df$sign <- ifelse(df$response >= 0, "Innovates More", "Gives Up")

  # Ghost: the line the tops of the reference bars trace, cut at the sign change
  ghost_lyr <- if (T_02_03b_ghost_off_fn(par, ref)) NULL else {
    g_df <- C_01_09_entry_fn(ref, 300)
    g_up <- g_df[g_df$response >= 0, , drop = FALSE]
    g_dn <- g_df[g_df$response < 0, , drop = FALSE]
    list(
      if (nrow(g_up) > 0) {
        T_02_03a_ghost_line_fn(g_up, aes(x = distance, y = response),
                               colour = T_01_01_palette_vec[["green"]],
                               linewidth = 1.1)
      },
      if (nrow(g_dn) > 0) {
        T_02_03a_ghost_line_fn(g_dn, aes(x = distance, y = response),
                               colour = T_01_01_palette_vec[["navy"]],
                               linewidth = 1.1)
      }
    )
  }

  ggplot(df, aes(x = distance, y = response, fill = sign)) +
    T_02_02_zero_fn(h = TRUE, v = FALSE) +
    T_02_02_rest_fn(v = 0.5) +
    ghost_lyr +
    geom_col(width = 1 / 300) +
    scale_fill_manual(values = c(
      "Innovates More" = T_01_01_palette_vec[["green"]],
      "Gives Up"       = T_01_01_palette_vec[["navy"]]
    )) +
    T_02_02_mark_x_fn(0.5, expression(d == 1 / 2)) +
    labs(
      x = expression(bold("Distance from the frontier (" * d * ")")),
      y = expression(bold("Change in research effort (" * Delta * n * ")")),
      caption = paste(
        "Firms close enough to win innovate harder to escape the entrant;",
        "firms too far behind to win stop trying. Same policy, opposite",
        "effects."
      )
    ) +
    T_02_01_theme_fn(grid = "none")
}

#### D_03: Policy ##############################################################
# Note: What competition is worth to a country, given where it stands.

###### D_03_01: Growth Against Competition, by Source ##########################
# Note: Growth from inventing, from copying and in total, with the
#   growth-maximising competition c*(D) as a dotted vertical named on top.

D_03_01_policy_fn <- function(par, ref = NULL) {
  pol <- C_01_10_policy_fn(par, 300)
  df  <- pol$curve

  long <- rbind(
    data.frame(comp = df$comp, value = df$total, line = "Total Growth"),
    data.frame(comp = df$comp, value = df$innovate, line = "Inventing"),
    data.frame(comp = df$comp, value = df$imitate, line = "Copying")
  )
  long$line <- factor(long$line, levels = c("Total Growth", "Inventing",
                                            "Copying"))

  # Ghost: all three series and the peak marker at the reference settings
  ghost_lyr <- if (T_02_03b_ghost_off_fn(par, ref)) NULL else {
    g_pol <- C_01_10_policy_fn(ref, 300)
    g_df  <- g_pol$curve
    list(
      T_02_03a_ghost_line_fn(
        data.frame(comp = g_df$comp, value = g_df$total),
        aes(x = comp, y = value),
        colour = T_01_02_series_vec[["main"]], linewidth = 1.05),
      T_02_03a_ghost_line_fn(
        data.frame(comp = g_df$comp, value = g_df$innovate),
        aes(x = comp, y = value),
        colour = T_01_02_series_vec[["third"]], linewidth = 1.05,
        linetype = "22"),
      T_02_03a_ghost_line_fn(
        data.frame(comp = g_df$comp, value = g_df$imitate),
        aes(x = comp, y = value),
        colour = T_01_02_series_vec[["compare"]], linewidth = 1.05,
        linetype = "22"),
      T_02_03a_ghost_point_fn(g_pol$best, g_pol$best_growth)
    )
  }

  ggplot(long, aes(x = comp, y = value, colour = line, linetype = line)) +
    T_02_02_rest_fn(v = pol$best) +
    ghost_lyr +
    geom_line(linewidth = 1.05) +
    T_02_03_point_fn(pol$best, pol$best_growth) +
    scale_colour_manual(values = c(
      "Total Growth" = T_01_02_series_vec[["main"]],
      "Inventing"    = T_01_02_series_vec[["third"]],
      "Copying"      = T_01_02_series_vec[["compare"]]
    )) +
    scale_linetype_manual(values = c("Total Growth" = "solid",
                                     "Inventing" = "22",
                                     "Copying" = "22")) +
    scale_y_continuous(labels = function(x) paste0(round(x * 100, 1), "%")) +
    T_02_02_mark_x_fn(pol$best, expression(c^"*" * (D))) +
    labs(
      x = expression(bold("Product market competition (" * c * ")")),
      y = expression(bold("Growth rate (" * g * ")")),
      caption = paste(
        "Competition raises growth from inventing and lowers growth from",
        "copying, so the best level of it depends on which one the country",
        "is doing. c*(D) is the competition that maximises measured growth",
        "at this distance, not the level that is socially best."
      )
    ) +
    T_02_01_theme_fn(grid = "h")
}

###### D_03_02: The Best Level of Competition ##################################
# Note: The growth-maximising level of competition against distance from
#   the frontier, with the country's own D and c*(D) as dotted lines.

D_03_02_frontier_fn <- function(par, ref = NULL) {
  df   <- C_01_11_frontier_fn(par, 60)
  here <- df$best_comp[which.min(abs(df$distance - par$distance))]

  # Ghost: the locus and the marker at the reference settings
  g_df <- if (T_02_03b_ghost_off_fn(par, ref)) NULL else {
    C_01_11_frontier_fn(ref, 60)
  }
  ghost_lyr <- if (is.null(g_df)) NULL else {
    g_here <- g_df$best_comp[which.min(abs(g_df$distance - ref$distance))]
    list(
      T_02_03a_ghost_line_fn(g_df, aes(x = distance, y = best_comp),
                             colour = T_01_02_series_vec[["main"]],
                             linewidth = 1.2),
      T_02_03a_ghost_point_fn(ref$distance, g_here)
    )
  }

  ggplot(df, aes(x = distance, y = best_comp)) +
    T_02_02_rest_fn(h = here, v = par$distance) +
    ghost_lyr +
    geom_line(colour = T_01_02_series_vec[["main"]], linewidth = 1.2) +
    T_02_03_point_fn(par$distance, here) +
    T_02_02_mark_x_fn(par$distance, expression(D)) +
    T_02_02_mark_y_fn(here, expression(c^"*" * (D))) +
    coord_cartesian(ylim = c(0, max(c(df$best_comp, g_df$best_comp)) * 1.15)) +
    labs(
      x = expression(bold("Distance from the frontier (" * D * ")")),
      # Two lines, so the rotated title fits the panel height on a slide
      y = expression(atop(bold("Growth-maximising"),
                          bold("competition (" * c^"*" * ")"))),
      caption = paste(
        "At the frontier the answer is the top of the inverted U. Far behind",
        "it is much lower, because growth then comes from copying, and",
        "copying needs rents."
      )
    ) +
    T_02_01_theme_fn(grid = "h")
}

################################################################################
## E: User Interface ###########################################################
################################################################################
# Note: bslib page: controls in a sidebar, figures in cards.

#### E_01: Sidebar #############################################################
# Note: Stage selector, then the controls. The sidebar chooses the model and
#   the main window chooses what to run in it; see CONVENTIONS.md 1.

###### E_01_01: Control Shorthand ##############################################
# Note: Label with tooltip, slider and box, from the toolkit.

E_01_01_ctl_fn <- function(id) {
  T_03_01_control_fn(id, B_03_04_controls_lst, B_03_05_help_lst,
                     B_03_01_defaults_lst)
}

###### E_01_02: Sidebar ########################################################
# Note: conditionalPanel reveals controls as the stages add layers.

E_01_02_sidebar_lst <- sidebar(
  width = 380,
  radioButtons("stage", "Stage of the Model",
               choices = B_03_02_stages_vec, selected = "1"),
  T_03_05_note_fn(paste(
    "Each stage adds one piece to the model and leaves the rest",
    "alone. Start at the top; the equations panel marks what is new.",
    "Move a slider and a faded copy of each figure stays behind at the",
    "settings you started from, so you can see what your change did.")),
  accordion(
    open = c("Competition and Innovation"),
    accordion_panel(
      "Competition and Innovation",
      E_01_01_ctl_fn("comp"),
      E_01_01_ctl_fn("gamma"),
      E_01_01_ctl_fn("psi"),
      E_01_01_ctl_fn("rho"),
      conditionalPanel("parseFloat(input.stage) >= 2",
                       E_01_01_ctl_fn("profit"),
                       E_01_01_ctl_fn("lambda_r"))
    ),
    accordion_panel(
      "Entry",
      conditionalPanel(
        "parseFloat(input.stage) >= 4",
        E_01_01_ctl_fn("entry"),
        E_01_01_ctl_fn("beta_e")
      ),
      conditionalPanel("parseFloat(input.stage) < 4",
                       tags$p(class = "stat-caption",
                              "Entry appears at stage 4."))
    ),
    accordion_panel(
      "The Country",
      conditionalPanel(
        "parseFloat(input.stage) >= 5",
        E_01_01_ctl_fn("distance"),
        E_01_01_ctl_fn("imitate")
      ),
      conditionalPanel("parseFloat(input.stage) < 5",
                       tags$p(class = "stat-caption",
                              "Policy appears at stage 5."))
    )
  ),
  actionButton("reset", "Reset Everything",
               class = "btn-outline-secondary btn-sm w-100")
)

#### E_02: Main Panel ##########################################################
# Note: Equations card, presets, prompt, readouts, then the figures.

###### E_02_01: Worked-Example Presets #########################################
# Note: Preset card for the main window, from the toolkit (T_05_04 to
#   T_05_07). Only the presets of the stage on screen are shown.

E_02_01_presets_lst <- T_05_04_presets_fn(
  B_03_03_scenarios_lst, B_03_02_stages_vec, stage_word = "Stage"
)

###### E_02_02: Page ###########################################################
# Note: The UI passed to shinyApp(). The second tags$head carries the preset
#   card's CSS and JS; T_07_08_head_fn() supplies the rest.

E_02_02_app_ui_lst <- tagList(
  T_07_08b_nav_fn(),
  page_sidebar(
  title        = T_07_09_title_fn("Growth Model: Schumpeterian “Destructive”",
                                  B_04_01_qr_src_chr),
  window_title = paste("Schumpeter: Destructive ·", T_07_01_author_chr),
  fillable     = FALSE,
  theme        = T_07_05_theme_fn(),
  sidebar      = E_01_02_sidebar_lst,
  T_07_08_head_fn(),
  tags$head(
    tags$style(HTML(T_05_07_preset_css_chr)),
    tags$script(HTML(T_05_05_preset_js_chr))
  ),
  navset_card_tab(
    title = textOutput("eq_title", inline = TRUE),
    nav_panel("Equations", uiOutput("eq_model")),
    nav_panel("Notation", uiOutput("eq_notation")),
    nav_panel("In Words", uiOutput("eq_explain"))
  ),
  E_02_01_presets_lst,
  uiOutput("prompt"),
  uiOutput("problems"),
  uiOutput("tiles"),
  layout_columns(
    col_widths = breakpoints(sm = 12, xl = c(6, 6)),
    T_07_07c_figcard_fn("ladder", "The Quality Ladder",
                          B_03_12_square_chr),
    conditionalPanel(
      "parseFloat(input.stage) >= 2",
      T_07_07c_figcard_fn("effects", "The Two Effects of Competition",
                          B_03_12_square_chr)
    )
  ),
  conditionalPanel(
    "parseFloat(input.stage) >= 3",
    T_07_07c_figcard_fn("inverted", "Innovation Against Competition",
                          B_03_11_tall_chr),
    uiOutput("inverted_note")
  ),
  conditionalPanel(
    "parseFloat(input.stage) >= 4",
    T_07_07c_figcard_fn("entry", "Entry and Distance to the Frontier",
                        B_03_11_tall_chr),
    uiOutput("dynamics_note")
  ),
  conditionalPanel(
    "parseFloat(input.stage) >= 5",
    layout_columns(
      col_widths = breakpoints(sm = 12, xl = c(6, 6)),
      T_07_07c_figcard_fn("policy", "Growth by Source",
                          B_03_12_square_chr),
      T_07_07c_figcard_fn("frontier", "Growth-Maximising Competition",
                          B_03_12_square_chr)
    ),
    uiOutput("policy_note")
  ),
  T_07_11_footer_fn(paste0("Notation follows the Part 3 exam questions.",
                           " Version ", B_03_14_version_chr, "."),
                    repo = B_03_15_repo_chr),
))

################################################################################
## F: Server ###################################################################
################################################################################
# Note: Assembles the stage's parameters, solves the model, draws.

#### F_01: Server Function #####################################################
# Note: Everything reactive lives here.

###### F_01_01: Server #########################################################
# Note: Local objects are plain snake_case.

F_01_01_app_server_fn <- function(input, output, session) {

  # --- Figure captions --------------------------------------------------------
  # Each caption is printed under its figure, not inside the graphics device
  T_07_07d_cap_fn(output)

  # --- Stage as a number ------------------------------------------------------
  stage_num <- reactive(as.numeric(input$stage))

  # --- Controls ---------------------------------------------------------------
  val <- function(id) T_03_04_val_fn(input, id)
  T_03_02_sync_fn(input, session, B_03_04_controls_lst)

  set_control <- function(id, value) {
    T_03_03_set_fn(session, B_03_04_controls_lst, id, value)
  }

  apply_values <- function(values) {
    for (id in names(values)) set_control(id, values[[id]])
    invisible(NULL)
  }

  # --- Which worked example is loaded -----------------------------------------
  # One reactiveVal, read by both the marked button and the card header
  scenario <- reactiveVal(names(B_03_03_scenarios_lst)[1])

  # NULL when the key is "custom" or not in the list
  scn_now <- reactive({
    k <- scenario()
    if (is.null(k) || !k %in% names(B_03_03_scenarios_lst)) NULL
    else B_03_03_scenarios_lst[[k]]
  })

  set_scenario_fn <- function(key) {
    scenario(if (is.null(key)) "custom" else key)
    session$sendCustomMessage("dgPreset", if (is.null(key)) "" else key)
    invisible(NULL)
  }

  load_preset_fn <- function(key) {
    if (is.null(key) || !key %in% names(B_03_03_scenarios_lst)) {
      return(invisible(NULL))
    }
    scn <- B_03_03_scenarios_lst[[key]]
    set_scenario_fn(key)
    apply_values(utils::modifyList(B_03_01_defaults_lst, scn$values))
    invisible(NULL)
  }

  # First preset belonging to a stage, or NULL
  first_preset_fn <- function(stage) {
    hits <- names(B_03_03_scenarios_lst)[vapply(
      B_03_03_scenarios_lst, function(x) identical(x$stage, stage), TRUE)]
    if (length(hits) == 0L) NULL else hits[[1L]]
  }

  # Every stage opens on its first example, which also resets the ghost
  observeEvent(input$stage, {
    first <- first_preset_fn(input$stage)
    if (!is.null(first)) {
      load_preset_fn(first)
      return()
    }
    set_scenario_fn(NULL)
  })

  # --- Worked-example presets -------------------------------------------------
  # One observer per preset; conditionalPanel decides which are on screen
  lapply(names(B_03_03_scenarios_lst), function(key) {
    observeEvent(input[[paste0("preset_", key)]],
                 load_preset_fn(key), ignoreInit = TRUE)
  })

  # stage_word is empty because the stage labels already begin "Stage 1: "
  output$preset_title <- renderUI({
    T_05_06_preset_title_fn(scn_now(), input$stage, B_03_02_stages_vec,
                            stage_word = "")
  })

  # --- Reset ------------------------------------------------------------------
  observeEvent(input$reset, {
    apply_values(B_03_01_defaults_lst)
    set_scenario_fn(NULL)
  })

  # --- Parameters in force at this stage --------------------------------------
  # Controls belonging to a later stage are switched off whatever their value,
  # so each stage is exactly that layer of the model. A pure function of the
  # values and the stage, so the ghost is assembled the same way.
  assemble_fn <- function(v, s) {
    list(
      gamma    = v$gamma,
      lambda_r = if (s >= 2) v$lambda_r else 1,
      profit   = if (s >= 2) v$profit else 1,
      psi      = v$psi,
      comp     = v$comp,
      rho      = v$rho,
      entry    = if (s >= 4) v$entry else 0,
      beta_e   = if (s >= 4) v$beta_e else 0,
      distance = if (s >= 5) v$distance else 0,
      imitate  = if (s >= 5) v$imitate else 0
    )
  }

  par_raw <- reactive({
    req(!is.null(input$comp))
    vals <- stats::setNames(lapply(names(B_03_01_defaults_lst), val),
                            names(B_03_01_defaults_lst))
    assemble_fn(vals, stage_num())
  })

  par_now  <- debounce(par_raw, B_03_13_debounce_ms_int)
  diag_now <- reactive(C_01_12_diagnostics_fn(par_now()))
  ok_now   <- reactive(length(diag_now()$problems) == 0)

  # --- The ghost: every figure at the reference settings ----------------------
  # The reference is the loaded worked example's values, else the defaults
  ref_vals <- reactive({
    key <- scenario()
    if (is.null(key) || !key %in% names(B_03_03_scenarios_lst)) {
      return(B_03_01_defaults_lst)
    }
    utils::modifyList(B_03_01_defaults_lst,
                      B_03_03_scenarios_lst[[key]]$values)
  })

  ref_par <- reactive(assemble_fn(ref_vals(), stage_num()))

  # NULL when the reference agrees with the sliders or would not solve
  ghost_par <- reactive({
    ref <- ref_par()
    if (T_02_03b_ghost_off_fn(par_now(), ref)) return(NULL)
    if (length(C_01_13_problems_fn(ref)) > 0) return(NULL)
    ref
  })

  # --- Scenario story ---------------------------------------------------------
  # Rendered inside the preset card, under the buttons
  output$scenario_story <- renderUI({
    T_05_02_story_fn(scn_now(), B_03_04_controls_lst, B_03_05_help_lst)
  })

  # --- The model so far -------------------------------------------------------
  output$eq_title <- renderText({
    T_05_04_stage_name_fn(B_03_02_stages_vec, input$stage)
  })

  eq_items <- reactive(T_06_03_items_fn(B_03_07_equations_lst, stage_num()))

  output$eq_model <- renderUI({
    T_06_04_model_fn(eq_items(), B_03_08_groups_vec,
                     "These appear as the later stages add to the model.")
  })

  output$eq_notation <- renderUI({
    T_06_05_notation_fn(B_03_09_notation_lst, stage_num(),
                        B_03_10_nota_cols_lst, first_stage = 1)
  })

  output$eq_explain <- renderUI({
    T_06_06_explain_fn(eq_items(), B_03_08_groups_vec)
  })

  # --- Prompt and problems ----------------------------------------------------
  output$prompt <- renderUI({
    T_07_12_prompt_fn(scn_now(), input$stage, B_03_06_prompts_lst)
  })

  output$problems <- renderUI(T_07_13_problems_fn(diag_now()$problems))

  # --- Readouts ---------------------------------------------------------------
  output$tiles <- renderUI({
    d <- diag_now()
    s <- stage_num()
    T_04_03_row_fn(
      T_04_01_tile_fn(
        "Growth rate", T_02_06_pct_fn(d$growth, 2),
        paste0(T_02_05_num_fn(d$innovation, 3),
               " innovations a year, each ",
               T_02_06_pct_fn(par_now()$gamma - 1, 0))
      ),
      T_04_01_tile_fn(
        "A lead lasts", paste0(T_02_05_num_fn(d$lifespan, 1), " years"),
        paste0("Worth ", T_02_05_num_fn(d$value, 1), ", against ",
               T_02_05_num_fn(d$value_safe, 1), " if it were safe")
      ),
      if (s >= 2) {
        T_04_01_tile_fn(
          "Who is trying harder",
          if (d$escaping) "Level firms" else "Laggards",
          paste0("Effort ", T_02_05_num_fn(d$effort_neck, 3), " against ",
                 T_02_05_num_fn(d$effort_lag, 3))
        )
      },
      if (s >= 3) {
        T_04_01_tile_fn(
          "Competition that maximises it", T_02_05_num_fn(d$peak_comp, 3),
          if (d$at_peak) "You are at the peak" else
            paste0("Growth there would be ",
                   T_02_06_pct_fn(d$peak_growth, 2)),
          class = if (d$at_peak) "good" else ""
        )
      },
      if (s >= 3) {
        T_04_01_tile_fn(
          "Sectors that are level", T_02_06_pct_fn(d$neck_share, 0),
          "The rest have a leader and a laggard"
        )
      },
      if (s >= 5) {
        T_04_01_tile_fn(
          "Best competition for this country", T_02_05_num_fn(d$best_comp, 2),
          paste0("At a distance of ",
                 T_02_06_pct_fn(par_now()$distance, 0), " from the frontier")
        )
      }
    )
  })

  # --- Figures ----------------------------------------------------------------
  # Half-width figures fold their titles at 28 characters
  output$ladder <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now())
    D_01_01_ladder_fn(par_now(), ref = ghost_par())
  }, title_width = 28) })

  output$effects <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now(), stage_num() >= 2)
    D_01_02_effects_fn(par_now(), ref = ghost_par())
  }, title_width = 28) })

  output$inverted <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now(), stage_num() >= 3)
    D_02_01_inverted_fn(par_now(), ref = ghost_par())
  }) })

  output$entry <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now(), stage_num() >= 4)
    D_02_02_entry_fn(par_now(), ref = ghost_par())
  }) })

  output$policy <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now(), stage_num() >= 5)
    D_03_01_policy_fn(par_now(), ref = ghost_par())
  }, title_width = 28) })

  output$frontier <- renderPlot({ T_02_01c_draw_fn({
    req(ok_now(), stage_num() >= 5)
    D_03_02_frontier_fn(par_now(), ref = ghost_par())
  }, title_width = 28) })

  output$inverted_note <- renderUI({
    req(stage_num() >= 3)
    d <- diag_now()
    tags$div(
      class = "narrative",
      tags$div(class = "nar-head", "Why the Inverted U Matters"),
      tags$p(HTML(paste(
        "<strong>Two schools of thought, both half right.</strong>",
        "Schumpeter argued that the prospect of a monopoly rent is what pays",
        "for innovation, so competition discourages it. The standard",
        "competition case argues the opposite: rivalry is what forces firms",
        "to improve. This model contains both arguments at once — the escape",
        "competition effect, which rises with c, and the Schumpeterian",
        "effect, which falls with it — and neither wins outright."
      ))),
      tags$p(HTML(paste0(
        "<strong>Which is why the answer is interior.</strong> Aggregate",
        " innovation is zero at both ends and positive in between, so the",
        " best level of competition is neither none nor all of it. Here it",
        " is c* = √2 − 1 ≈ ", T_02_05_num_fn(d$peak_comp, 3),
        ", and that number does not move when the cost of research, the size",
        " of a productivity step or the rent changes: it comes from the",
        " shape of the two effects and from nothing else."
      ))),
      tags$p(HTML(paste(
        "<strong>And why the empirical debate looked unresolvable.</strong>",
        "Studies fitting a straight line through competition and innovation",
        "found a positive slope in some samples and a negative one in",
        "others. On this model both were reading one side of the same hump.",
        "Fitting the curve instead — on UK firm data, with competition",
        "measured by the Lerner index — is what turned two contradictory",
        "findings into one shape."
      ))),
      tags$p(HTML(paste(
        "<strong>The policy reading.</strong> The figure is an argument",
        "against any competition policy stated as a direction. Moving",
        "towards the peak raises innovation; moving past it lowers",
        "innovation just as reliably, and from the outside the two look",
        "identical. Where a country already sits on the curve decides which",
        "way it should go, which is the question lecture 3.5 takes up."
      )))
    )
  })

  output$dynamics_note <- renderUI({
    req(stage_num() >= 4)
    d <- diag_now()
    tags$div(
      class = "narrative",
      tags$div(class = "nar-head", "Two Predictions About Firms"),
      tags$p(HTML(paste0(
        "<strong>Turnover at the top.</strong> A leader is displaced at the",
        " rate laggards innovate, so leadership of an industry lasts about ",
        T_02_05_num_fn(d$lifespan, 1),
        " years here. The model predicts continual churn among the leading",
        " firms in an industry, and more of it where the prize for catching",
        " up is larger. That is a testable claim about firm dynamics, and it",
        " is what the data on industry leadership show."
      ))),
      tags$p(HTML(paste(
        "<strong>Entry has opposite effects on different firms.</strong>",
        "An incumbent close to the frontier can hope to stay ahead of an",
        "entrant, so the threat makes it innovate harder. One far behind",
        "cannot, so the threat makes it give up: the expected rent from",
        "trying has fallen. Averaging the two together, as a study of a",
        "whole industry would, can find almost nothing — which is why the",
        "prediction has to be tested by splitting firms on distance to the",
        "frontier."
      ))),
      tags$p(HTML(paste(
        "<strong>And a warning about averages.</strong> The same logic",
        "applies to the inverted U itself: a regression of innovation on",
        "competition that imposes a straight line will find whichever effect",
        "happens to dominate in the sample, and two such studies can",
        "contradict each other while both being right."
      )))
    )
  })

  output$policy_note <- renderUI({
    req(stage_num() >= 5)
    tags$div(
      class = "narrative",
      tags$div(class = "nar-head", "Appropriate Growth Policy"),
      tags$p(HTML(paste(
        "<strong>The argument.</strong> A country far from the frontier",
        "grows mainly by adopting technologies that already exist elsewhere.",
        "That favours large established firms, long-term finance and secure",
        "rents. A country at the frontier has to invent instead, which",
        "favours competition, entry and the selection of new firms. The",
        "institutions that suit one do not suit the other."
      ))),
      tags$p(HTML(paste(
        "<strong>Why it is uncomfortable.</strong> The policies that carried",
        "a country through catch-up are precisely the ones that will hold it",
        "back once it arrives, and the constituencies those policies created",
        "will defend them. Growth slowdowns in successful catch-up economies",
        "are the standard illustration."
      ))),
      tags$p(HTML(paste(
        "<strong>And who becomes an innovator.</strong> The model treats",
        "research effort as something bought with money. The evidence on",
        "inventors suggests exposure matters as much as incentives: children",
        "of similar early ability are far more likely to patent if they grew",
        "up around innovation. If so, part of the growth policy question is",
        "about who is in the pool at all, which no amount of competition",
        "policy will reach."
      )))
    )
  })
}

################################################################################
## G: Run ######################################################################
################################################################################
# Note: Launch.

#### G_01: Launch ##############################################################
# Note: Returns the app object.

###### G_01_01: Build App ######################################################
# Note: UI from E, server from F.

G_01_01_app_lst <- shinyApp(E_02_02_app_ui_lst, F_01_01_app_server_fn)

G_01_01_app_lst
