"""Reproduce the January-May comparison from Sales.csv. Run in this folder."""
import pandas as pd
x = pd.read_csv("Sales.csv", sep="\t")
x["date"] = pd.to_datetime(x["OrderDate"].str.replace(r"^[^,]+, ", "", regex=True))
for col in ("Sales", "Cost"):
    x[col.lower()] = x[col].str.replace("[$,]", "", regex=True).astype(float)
period = x[x["date"].dt.year.isin((2019, 2020)) & x["date"].dt.month.le(5)]
result = period.groupby(period["date"].dt.year).agg(sales=("sales", "sum"), cost=("cost", "sum"))
result["sales_less_cost"] = result["sales"] - result["cost"]
print(result.to_string(float_format=lambda v: f"{v:,.2f}"))
print("Sales change:", f"{(result.loc[2020, 'sales']/result.loc[2019, 'sales']-1):.1%}")
print("Cost gap change:", f"{(result.loc[2020, 'sales_less_cost']/result.loc[2019, 'sales_less_cost']-1):.1%}")
