################################################################################
## Project: ECON42550 Macroeconomics                                          ##
## Schumpeterian Growth: Model Functions                                      ##
################################################################################

## Author:      Sam Deegan
## Affiliation: University College Dublin
## Email:       sam.deegan@ucdconnect.ie

## Usage:
##   Sourced automatically by app.R. Can be sourced alone from a lecture
##   .qmd so slide figures come from the same model:
##     source("R/model.R")
##
## Inputs:
##   None. Every function is a pure function of a parameter list "par".
##
## Outputs:
##   C_01_* functions: effort, sector mix, innovation, growth, the peak, the
##   value of a lead, entry, policy, readouts.
##
## The model (a teaching version of the step-by-step quality ladder of
## Aghion, Bloom, Blundell, Griffith and Howitt 2005):
##   Each sector has two firms. An innovation multiplies productivity by
##   gamma > 1 and moves the innovator one step up the ladder. A sector is
##   either neck and neck, with the two firms level, or unlevelled, with a
##   leader and a laggard one step behind.
##
##   Competition c erodes the profit of firms that are level with a rival,
##   and not the profit of a firm with a technological lead:
##       pi_leader  = pi0,   pi_neck = pi0 (1 - c),   pi_laggard = 0.
##
##   A firm choosing research effort n pays psi n^2 / 2 and innovates with
##   probability lambda n, so it sets
##       n = lambda * (gain from innovating) / psi.
##   Writing k = lambda pi0 / psi,
##       neck and neck:  gain = pi_leader - pi_neck = pi0 c    =>  n_n = k c
##       laggard:        gain = pi_neck - 0 = pi0 (1 - c)      =>  n_l = k(1-c)
##
##   The first is the escape-competition effect: competition makes being
##   level unprofitable, so level firms innovate to get away from it. The
##   second is the Schumpeterian effect: competition lowers the prize a
##   laggard is chasing, so it innovates less.
##
##   In steady state the flows between the two kinds of sector balance,
##       omega_n * 2 n_n = (1 - omega_n) * n_l,
##   so omega_n = n_l / (n_l + 2 n_n), and the aggregate innovation rate is
##       I(c) = omega_n * 2 n_n + (1 - omega_n) * n_l
##            = 4 k c (1 - c) / (1 + c),
##   which is zero at both ends and peaks at c* = sqrt(2) - 1 = 0.414: the
##   inverted U.
##
##   Growth is  g = I(c) * (gamma - 1).
##
##   The value of a lead is the rent divided by the discount rate plus the
##   rate at which it is destroyed,  V = pi0 / (rho + n_l), so the expected
##   length of a period of leadership is 1 / n_l.
##
##   Two reduced forms sit on top of the model: an entry term
##   k beta e (1 - 2d) in an incumbent's effort at distance d from the
##   frontier (C_01_09), and a country growth rate that mixes inventing and
##   imitating by its distance D from the world frontier (C_01_10).
##
## Parameter list (par) elements:
##   gamma, lambda_r, profit, psi, comp, rho, entry, beta_e, distance,
##   imitate
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
# Note: C_01 holds the model; app.R holds sections B, D, E, F and G.
#
#   C: Model
#     C_01_01  Research intensity k
#     C_01_02  Effort by type of firm
#     C_01_03  The mix of sectors
#     C_01_04  The aggregate innovation rate
#     C_01_05  Growth
#     C_01_06  The inverted U across the range of competition
#     C_01_07  The peak
#     C_01_08  The value of a lead
#     C_01_09  Entry and distance to the frontier
#     C_01_10  Appropriate growth policy
#     C_01_11  Best competition across distances
#     C_01_12  Readouts
#     C_01_13  Problems with the calibration

################################################################################
## C: Model ####################################################################
################################################################################
# Note: Pure functions. Nothing here touches Shiny.

#### C_01: Model Functions #####################################################
# Note: Research effort by type of firm, the aggregate rate, growth, and what
#   it all means for firms.

###### C_01_01: Research Intensity #############################################
# Note: k scales every effort in the model: research is more intense when
#   innovating is likely to succeed, profits are large, or research is cheap.

