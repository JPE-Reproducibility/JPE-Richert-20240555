## Potential Personal Identifiable Information (PII)

⚠️ We found the following instances of potentially personally identifying information. This may be completely legitimate but might be worth checking. *As a reminder, privacy legislation in many countries (e.g. GDPR in EU) prohibits the dissemination of personal identifiable information without prior (and documented) consent of individuals.* If indeed you want to publish such information with your replication package, you should probably have obtained IRB approval for this - please check!

**Summary:**
- Data files with PII indicators: 5
- Variables flagged in data: 6
- Code files with PII references: 36
- PII references in code: 549

### Summary of Flagged Files

| File Type | File | Variables/References | PII Categories |
|-----------|------|----------------------|----------------|
| Data | `auctionlistid.csv` | 1 | name |
| Data | `bondtypes.csv` | 2 | name, loc |
| Data | `immspreads_clean.csv` | 1 | name |
| Data | `limitorders_clean.csv` | 1 | name |
| Data | `openinterest_clean.csv` | 1 | name |
| Code | `BsplineBasis3.m` | 24 | city, second, son, degree |
| Code | `BsplineEval3.m` | 1 | second |
| Code | `acrossrounds.m` | 1 | second |
| Code | `basic_estimator.m` | 56 | lon, lat, city |
| Code | `basic_estimator_copydrop.m` | 56 | lon, lat, city |
| Code | `bondpriceimport.m` | 13 | name, loc |
| Code | `bondprices.m` | 1 | lat |
| Code | `build_bondforestimation.m` | 2 | name |
| Code | `calculate_surplusraw.m` | 5 | lon, son |
| Code | `cdf_estimator.m` | 1 | lat |
| Code | `cdf_estimator_imm.m` | 2 | lat |
| Code | `complex_bootstrap.m` | 6 | second, lon, lat |
| Code | `complex_estimator_step1.m` | 71 | lon, lat, city |
| Code | `complex_estimator_step2.m` | 12 | lon, lat |
| Code | `complex_estimator_step2b.m` | 11 | lon, lat |
| Code | `data_summary.m` | 27 | name, block, loc, lat, second |
| Code | `doubleauctionOuter_1stepspecial_yin.m` | 3 | lat |
| Code | `emcdf.m` | 1 | lat |
| Code | `firststagebidding.m` | 10 | loc, lat |
| Code | `jacobianest.m` | 13 | loc, location, lat, second |
| Code | `main_cds.m` | 3 | lat, loc, location, name |
| Code | `normalize_prices.m` | 28 | lon, lat, second, name |
| Code | `npestimator.m` | 20 | lon |
| Code | `permn.m` | 4 | son, name, lat, second |
| Code | `postestimation_clean.m` | 16 | lat, second, son, lon, url |
| Code | `postmain_cfs.m` | 1 | lat |
| Code | `pricechangebs.m` | 1 | loc, location |
| Code | `robustnesschecks.m` | 6 | lat, lon |
| Code | `round1_quotescalibration.m` | 8 | lat, lon |
| Code | `smc_cfs_yin.m` | 30 | lat, block, loc |
| Code | `truthfulpimmcheck.m` | 3 | lat |
| Code | `v_correction.m` | 3 | lon |
| Code | `verify_env.m` | 5 | block, loc, name |
| Code | `weightedMedian.m` | 4 | lat |
| Code | `weightedcorrs.m` | 100 | lat, son, second, loc, location |
| Code | `weightsolnpricespartialgridINTs1_yin.m` | 1 | lon |

*See [Appendix](report-pii-appendix.md) for detailed listing of all flagged instances.*
