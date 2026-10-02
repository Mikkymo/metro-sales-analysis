# Methodology and Reproduction
[Back to project overview](../README.md)

## Objective

Assess whether sales growth is accompanied by growth in sales minus recorded cost, then identify the questions needed for a product and regional investigation.

## Scope

The supplied sales extract contains 57,851 rows spanning July 2017 through May 2020. The headline comparison uses January–May 2019 and January–May 2020. Matching calendar months avoids treating the incomplete 2020 year as comparable with a complete earlier year.

## Calculation definitions

| Metric | Definition |
| --- | --- |
| Sales | Sum of the recorded Sales field for the selected period |
| Recorded cost | Sum of the recorded Cost field for the selected period |
| Sales minus recorded cost | Total sales minus total recorded cost |
| Period change | (2020 value ÷ 2019 value − 1) × 100 |

The cost gap is not net profit. The available fields do not represent all business expenses or returns.

## Reproduce the headline results

From a local checkout of this repository, install Python and pandas, then run:

```bash
python -m pip install pandas
python verify_comparison.py
```

The script reads `Sales.csv` as a tab-separated file, parses the order-date text, removes currency symbols and grouping commas from Sales and Cost, and aggregates the selected months by year.

Expected totals:

| Year | Sales | Recorded cost | Sales minus recorded cost |
| --- | ---: | ---: | ---: |
| 2019 | 10,020,031.05 | 9,620,904.20 | 399,126.85 |
| 2020 | 12,650,022.79 | 12,620,299.50 | 29,723.29 |

The script prints sales change and the cost-gap change. Recorded-cost growth can be calculated from the printed totals using the period-change formula.

## SQL and Excel assets

The [SQL script](../SQL_CAPSTONE_ONYX_COHORT.sql) and [Excel workbook](../my_sql_capstone%20_FINAL.xlsb) preserve the original exercise. Their presence does not imply that every historical query or dashboard calculation has been reconciled to the comparison above.

For further analysis, check join-key uniqueness, unmatched records, and row counts before and after joins. Reconcile totals to the source extract before interpreting segment results.

## Interpretation

The comparison establishes that recorded costs grew faster than sales within the selected period. It does not establish why. Product mix, quantity, selling price, and recorded-cost changes are candidates for investigation, rather than confirmed causes.

## Validation boundary

The verification script supports the headline period comparison. It does not independently validate every workbook metric, product or regional conclusion, or historical dashboard annotation.