C_01_01_scale_fn <- function(par) {
  par$lambda_r * par$profit / par$psi
}

###### C_01_02: Effort by Type of Firm #########################################
# Note: The two effects, side by side. A level firm innovates to escape
#   competition, so its effort rises with c; a laggard is chasing a prize
#   that competition has shrunk, so its effort falls with c.

C_01_02_effort_fn <- function(par, comp = NULL) {
  c_use <- if (is.null(comp)) par$comp else comp
  k     <- C_01_01_scale_fn(par)
  list(
    neck    = k * c_use,
    laggard = k * (1 - c_use),
    scale   = k
  )
}

###### C_01_03: The Mix of Sectors #############################################
# Note: In steady state, sectors leave the neck-and-neck state as fast as
#   they arrive in it. More escape-competition effort means fewer level
#   sectors.

C_01_03_mix_fn <- function(par, comp = NULL) {
  eff <- C_01_02_effort_fn(par, comp)
  den <- eff$laggard + 2 * eff$neck
  neck_share <- if (den <= 0) NA_real_ else eff$laggard / den
  list(neck = neck_share, unlevelled = 1 - neck_share)
}

###### C_01_04: The Aggregate Innovation Rate ##################################
# Note: The two effects combined. Zero at no competition, zero at total
#   competition, and a maximum in between: the inverted U.

C_01_04_innovation_fn <- function(par, comp = NULL) {
  c_use <- if (is.null(comp)) par$comp else comp
  k     <- C_01_01_scale_fn(par)
  4 * k * c_use * (1 - c_use) / (1 + c_use)
}

###### C_01_05: Growth #########################################################
# Note: Each innovation raises productivity by a factor gamma, so growth is
#   the rate of innovation times the size of a step. Output is the sum of
#   sector outputs, so a step adds gamma - 1 to aggregate productivity and
#   g = I(c) * (gamma - 1), as in Aghion, Akcigit and Howitt (2014). Aghion
#   and Howitt (1992) write I(c) * ln(gamma), which needs a log aggregator;
#   the two agree to first order in gamma - 1.

C_01_05_growth_fn <- function(par, comp = NULL) {
  C_01_04_innovation_fn(par, comp) * (par$gamma - 1)
}

###### C_01_06: The Inverted U #################################################
# Note: Innovation, growth, the sector mix and both efforts across the
#   whole range of competition, on a grid the figures share.

C_01_06_curve_fn <- function(par, n = 300) {
  grid <- seq(0.001, 0.999, length.out = n)
  data.frame(
    comp       = grid,
    innovation = vapply(grid, function(x) C_01_04_innovation_fn(par, x), 0),
    growth     = vapply(grid, function(x) C_01_05_growth_fn(par, x), 0),
    neck       = vapply(grid, function(x) C_01_03_mix_fn(par, x)$neck, 0),
    escape     = vapply(grid, function(x) C_01_02_effort_fn(par, x)$neck, 0),
    schumpeter = vapply(grid, function(x) C_01_02_effort_fn(par, x)$laggard, 0)
  )
}

###### C_01_07: The Peak #######################################################
# Note: Maximising 4kc(1-c)/(1+c) gives c^2 + 2c - 1 = 0, so the peak is at
#   sqrt(2) - 1 exactly, whatever k and gamma are (ABBGH 2005).

C_01_07_peak_fn <- function(par) {
  c_star <- sqrt(2) - 1
  list(comp = c_star,
       innovation = C_01_04_innovation_fn(par, c_star),
       growth = C_01_05_growth_fn(par, c_star))
}

###### C_01_08: The Value of a Lead ############################################
# Note: The rent, discounted, and eroded by the chance of being overtaken.
#   Creative destruction is a cost to the incumbent and the source of growth
#   for everyone else at the same time.

C_01_08_value_fn <- function(par) {
  eff     <- C_01_02_effort_fn(par)
  destroy <- eff$laggard
  list(
    rent       = par$profit,
    destroyed  = destroy,
    value      = par$profit / (par$rho + destroy),
    lifespan   = if (destroy > 0) 1 / destroy else Inf,
    no_destroy = par$profit / par$rho
  )
}

