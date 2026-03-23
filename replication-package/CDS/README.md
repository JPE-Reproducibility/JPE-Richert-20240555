# Replication Package

## Quantity Commitments in Multiunit Auctions: Evidence from Credit Event Auctions

**Author:** Eric Richert


---

## Overview

This package contains the code and data to replicate all tables and figures in the paper. The code is written in MATLAB and executes from a single main script.

---


## Data

Confidential data used in this paper and not provided as part of the public replication package will be preserved for 5 years after publication, in accordance with journal policies.

All raw input data are CSV files stored in `confidential-data-not-for-publication/`. The code reads only from this directory. 

The main paper uses only bidding data, eligible bonds, bond characteristics and prices are used only in supplementary appendices.


### 1. Bidding Data

**Source:** Creditex Group, Markit Group (Accessed 2019) https://creditfixings.com

CDS credit event auction results are published by Creditex/Markit on the Credit Event Fixings website. Data is subject to a redistribution restriction, but can be freely downloaded from the website. One webpage exists for each auction that displays three tables. Each of these tables, corresponds to one CSV file, which collects the tables for each auction:

- **Stage 1 -- Price Quotes:** Each participating dealer submits a two-sided market (bid and offer) on the CDS contract. These quotes are used to compute the Initial Market Midpoint (IMM). The quotes are recorded in `immspreads_clean.csv`.
- **Stage 1 -- Physical Settlement Requests:** Each dealer submits a net open interest (NOI) quantity representing their net position in the underlying bonds. Positive values indicate offers to sell; negative values indicate bids to buy. These are recorded in `openinterest_clean.csv`.
- **Stage 2 -- Limit Orders:** Dealers submit limit order bids (price--quantity pairs) that, combined with the net open interest, determine the final auction price. These are recorded in `limitorders_clean.csv`.

For each auction I extracted the three tables from the auction-specific web page (following the link to the credit event) from creditfixings.com. 

