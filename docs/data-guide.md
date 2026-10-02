# Data Guide
[Back to project overview](../README.md)

## Source files

| Table | Analytical role |
| --- | --- |
| [Sales.csv](../Sales.csv) | Sales records, including order dates and recorded sales and cost values |
| [Product.csv](../Product.csv) | Product lookup information |
| [Region.csv](../Region.csv) | Regional lookup information |
| [Reseller.csv](../Reseller.csv) | Reseller lookup information |
| [Salesperson.csv](../Salesperson.csv) | Salesperson lookup information |
| [SalespersonRegion.csv](../SalespersonRegion.csv) | Salesperson-to-region mapping |
| [Targets.csv](../Targets.csv) | Target information for performance comparisons |

These descriptions explain the intended role of each table; they are not a verified column-level data dictionary.

## Import considerations

- The supplied CSV exports contain tab-separated fields despite their file extensions.
- Monetary text requires parsing before aggregation.
- Order-date text must be converted into a date field.
- Check relationship keys and record granularity before joining lookup or target tables.
- Avoid joins that duplicate sales records, particularly when a mapping table contains multiple entries per salesperson.

## Coverage and provenance

The sales extract contains 57,851 rows, with dates from July 2017 through May 2020. Its fields resemble an AdventureWorks-style sample, but the original distributor has not been verified. Findings should be described as observations from the supplied sample records.

## Financial interpretation

The available Sales and Cost fields support a recorded sales-minus-cost comparison. They do not support a net-profit claim or prove a realised business outcome.

## Further documentation priorities

A future rebuild should document verified primary and foreign keys, table granularity, missing-value checks, and the source attribution. These are proposed improvements, not completed checks.
