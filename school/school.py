import matplotlib
matplotlib.use("TkAgg")
import pandas as pd
import statsmodels.formula.api as smf
from statsmodels.stats.anova import anova_lm
from plotnine import (
    ggplot, aes, geom_line, geom_point, facet_wrap,
    scale_y_continuous, labs, theme, element_text)
from plotnine import ggsave

df = pd.read_csv("school.csv")

df_long = df.melt(id_vars=["state"], var_name="metric_year", value_name="value")

df_long[["metric", "year"]] = df_long["metric_year"].str.rsplit("_", n=1, expand=True)
df_long["year"] = pd.to_numeric(df_long["year"], errors="coerce")

df_long.columns = [c.strip().lower() for c in df_long.columns]
df_long["metric"] = df_long["metric"].str.strip().str.lower()

wide = (
    df_long
    .pivot_table(index=["state", "year"], columns="metric", values="value", aggfunc="first")
    .reset_index()
)

if "weapon" in wide.columns and "weapon_state" not in wide.columns:
    wide = wide.rename(columns={"weapon": "weapon_state"})

for col in ["acgr", "alcohol", "bully", "cyberbully", "weapon_state"]:
    if col in wide.columns:
        wide[col] = pd.to_numeric(wide[col], errors="coerce")

final_data = wide.dropna(subset=["acgr","alcohol","bully","cyberbully","weapon_state"]).copy()

print("final_data columns:", final_data.columns.tolist())  # 디버그
required = {"acgr","alcohol","bully","cyberbully","weapon_state"}
missing = required - set(final_data.columns)

# ANOVA(Type I) & linear
anova_model = smf.ols("acgr ~ weapon_state + bully + cyberbully + alcohol", data=final_data).fit()
print(anova_lm(anova_model, typ=1))

lm_model = smf.ols("acgr ~ weapon_state + bully + cyberbully + alcohol", data=final_data).fit()
print(lm_model.summary())

combine_rate = (
    final_data
    .melt(id_vars=['state','year'],
          value_vars=['acgr','weapon_state','bully','cyberbully','alcohol'],
          var_name='clue', value_name='number')
    .sort_values(['state','clue','year'])
    .assign(
        number=lambda df: df.groupby(['state','clue'])['number']
                           .apply(lambda s: s.interpolate('linear', limit_direction='both'))
                           .reset_index(level=[0,1], drop=True)
    )
)

# making facet plot
p = (
    ggplot(combine_rate, aes(x='year', y='number', color='clue', group='clue'))
    + geom_line()
    + geom_point()
    + scale_y_continuous(limits=(0, 100))
    + facet_wrap('~state', ncol=6)
    + labs(
        title='Factors Influencing Graduation Rates by Year and State',
        x='Year', y='Graduation Rate'
    )
    + theme(
        figure_size=(16, 9),
        axis_text_x=element_text(rotation=0, size=8),
        axis_text_y=element_text(size=8),
        legend_title=element_text(size=9),
        legend_text=element_text(size=8),
        plot_title=element_text(size=12, weight='bold')
    )
)

fig = p.draw()

import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

root = tk.Tk()
root.wm_title("Facet Plot (plotnine)")

canvas = FigureCanvasTkAgg(fig, master=root)
canvas.draw()
canvas.get_tk_widget().pack(fill="both", expand=1)

root.geometry("1280x720")

root.mainloop()
ggsave(p, "facet_plot.png", dpi=300)