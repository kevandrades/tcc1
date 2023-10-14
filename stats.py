import polars as pl
import statsmodels.formula.api as smf
from src.data.maps import NUM_EXP_COLUMNS
from math import inf
'tramit_tmp'

df = pl.read_csv("data/infame_filter.csv")

def backward_aic_qr(df, y = "tramit_tmp", exp_columns = NUM_EXP_COLUMNS, quantile=.5):
    model = (
        smf.quantreg(
            f"{y} ~ {' + '.join(exp_columns)}",
            data=df
        )
        .fit(q=quantile)
    )

    best_aic = model.aic

    variables = set(exp_columns)

    for variable in exp_columns:
        formula = f"tramit_tmp ~ {' + '.join(variables.difference(variable))}"

        model = smf.quantreg(formula, data=df).fit(q=quantile)

        current_aic = model.aic

        if current_aic <= best_aic:
            best_aic = current_aic
            variables.remove(variable)

    return model



quantiles = .1, .25, .5, .75, .9

quantregs = {
    quantile: backward_aic_qr(
        df, quantile=quantile
    ) for quantile in quantiles
}




