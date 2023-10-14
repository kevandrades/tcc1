from src.data.maps import PROCEDIMENTOS_ID, EXP_COLUMNS, EXP_LABELS
from src.data.loading import read_data, c
import polars as pl
from statsmodels.formula.api import quantreg
from scipy import stats as st
import functools as fct


EXP_COLUMNS = tuple(
    column for column in EXP_COLUMNS if (
        "Decis" not in EXP_LABELS[column]
        or "Rec. Interno" not in EXP_LABELS[column]
    )
)

ft = (
    pl.read_csv(
        'data/ft_filtrado.csv',
        columns = (
            'procedimento', 'formato', 'sigla_grau', 'originario',
            *EXP_COLUMNS,
            'tramit_tmp'
        )
    )
    #.filter(
    #    ~(
    #        (c.sigla_grau == "G1") & (
    #            ((c.formato == "Eletrônico") & c.procedimento.is_in(("Execução extrajudicial não fiscal", "Execução fiscal"))) | 
    #            c.procedimento.is_in(("Conhecimento não criminal", "Outros"))
    #        )
    #    )
    #)
    .with_columns(c.procedimento.map_dict(PROCEDIMENTOS_ID))
    .fill_null(0)
)


def contingency(column1, column2, df=ft):
    return (
        df.group_by([column1, column2])
        .agg(pl.count())
        .pivot("count", column1, column2)
        .fill_null(0)
        .drop(columns=[column1, column2])
    )

def cramer_v(dataset):
    X2 = st.chi2_contingency(dataset, correction=False)[0]
    N = dataset.sum(axis=0).sum(axis=1)
    minimum_dimension = min(dataset.shape)-1
  
    return ((X2/N) / minimum_dimension)**(1/2)

fmt_grau = st.fisher_exact(contingency("formato", "sigla_grau"))

grau_orig = st.fisher_exact(contingency("originario", "sigla_grau"))

fmt_prc = st.chi2_contingency(contingency("formato", "procedimento"))

prc_grau = st.chi2_contingency(contingency("procedimento", "sigla_grau"))

prc_grau_ndrop = (
    ft.group_by(["procedimento", "sigla_grau"])
    .agg(pl.count())
    .pivot("count", "procedimento", "sigla_grau")
    .fill_null(0)
)

cramer_v(contingency("procedimento", "sigla_grau"))

ft = ft.to_dummies(columns=["sigla_grau", "formato", "procedimento"]).sample(997)
ft.write_csv("dummied.csv")
  
# Print the result

corrs = (
    pl.from_pandas(
        ft.select(EXP_COLUMNS)
        .to_pandas().corr()
        .melt(ignore_index=False)
        .reset_index()
    )
    .filter(c.index != c.variable)
    .select([
        pl.struct(
            c.index.str.replace_all("[^0-9]", "").cast(pl.Int8),
            c.variable.str.replace_all("[^0-9]", "").cast(pl.Int8)
        ).map_elements(
            lambda x: "_".join(str(x_) for x_ in sorted(x.values()))
        ).alias("idx"),
        c.value.round(2).abs().alias("corr")
    ])
    .unique(subset="idx")
    .sort("corr")
    .with_columns(c.idx.map_elements(lambda x: x.split("_")).alias("ex"))
    .explode("ex")
)

refs = corrs.filter(c.corr > .3).group_by("ex").agg(
    pl.count(),
    min = c.corr.min(),
    med = c.corr.median(),
    max = c.corr.max()
).sort("count")


quantiles = 0.1, 0.25, 0.5, 0.75, 0.90 # Pode adicionar mais quantis se necessário
quantile = .5
results = {}  # Vamos armazenar os resultados dos modelos aqui

selected_vars = []

best_aic = float('inf')

while True:
    best_var_to_add = None
    best_model = None

    # Tente adicionar uma variável
    for var in ('formato_Eletrônico', 'formato_Físico', 'sigla_grau_G1', 'sigla_grau_G2', 'procedimento_2', 'procedimento_5', 'procedimento_6', 'procedimento_7', 'ind4', 'ind5', 'ind6a', 'ind8a', 'ind9', 'ind10', 'ind11', 'ind13a', 'ind13b', 'ind24', 'ind25', 'ind26'):
        print(var)
        formula = f'tramit_tmp ~ {" + ".join(selected_vars + [var])}'
        model = quantreg(formula, data=ft).fit(q=quantile)
        aic = model.aic

        if aic < best_aic:
            best_aic = aic
            best_var_to_add = var
            best_model = model

    if best_var_to_add is not None:
        selected_vars.append(best_var_to_add)
    else:
        break


EXP = ['sigla_grau_G1', 'procedimento_2', 'procedimento_5',
       'procedimento_6', 'procedimento_7', 
       'ind5', 'ind4', 'ind6a', 'ind8a',
       'ind9', 'ind10', 'ind11', 'ind13a', 'ind13b', 'ind24', 'ind25', 'ind26',
       'formato_Eletrônico']

final_formula = f'tramit_tmp ~ {" + ".join(EXP)}'
final_model = quantreg(final_formula, data=ft).fit(q=quantile)
ctgrc = ('sigla_grau_G1', 'procedimento_2', 'procedimento_5', 'procedimento_6', 'procedimento_7')


for column in EXP_COLUMNS:
    all_cols = ctgrc + (column,)
    fml = f'tramit_tmp ~ {" + ".join(all_cols)}'
    print(column)
    quantreg(fml, ft).fit(q=quantile).summary()


print(final_model.summary())