The complete list of auctions with dates, final prices, and credit event types was obtained from the [auction history page](https://www.creditfixings.com/#/disclaimer-history) and is stored in `auctionlistid.csv`.

| File | Contents | Key Columns |
|------|----------|-------------|
| `immspreads_clean.csv` | Stage 1 dealer price quotes | `biddername`, `bid_imm`, `offer_imm`, `aucid` |
| `openinterest_clean.csv` | Stage 1 physical settlement requests | `biddername`, `qNOI` (millions), `aucid` |
| `limitorders_clean.csv` | Stage 2 limit order submissions | `biddername`, `price`, `quantity` (millions), `aucid`, `fromIMM`, `partially` |
| `auctionlistid.csv` | Auction list with metadata | `ticker`, `name`, `type`, `tier`, `year`, `auction_month`, `day`, `aucid`, `finalprice`, `notheld`, `Default type`, ... |

All the auction information is available at the website listed. However it may not be reproduced or redistributed in any form (see the disclaimer on the website).


### 2. Eligible Bonds

**Source:** DC Administration Services (Accessed 2019).https://www.cdsdeterminationscommittees.org/credit-default-swaps-archive/)



For each credit event, the ISDA Determinations Committee publishes a list of deliverable obligations (bonds eligible for physical settlement). These lists were extracted from the individual event pages on the DC committee archive. On each event page is a pdf called Final List that contains the eligible bond identifiers and usually some description of these bonds. The bond identifiers (CUSIPs) and any descriptions were recorded in `bondtypes.csv`.

| File | Contents | Key Columns |
|------|----------|-------------|
| `bondtypes.csv` | Individual bond identifiers and characteristics per auction | `aucid`, `comboid` (CUSIP), `name`, `ticker`, `coupon`, `maturity_date`, `denomination`, `issueamount`, ... |

### 3. Bond Characteristics

**Source:** Bloomberg L.P. (Accessed 2019). Bloomberg Terminal.

Refinitiv LPC (Accessed 2019). DealScan.

Bond-level characteristics (coupon rates, maturity dates, duration, convexity, issue amounts, floating rate indicators, etc.) were obtained by entering the CUSIP identifiers from the deliverable obligations lists into a Bloomberg terminal (Bloomberg). For loans the same procedure was followed but the loans were manually matched between information in the Final list from the determinations committee (DC Administration Services) and DealScan (Refinitiv LPC). The raw bond-level data are in `bondtypes.csv`. 

| File | Contents | Key Columns |
|------|----------|-------------|
| `bondtypes.csv` | Bond-level characteristics from Bloomberg, loans from DealScan | `coupon`, `maturity_date`, `duration`, `convexity`, `T`, `m`, `r`, `F`, `zerocoupon`, `floatingratenote`, ... |

Information obtained from the terminal is proprietary for termainal users, and cannot be republished. Access requires a subscription to a bloomberg terminal.


Information obtained from DealScan (Refinitiv) is proprietary and cannot be republished. Access requires a subscription to Refinitiv LPC. 


### 4. Bond Prices

**Source:** FINRA. (2019). TRACE (Standard Database). Wharton Research Data Service. https://wrds-www.wharton.upenn.edu/


Secondary market bond transaction prices were obtained from the FINRA TRACE database, accessed through Wharton WRDS. The bond identifiers from `bondtypes.csv` were used to query TRACE for transaction-level data (prices, quantities, and timestamps) in a window around each auction date. The raw TRACE output is stored in `gosyop23q6grk5y1.csv`. The code in `bondpriceimport.m` processes this into daily bond price summaries (mean price, standard deviation, volume) for each auction in a 61-day window (30 days before through 30 days after the auction).

| File | Contents | Key Columns |
|------|----------|-------------|
| `gosyop23q6grk5y1.csv` | Raw FINRA TRACE bond transactions | `cusip_id`, `bond_sym_id`, `company_symbol`, `date`, `tradetime`, `quantity`, `quantity_ind`, `price` |

This data is accessible to academic researchers, but cannot be reposted publicly.



---

## Software Requirements

- **MATLAB** The code was run in R2023a
- **Required Toolboxes:**
  - Statistics and Machine Learning Toolbox
  - Optimization Toolbox
  - Parallel Computing Toolbox

---

## Hardware Requirements

- The bootstrap estimation uses parallel computing (`ncores = 20` by default in `main_cds.m`). Adjust this setting to match available cores.
- Estimated runtime: approximately 20 hours on a 20-core cluster node, or 3--4 days on a desktop. The bootstrap estimation (~10 hrs), counterfactual simulations (~7 CF runs, ~45 min each), and value calculation (~3.5 hrs) are the most time-consuming stages.
- Large intermediate `.mat` files are generated (up to ~700 MB for `smc_cfs_np.mat`).

---

## Folder Structure

```
CDS/
+-- README.md                              This file
+-- code/
|   +-- main_cds.m                         Main replication script (run this)
|   +-- datacleaning/                      Data loading and preparation (11 files)
|   +-- estimation/                        Bootstrap estimation routines (10 files)
|   +-- postestimation/                    Post-estimation analysis (8 files)
|   +-- cfs/                               Counterfactual simulations (8 files)
|   +-- computation/                       Utility/helper functions (25 files)
+-- confidential-data-not-for-publication/ Raw input data (CSV files)
+-- output/                                All generated outputs
    +-- figures/                           Figures (.png)
    +-- tables/                            Tables (.tex)
    +-- logs/                              Execution logs
    +-- intermediate/                      Intermediate .mat files
```


---

## Instructions

1. Open MATLAB and set the working directory to `CDS/`.
2. Open `code/main_cds.m` and review the settings section:
   - `ncores`: Number of parallel workers (default: 20)
   - `nbs`: Number of bootstrap replications (default: 200)
   - `updatedata`: Set to 1 to rebuild data from CSVs, 0 to load cached
   - `bond_price_analysis`: Set to 0 to skip bond price import (not required for main results)
3. Run `main_cds.m`.
4. All outputs are saved to the `output/` directory.

---

## Code Pipeline

The code executes in the following order when `main_cds.m` is run. All scripts share the MATLAB workspace (they are scripts, not functions, unless noted). Path variables (`code_dir`, `root_dir`, `data_path`, `fig_path`, `tab_path`, `log_path`, `int_path`) are set once in `main_cds.m` and used throughout.

### Stage 1: Bond Price Import

**Script:** `bondpriceimport.m`

Imports secondary market bond transaction prices from FINRA TRACE (`gosyop23q6grk5y1.csv`). For each auction, identifies the deliverable bonds via CUSIP matching against `bondtypes.csv`, then computes daily volume-weighted average prices, standard deviations, and trading volumes in a 61-day window centered on the auction date (30 days before through 30 days after). These price series are used later to measure post-auction price recovery and cheapest-to-deliver risk. Saves `bondprices.mat`.

*Runtime: ~1.5 hours (serial). Can be skipped by setting `bond_price_analysis=0`.*

### Stage 2: Data Preparation

**Script:** `data_summary.m`

Loads the auction-level CSV data (dealer quotes, net open interest, limit orders, bond characteristics) and constructs the estimation sample. Calls three subscripts:
- `bondprices.m` -- Loads TRACE price series, interpolates missing days, computes post-auction abnormal returns and cheapest-to-deliver spread risk (Figure OS.3).
- `firststagebidding.m` -- Constructs auction-level variables: the Initial Market Midpoint (IMM) from dealer bid/offer quotes, aggregate net open interest (NOI), price cap/floor from ISDA rules, and the final auction clearing price. Links bidders across auction stages (`acrossrounds.m`) to extract each dealer's stage-2 limit order schedule and carried-over IMM bid. Produces Figure OS.7 (auction price vs IMM scatter).
- `outcomelinks.m` -- Merges auction outcomes with post-auction bond price changes for price discovery analysis.

Produces Tables 1, 2 (Parker Drilling example), OS.1 (eligible bonds), OS.2 (participation), OS.3 (post-auction prices), and Figures OS.4 (purchases), OS.5 (event-type prices). Saves `maindata.mat`.

*Runtime: ~30 seconds.*

### Stage 3: Price Normalization

**Script:** `normalize_prices.m`

Standardizes prices and quantities for cross-auction estimation. Prices are rescaled to so that bids from different auctions are comparable. Quantities are normalized by NOI magnitude so that a unit represents one "lot" of net open interest. Constructs bidder-auction panel variables: unique bidder-within-auction IDs (`idfs`, `idss`), supply function matrices (`supplyp`, `supplyq`), carried-over positions from stage 1, and bond characteristic controls. Calls `customerorder_frequency.m` to flag likely customer (non-dealer) orders based on excess quantity patterns. Produces Figures 1A/1B (Parker Drilling demand curves), Table 3 (auction descriptives), Table A.1 (IPV test), Tables OS.4/OS.5 (bond traits), and Section 2 in-text statistics. Saves `for211.mat`.

*Runtime: ~20 seconds.*

### Stage 4: Estimation Setup

**Script:** `npestimator.m`

Prepares inputs for the bootstrap estimator. Draws 200 bootstrap samples at the auction level. For each bidder in each bootstrap draw, constructs a simulated set of opponents by kernel-weighted resampling conditional on the auction's IMM and NOI. Saves `temp_preinv.mat`.

*Runtime: ~2 minutes.*

### Stage 5: Bootstrap Estimation

**Script:** `complex_bootstrap.m`

Core estimation step. Recovers bounds on each dealer's net position and marginal valuations from their observed bidding behavior, using the first-order conditions of the auction game.

1. **Step 1 — Position bounds** (`complex_estimator_step1`): For each bidder, simulates opponent supply curves from the kernel-weighted opponent draws, finds clearing prices at each possible quantity, and inverts the first-order condition to bound the number of committed units (`nbounds`). Run on the full sample (point estimate) and on each of 200 bootstrap resamples via `parfor` (5 batches of 40).

2. **Confidence intervals**: Constructs uniform confidence bands on `nbounds` using moment inequality procedures, with `nearestSPD` for covariance matrix repair when bootstrap variance matrices are near-singular.

3. **Step 2 — Value bounds** (`complex_estimator_step2`): Plugs the CI-corrected position bounds into the bidder's participation constraint to recover bounds on marginal valuations `v(q)` for each dealer.

4. **Variance correction** (`v_correction`): Computes bootstrap variance of value bounds by re-evaluating step 2 across all bootstrap draws (~3.3M calls of `complex_estimator_step2b`, parallelized via `parfor`). Constructs final CIs on value bounds.

5. **Diagnostics** (`complex_bootstrap_pe_outputs`): Reports point-estimate bound widths and produces Figure 4 left/middle panels (CDF bounds on net exposure and marginal values).

*Runtime: ~10 hours on 20 cores (step 1 ~6 hrs, v_correction ~3.5 hrs).*

### Stage 6: Post-Estimation

**Script:** `postestimation_clean.m`

Evaluates auction performance using the estimated value and position bounds. The key exercise is computing what prices *would* clear if dealers bid truthfully (revealing their positions), then comparing to actual auction prices:

- **Table 4**: Auction price mean, variance, and covariance with true values under the status quo vs. truthful bidding. Uses `pricechangebs` to simulate truthful-bidding clearing prices at each IMM quantile via kernel-weighted bidder resampling.
- **Section 6.1**: Surplus bounds — how much total value the auction creates vs. destroys. Calls `calculate_surplusraw` for status quo surplus from realized allocations and values.
- **Section 6.2**: Price bias — how far auction prices deviate from true values (in cents and percent).
- **Section 6.3**: Price risk and hedging effectiveness — variance of auction prices, correlation with default losses, and optimal hedge ratios.
- **Section C.7**: Bid shading statistics — how much dealers shade bids based on their committed positions.
- **Figure 4** (right panel): Unconditional CDF bounds on marginal values. Joint distribution contours. **Figure OS.8**: Clearing prices as a function of NOI.

Also computes `immquantiles = prctile(IMM, [12.5, 37.5, 62.5, 87.5])`, which defines the four market conditions for counterfactual simulations. Saves updated `smc_cfs_np.mat`.

*Runtime: ~5 minutes.*

### Stage 7: Counterfactual Simulations

**Script:** `smc_cfs_yin.m` (called 7 times)

Solves for Bayesian Nash equilibrium of a double auction where both buyers and sellers submit supply/demand schedules, replacing the one-sided CDS auction mechanism. Uses Sequential Monte Carlo (SMC) to find equilibrium bidding strategies that are consistent with the estimated value distributions:

1. `generatesimsforcf` draws simulated bidder sets from the estimated distributions, conditional on a target IMM value.
2. B=40 SMC particles (candidate equilibria) evolve through J=100 stages via `parfor`. Each particle parameterizes bidding strategies using B-spline price functions and beta quantity distributions. `doubleauctionOuter_1stepspecial_yin` evaluates each particle by simulating market clearing and measuring fit to the estimated value/position distributions.
3. The best-fitting particles are used to compute counterfactual clearing prices, surplus, and value bounds via `weightsolnpricespartialgridINTs1_yin`.

The 7 runs cover:
- **4 main runs** at `immquantiles = prctile(IMM, [12.5, 37.5, 62.5, 87.5])` — four market conditions from low to high IMM, with `sell_limit = median(Bondvol)` (median bond supply)
- **3 robustness runs**: large bond supply (sell\_limit=500), small bond supply with doubled positions (sell\_limit=100, sfrac=2), and exogenous position changes (positionschange=1)

*Runtime: ~45 minutes per run on 20 cores, ~5.5 hours total for 7 runs.*

### Stage 8: Counterfactual Aggregation

**Script:** `postmain_cfs.m`

Loads the 4 main CF result files and aggregates across IMM quantiles to produce Table 5: mean double auction clearing price, price variance, covariance with true values, and surplus bounds. Computes the same performance metrics as Table 4 (price bias, hedging effectiveness, risk) but under the counterfactual double auction mechanism, enabling direct comparison of the two formats (Section 7 in-text statistics).

Table OS.6 (robustness to bond supply assumptions) is assembled in `main_cds.m` from the two robustness CF runs with alternative sell limits.

*Runtime: ~1 minute.*

### Stage 9: Robustness Checks

**Script:** `robustnesschecks.m`

Validates model assumptions (Appendix C):
- **Figure OS.6**: Plots estimated position bounds for two individual auctions (61 and 57) to illustrate the monotonicity restriction visually.
- **Customer order robustness** (Appendix C.6): Re-estimates the model using `basic_estimator` (simpler bounds without bootstrap CIs) and `basic_estimator_copydrop` (same estimator but dropping bids flagged as likely customer orders). Compares value bounds to assess sensitivity to non-dealer participation.
- `truthfulpimmcheck` (Appendix C.5.1): Tests whether dealers have incentives to misreport IMM quotes. Simulates the expected fine from quote manipulation vs. the expected benefit from moving the IMM, finding manipulation is not profitable.
- `round1_quotescalibration` (Appendix C.5.1): Calibrates a structural model of optimal quote manipulation. Grid searches over signal noise (sigma\_eta), prior mean, and prior variance (5×5×10 = 250 parameter combinations), computing equilibrium quote deviations under each.
- `riskaversion` (Appendix C.2): Computes CARA utility ratios to assess how much risk aversion would be needed to rationalize observed bidding as optimal.

*Runtime: ~4 hours (round1\_quotescalibration grid search ~1.7 hrs, basic\_estimator ~1 hr each).*

---

## Complete File Reference

### `code/main_cds.m`

Main entry point. Sets paths, creates output directories, adds subdirectories to MATLAB path, then calls all pipeline stages in sequence. Assembles Table OS.6 from robustness CF runs.

### `code/datacleaning/` (11 files)

| File | Type | Description |
|------|------|-------------|
| `bondpriceimport.m` | Script | Imports FINRA TRACE bond transactions. Generates CUSIP permutations, matches to auction bonds, computes daily price summaries in 61-day windows. Saves `bondprices.mat`. |
| `data_summary.m` | Script | Loads all CSV data, merges and cleans. Calls `bondprices`, `firststagebidding`, `outcomelinks`. Produces Tables 1, 2, OS.1, OS.2, OS.3, Figures OS.4, OS.5. Saves `maindata.mat`. |
| `normalize_prices.m` | Script | Normalizes prices to 0--100 scale, constructs bidder IDs, normalizes quantities by NOI, builds supply function matrices. Calls `customerorder_frequency`. Produces Table 3, A.1, OS.4, OS.5, Figures 1A/1B. Saves `for211.mat`. |
| `bondprices.m` | Script | Loads `bondprices.mat`, filters auctions, calls `cleanbondprice` for interpolation, constructs post-auction price measures. Produces Figure OS.3. Called by `data_summary`. |
| `cleanbondprice.m` | Script | Interpolates missing bond prices via forward/backward fill. Normalizes standard deviations. Computes cheapest-to-deliver risk statistics. Called by `bondprices`. |
| `firststagebidding.m` | Script | Computes IMM from bid/offer quotes, NOI, price caps, auction prices. Matches bond characteristics to observations. Calls `acrossrounds`, `tiesstats`. Produces Figure OS.7. Called by `data_summary`. |
| `acrossrounds.m` | Script | Links bidders across auction stages. Extracts stage-2 bid vectors. Computes bidder-level statistics (slopes, quantities won). Calls `fixfromimm`. Saves `maindata.mat`. Called by `firststagebidding`. |
| `tiesstats.m` | Script | Computes tied-bid statistics for each auction. Called by `firststagebidding`. |
| `fixfromimm.m` | Script | Reconstructs the carried-over IMM bid indicator by matching stage-2 prices to IMM quotes. Called by `acrossrounds`. |
| `outcomelinks.m` | Script | Links auction outcomes to post-auction bond price changes. Diagnostic regressions. Called by `data_summary` (conditional on `bond_price_analysis==1`). |
| `customerorder_frequency.m` | Script | Estimates customer order probabilities from excess quantity and multi-step bidding patterns. Called by `normalize_prices`. |

### `code/estimation/` (10 files)

| File | Type | Description |
|------|------|-------------|
| `npestimator.m` | Script | Draws 200 bootstrap resamples. Constructs kernel-weighted opponent sets (`drawnids`) for each bidder. Computes bond characteristic regression and slope bounds. Saves `temp_preinv.mat`. Called by `main_cds`. |
| `complex_bootstrap.m` | Script | Main estimation orchestrator. Runs point estimate and bootstrap step1, constructs CIs, calls step2 for value bounds, calls `v_correction` for bootstrap variance, calls `complex_bootstrap_pe_outputs` for diagnostics. Called by `main_cds`. |
| `complex_estimator_step1.m` | Function | First-stage estimator. For each bidder: simulates opponent supply curves from bootstrap draws, finds clearing prices at each quantity, and inverts the first-order condition to bound net committed positions (`nbounds`). Returns position bounds and price/probability statistics (`extrainfo`). Called by `complex_bootstrap`. |
| `complex_estimator_step2.m` | Function | Second-stage estimator. Takes CI-corrected position bounds from step 1, plugs into the participation constraint to compute value bounds v(q) — the range of marginal valuations consistent with observed bidding. Returns value bounds, surplus bounds, and bid shading. Called by `complex_bootstrap`. |
| `complex_estimator_step2b.m` | Function | Single-bidder version of step 2, optimized for the `parfor` loop in `v_correction`. Called ~3.3M times across all bootstrap draws. Called by `v_correction`. |
| `v_correction.m` | Script | Bootstrap variance correction for value bounds. Section 1 (`parfor` on inequality index): re-evaluates step 2 across all bootstrap draws to get the sampling distribution of value bounds. Sections 2--3 (serial): constructs final GMS/CLR confidence intervals. Called by `complex_bootstrap`. |
| `complex_bootstrap_pe_outputs.m` | Script | Reports point-estimate diagnostics (bound widths, shading statistics). Calls `cdf_estimator_imm` for CDF bounds. Produces Figure 4 left/middle panels. Called by `complex_bootstrap`. |
| `basic_estimator.m` | Function | Simpler combined step1+step2 estimator with data-dependent (not bootstrap) bounds. Used in customer order robustness to compare against main specification. Called by `robustnesschecks`. |
| `basic_estimator_copydrop.m` | Function | Same as `basic_estimator` but drops bids flagged as suspected customer orders (via `drop` mask). Comparison with `basic_estimator` tests sensitivity to non-dealer participation. Called by `robustnesschecks`. |
| `pricechangebs.m` | Function | Simulates truthful-bidding clearing prices. Resamples bidder sets conditional on IMM via kernel weights, replaces each bidder's submitted schedule with their value function, and finds the new supply-demand intersection. Returns price bounds and surplus. Called by `postestimation_clean`. |

### `code/postestimation/` (8 files)

| File | Type | Description |
|------|------|-------------|
| `postestimation_clean.m` | Script | Evaluates auction performance (Section 6). Computes truthful-bidding clearing prices, surplus bounds, price bias, variance, and hedging effectiveness. Produces Table 4, Figure 4 (right panel, contours), Figure OS.8. Saves `immquantiles` for CF stage. Called by `main_cds`. |
| `calculate_surplusraw.m` | Script | Computes status quo surplus bounds from realized allocations and estimated value functions (Section 6.1). Called by `postestimation_clean`. |
| `pricechange_realized.m` | Function | Computes truthful-bidding clearing prices for each realized auction using the actual bidder set (not resampled). Called by `postestimation_clean`. |
| `pricechangeNOI_DIR.m` | Function | Computes clearing prices conditional on a target NOI value, used for Figure OS.8 (how prices vary with aggregate position). Called by `postestimation_clean`. |
| `robustnesschecks.m` | Script | Runs Appendix C robustness checks: truthful reporting test, quote manipulation calibration, risk aversion bounds, and customer order sensitivity. Produces Figure OS.6. Called by `main_cds`. |
| `truthfulpimmcheck.m` | Script | Tests whether dealers profit from misreporting IMM quotes (Appendix C.5.1). Simulates manipulation benefit vs. expected fine. Called by `robustnesschecks`. |
| `round1_quotescalibration.m` | Script | Calibrates structural model of optimal quote manipulation (Appendix C.5.1). Searches 5×5×10 grid of signal noise parameters. Called by `robustnesschecks`. |
| `riskaversion.m` | Script | Bounds on risk aversion needed to rationalize observed bidding (Appendix C.2). Computes CARA utility ratios. Called by `robustnesschecks`. |

### `code/cfs/` (8 files)

| File | Type | Description |
|------|------|-------------|
| `smc_cfs_yin.m` | Script | Solves for double auction equilibrium via Sequential Monte Carlo (B=40 particles, J=100 stages, `parfor`). Finds bidding strategies consistent with estimated value distributions. Saves `cf_topout_np_pt_*.mat`. Called by `main_cds` (7 times at different IMM/supply values). |
| `postmain_cfs.m` | Script | Aggregates CF results across 4 IMM quantiles. Computes double auction prices, surplus, variance, and hedging metrics. Produces Table 5 and Section 7 in-text statistics. Called by `main_cds`. |
| `generatesimsforcf.m` | Script | Draws simulated bidder sets from estimated value/position distributions, conditional on target IMM. Called by `smc_cfs_yin`. |
| `normalizeXs.m` | Function | Logistic transformation enforcing monotonicity of parameterized bid functions. Called by `smc_cfs_yin`. |
| `doubleauctionOuter_1stepspecial_yin.m` | Function | Evaluates one SMC particle: constructs bid/ask schedules from B-spline price and beta quantity parameters, finds clearing price, computes surplus, and measures fit to target distributions. Called by `smc_cfs_yin`. |
| `weightsolnpricespartialgridINTs1_yin.m` | Function | Inverts equilibrium clearing prices to recover value bounds and surplus for each bidder in the counterfactual. Called by `smc_cfs_yin`. |
| `getExpectedR.m` | Function | Computes E[R|eta] by Bayesian updating with normal signal structure. Called by `round1_quotescalibration`. |
| `getIMM.m` | Function | Simulates IMM formation from correlated dealer quote submissions. Called by `round1_quotescalibration` and `getExpectedRIMM`. |
| `getExpectedRIMM.m` | Function | Computes E[R|eta,IMM] by Bayesian updating conditional on both private signal and observed IMM. Called by `round1_quotescalibration`. |

### `code/computation/` (25 utility functions)

| File | Description |
|------|-------------|
| `nearestSPD.m` | Finds nearest symmetric positive definite matrix (Higham 1988 algorithm). Used in CI construction. |
| `cdf_estimator_imm.m` | Estimates CDF bounds for partially identified distributions (positions, values) conditional on IMM. Uses kernel weights and intersection bounds. For Figure 4. |
| `pairwise_jointd_estimator_imm.m` | Estimates bivariate CDF bounds of (position, value) conditional on IMM on a 100×100 grid. For contour plots. |
| `cdf_estimator.m` | Unconditional version of CDF estimation (superseded by `cdf_estimator_imm`). |
| `pairwise_jointd_estimator.m` | Unconditional version of joint CDF estimation (superseded by `pairwise_jointd_estimator_imm`). |
| `pmcalculation.m` | Simulates IMM formation from dealer quotes to compute the distribution of the market midpoint and the expected fine for deviating from truthful reporting. Used by `truthfulpimmcheck`. |
| `runobjconstr.m` | Wrapper for `fmincon` with nested objective/constraint functions. Used in SMC optimization. |
| `BsplineEval3.m` | Evaluates cubic B-spline basis functions. Calls `BsplineBasis3`. (Third-party: Hickman/Hubbard/Paarsch) |
| `BsplineBasis3.m` | Cox-de Boor recursion for cubic B-spline basis. (Third-party: Hickman/Hubbard/Paarsch) |
| `emcdf.m` | Empirical CDF computation. |
| `evalkspdf.m` | Kernel density function evaluation (gaussian, epanechnikov, box, triangle). |
| `evalkspdf_denom.m` | Squared kernel values for bandwidth computation. |
| `evalkspdf_num.m` | Weighted kernel values for integrated squared error in bandwidth selection. |
| `regressab.m` | Wrapper for `regress()` interleaving coefficients and standard errors. |
| `tabstat.m` | Summary statistics: [N; mean; std; p10; p50; p90]. |
| `weightedcorrs.m` | Weighted correlation matrix. |
| `weightedMedian.m` | Weighted median. (Third-party: Sven Haase) |
| `histwc.m` | Weighted histogram count. |
| `histwcv.m` | Vectorized weighted histogram. |
| `logmvnpdf.m` | Log multivariate normal PDF (numerically stable). |
| `jacobianest.m` | Numerical Jacobian via adaptive finite differences with Richardson extrapolation. |
| `permn.m` | Permutations with repetition. (Third-party: Jos van der Geest) |
| `table2latex.m` | Converts MATLAB table to LaTeX tabular environment. |
| `dscatter.m` | Density-colored scatter plot. |
| `heatscatter.m` | Heat-colored scatter plot with optional fit line. |

---

## Output-to-Paper Mapping

### Main Text -- Figures

| Paper | Description | Output File | Source Script |
|-------|-------------|-------------|--------------|
| Figure 1A | Bidder Demand (Parker Drilling) | `output/figures/bidderdemand.png` | `normalize_prices.m` |
| Figure 1B | Aggregate Demand (Parker Drilling) | `output/figures/aggdemand.png` | `normalize_prices.m` |
| Figure 3 | Bounds from Monotonicity | Theoretical illustration | -- |
| Figure 4 (left) | Distribution of Net Exposure | `output/figures/bootstrap_nmy.png` | `postestimation_clean.m` |
| Figure 4 (middle) | Distribution of Marginal Values (conditional) | `output/figures/bootstrap_v0.png` | `postestimation_clean.m` |
| Figure 4 (right) | Distribution of Marginal Values (unconditional) | `output/figures/mvcdf.png` | `postestimation_clean.m` |

### Main Text -- Tables

| Paper | Description | Output | Source Script |
|-------|-------------|--------|--------------|
| Table 1 | Initial Stage Quantities (Parker Drilling) | `output/tables/table1.tex` | `data_summary.m` |
| Table 2 | Initial Stage Price Quotes (Parker Drilling) | `output/tables/table2.tex` | `data_summary.m` |
| Table 3 | Auction Description | `output/tables/table3.tex` | `normalize_prices.m` |
| Table 4 | Statistics to Evaluate Auction Performance | `output/tables/table4.tex` | `postestimation_clean.m` |
| Table 5 | Change in Auction Format (Counterfactual) | `output/tables/table5.tex` | `postmain_cfs.m` |

### Appendix -- Tables and Figures

| Paper | Description | Output | Source Script |
|-------|-------------|--------|--------------|
| Table A.1 | Evidence of Independent Private Values | `output/tables/tableA1.tex` | `normalize_prices.m` |
| Table OS.1 | Eligible Bonds Description | `output/tables/tableOS1.tex` | `data_summary.m` |
| Table OS.2 | Auction Participation | `output/tables/tableOS2.tex` | `data_summary.m` |
| Table OS.3 | Post-Auction Prices | `output/tables/tableOS3.tex` | `data_summary.m` |
| Table OS.4 | Bond Traits: Bidder Level | `output/tables/tableOS4.tex` | `normalize_prices.m` |
| Table OS.5 | Bond Traits: Auction Level | `output/tables/tableOS5.tex` | `normalize_prices.m` |
| Table OS.6 | Change in Auction Format (Bond Supply) | `output/tables/tableOS6.tex` | `main_cds.m` (from `smc_cfs_yin` runs) |
| Figure OS.3 | Secondary Market Prices | `output/figures/abnormaleventgraph.png` | `bondprices.m` |
| Figure OS.4 | Purchases | `output/figures/totalQ.png`, `purchasedQ.png` | `data_summary.m` |
| Figure OS.5 | Event Types: Prices | `output/figures/priceevent.png` | `data_summary.m` |
| Figure OS.6 | Sample Bounds from Monotonicity | `output/figures/graphn61.png`, `graphn57.png` | `robustnesschecks.m` |
| Figure OS.7 | Auction Price vs IMM | `output/figures/auctionpriceIMM.png` | `firststagebidding.m` |
| Figure OS.8 | Clearing Prices across NOI | `output/figures/NOI_exp_price.png` | `postestimation_clean.m` |

### In-Text Statistics

All in-text numerical claims are produced with labeled `fprintf` statements in the execution log. Key sections and their source scripts:

| Paper Section | Description | Source Script |
|---------------|-------------|---------------|
| Section 2 | Sample descriptives (N auctions, N bidders, NOI, etc.) | `normalize_prices.m` |
| Section 2 | Price cap statistics | `firststagebidding.m` |
| Section 6.1 | Status quo surplus bounds | `calculate_surplusraw.m` |
| Section 6.1 | Truthful bidding surplus bounds | `postestimation_clean.m` |
| Section 6.2 | Price bias (cents, %) | `postestimation_clean.m` |
| Section 6.3 | Risk SD, hedging effectiveness | `postestimation_clean.m` |
| Section 7 | CF surplus, price bias, hedging | `postmain_cfs.m` |
| Appendix C.2 | Risk aversion comparison | `riskaversion.m` |
| Appendix C.5.1 | Truthful reporting incentives | `truthfulpimmcheck.m` |
| Appendix C.5.1 | Quote manipulation calibration | `round1_quotescalibration.m` |
| Appendix C.6 | Customer orders robustness | `robustnesschecks.m` |
| Appendix C.7 | Bid shading with positions | `postestimation_clean.m` |
| Appendix D | CF robustness (volume caps, positions) | `smc_cfs_yin.m` |

---

## Running on a Cluster (SLURM)

The `slurm/` directory contains batch scripts that split the pipeline into jobs that fit within a 12-hour wall time limit. Each job chains to the next on success.
To use these scripts, the user must change account, partition, and qos to match their own cluster.

```
cd CDS/slurm
bash submit_all.sh
```

### Job Structure

| Job | Script | Cores | Wall Time | Runtime | Description |
|-----|--------|-------|-----------|---------|-------------|
| 1 | `job1_dataprep` | 1 | 6 hrs | ~1.5 hrs | Bond price import + data cleaning |
| 2 | `job2_estimation` | 21 | 12 hrs | ~10 hrs | Bootstrap estimation (parfor step1 + v_correction) |
| 3a | `job3a_postcfs` | 21 | 6 hrs | ~2.5 hrs | Post-estimation + CF runs 1--2 |
| 3b | `job3b_postcfs` | 21 | 6 hrs | ~1.5 hrs | CF runs 3--4 + postmain_cfs (Table 5) |
| 3c | `job3c_postcfs` | 21 | 11 hrs | ~7.5 hrs | Robustness CFs (3 runs) + tableOS6 + robustnesschecks |

**Total wall time: ~23 hours** (vs ~3--4 days on a desktop with 20 cores).

Each job saves results to `output/intermediate/` and logs to `output/logs/`. If a job fails, the pipeline stops and does not submit the next job. Check the MATLAB log (`output/logs/jobN_log.txt`) for error details.


---

## Notes

- Execution logs are saved to `output/logs/` and contain all in-text numerical results with section labels (e.g., `SECTION 6.1: Surplus from Reallocation`). Search the log for the section label to find any reported statistic.
- Intermediate `.mat` files saved during execution allow restarting from any stage by setting `updatedata=0` in `main_cds.m`.
- The counterfactual simulations generate large `.mat` files in `output/intermediate/`. All saves use `-v7.3` format to support variables larger than 2 GB.
- The `computation/` directory includes third-party functions for B-spline evaluation (Hickman/Hubbard/Paarsch), permutations (Jos van der Geest), and weighted median (Sven Haase).


References

Bloomberg L.P. (Accessed 2019). Bloomberg Terminal.

Creditex Group, Markit Group (Accessed 2019) https://creditfixings.com

DC Administration Services (Accessed 2019). https://cdsdeterminationscommittees.org

Refinitiv LPC (Accessed 2019). DealScan.

FINRA. (2019). TRACE (Standard Database). Wharton Research Data Service. https://wrds-www.wharton.upenn.edu/