###### C_01_09: Entry and Distance to the Frontier #############################
# Note: A reduced form, not solved out of the step-by-step model: a firm
#   close to the frontier answers the threat of entry by innovating harder,
#   one far behind gives up. The sign flips at d = 1/2.

C_01_09_entry_fn <- function(par, n = 200) {
  d <- seq(0, 1, length.out = n)
  k <- C_01_01_scale_fn(par)

  base  <- k * (1 - d)
  with_entry <- k * ((1 - d) + par$entry * par$beta_e * (1 - 2 * d))

  data.frame(
    distance = d,
    base     = base,
    entry    = pmax(with_entry, 0),
    response = pmax(with_entry, 0) - base
  )
}

###### C_01_10: Appropriate Growth Policy ######################################
# Note: A country at distance D from the world frontier grows by imitating,
#   D m (1 - c), and by innovating, (1 - D) I(c), each scaled by gamma - 1.
#   Competition hinders the first and drives the second, so the
#   growth-maximising c, read off the grid, rises towards the frontier.

C_01_10_policy_fn <- function(par, n = 300) {
  grid <- seq(0.001, 0.999, length.out = n)
  d    <- par$distance

  innovate <- (1 - d) * vapply(grid, function(x) {
    C_01_04_innovation_fn(par, x)
  }, 0)
  imitate  <- d * par$imitate * (1 - grid)

  df <- data.frame(
    comp     = grid,
    innovate = innovate * (par$gamma - 1),
    imitate  = imitate * (par$gamma - 1),
    total    = (innovate + imitate) * (par$gamma - 1)
  )
  list(curve = df, best = df$comp[which.max(df$total)],
       best_growth = max(df$total))
}

###### C_01_11: Best Competition Across Distances ##############################
# Note: The policy figure: how the growth-maximising level of competition
#   changes with how far behind a country is.

C_01_11_frontier_fn <- function(par, n = 60) {
  grid <- seq(0, 0.95, length.out = n)
  best <- vapply(grid, function(d) {
    C_01_10_policy_fn(modifyList(par, list(distance = d)), 200)$best
  }, 0)
  data.frame(distance = grid, best_comp = best)
}

###### C_01_12: Readouts #######################################################
# Note: The numbers shown in the tiles above the figures.

C_01_12_diagnostics_fn <- function(par) {
  eff  <- C_01_02_effort_fn(par)
  mix  <- C_01_03_mix_fn(par)
  peak <- C_01_07_peak_fn(par)
  val  <- C_01_08_value_fn(par)
  pol  <- C_01_10_policy_fn(par, 200)

  list(
    effort_neck = eff$neck,
    effort_lag  = eff$laggard,
    escaping    = eff$neck > eff$laggard,
    neck_share  = mix$neck,
    innovation  = C_01_04_innovation_fn(par),
    growth      = C_01_05_growth_fn(par),
    peak_comp   = peak$comp,
    peak_growth = peak$growth,
    at_peak     = abs(par$comp - peak$comp) < 0.02,
    lifespan    = val$lifespan,
    value       = val$value,
    value_safe  = val$no_destroy,
    best_comp   = pol$best,
    problems    = C_01_13_problems_fn(par)
  )
}

###### C_01_13: Problems with the Calibration ##################################
# Note: Warnings shown above the figures when the numbers stop making sense.

C_01_13_problems_fn <- function(par) {
  out <- character(0)

  if (isTRUE(par$gamma <= 1)) {
    out <- c(out, paste(
      "An innovation has to raise productivity, so the step size must be",
      "above one. Otherwise there is no growth to have."
    ))
  }
  if (isTRUE(par$psi <= 0)) {
    out <- c(out, "Research must cost something, or effort is unbounded.")
  }
  if (isTRUE(par$comp <= 0.001)) {
    out <- c(out, paste(
      "With no competition at all, a firm level with its rival is already",
      "earning the full monopoly profit, so it has nothing to escape from",
      "and innovation stops."
    ))
  }
  out
}
