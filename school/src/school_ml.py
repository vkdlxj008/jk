import warnings
warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd

from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier

# Load & reshape
df = pd.read_csv("school.csv")

df_long = df.melt(id_vars=["state"], var_name="metric_year", value_name="value")
df_long[["metric", "year"]] = df_long["metric_year"].str.rsplit("_", n=1, expand=True)
df_long["year"] = pd.to_numeric(df_long["year"], errors="coerce")
df_long.columns = [c.strip().lower() for c in df_long.columns]
df_long["metric"] = df_long["metric"].str.strip().str.lower()

wide = (
    df_long.pivot_table(index=["state", "year"], columns="metric", values="value", aggfunc="first")
          .reset_index()
)

if "weapon" in wide.columns and "weapon_state" not in wide.columns:
    wide = wide.rename(columns={"weapon": "weapon_state"})

features = ['alcohol','bully','cyberbully','weapon_state']
target = 'acgr'

for col in features + [target, 'year']:
    if col in wide.columns:
        wide[col] = pd.to_numeric(wide[col], errors="coerce")

wide = wide[wide['state'].str.lower() != 'united states']
wide = wide[np.isfinite(wide[target])]

THRESH = 85.0
wide['y_bin'] = (wide[target] >= THRESH).astype(int)

# data/X/y 구성
cat_cols = ['state']
num_cols = features + ['year']

data = wide[cat_cols + num_cols + ['y_bin']].dropna(subset=['year']).copy()

X = data[cat_cols + num_cols]
y = data['y_bin']
years = sorted(data['year'].dropna().unique().tolist())

#  Processing & Model
preproc_for_logit = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore'), cat_cols),
    ('num', Pipeline([
        ('imp', SimpleImputer(strategy='median')),
        ('sc', StandardScaler())
    ]), num_cols),
])

preproc_for_rf = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore'), cat_cols),
    ('num', SimpleImputer(strategy='median'), num_cols),
])

models = {
    'Logit': Pipeline([
        ('pre', preproc_for_logit),
        ('clf', LogisticRegression(
            penalty='l2', C=1.0, class_weight='balanced',
            max_iter=2000, solver='lbfgs', random_state=42
        ))
    ]),
    'RF': Pipeline([
        ('pre', preproc_for_rf),
        ('clf', RandomForestClassifier(
            n_estimators=600, max_depth=None, min_samples_leaf=5,
            random_state=42, n_jobs=-1, class_weight='balanced_subsample'
        ))
    ])
}

# Expanding split (<= t-1 → t), hardest one
def expanding_splits_strict(df):
    ys = sorted(df['year'].dropna().unique().tolist())
    for t in ys:
        prev = [yy for yy in ys if yy < t]
        if not prev:
            continue
        tr = df['year'].isin(prev)
        seen = set(df.loc[tr, 'state'])
        te = (df['year'] == t) & (df['state'].isin(seen))
        if tr.sum() == 0 or te.sum() == 0:
            continue
        if df.loc[tr, 'y_bin'].nunique() < 2:
            counts = df.loc[tr, 'y_bin'].value_counts().to_dict()
            print(f"[skip] year={t}: only one class in training {counts}")
            continue
        yield tr, te, t

def summarize_metrics(y_true, proba, pred):
    out = dict(
        acc = accuracy_score(y_true, pred),
        f1  = f1_score(y_true, pred, zero_division=0),
        prec= precision_score(y_true, pred, zero_division=0),
        rec = recall_score(y_true, pred, zero_division=0),
        auc = np.nan
    )
    try:
        out['auc'] = roc_auc_score(y_true, proba)
    except Exception:
        pass
    return out

# evaluation
import numpy as np
from sklearn.metrics import roc_curve, f1_score

def best_threshold_from_train(y_true, p_train, mode="f1"):
    if mode == "youden":
        fpr, tpr, thr = roc_curve(y_true, p_train)
        j = tpr - fpr
        return thr[np.nanargmax(j)]
    else:
        cand = np.linspace(0.1, 0.9, 81)
        scores = [f1_score(y_true, (p_train >= c).astype(int), zero_division=0) for c in cand]
        return float(cand[int(np.argmax(scores))])

results = {}
for name, pipe in models.items():
    per_year = []
    for tr, te, t in expanding_splits_strict(data):
        X_tr, y_tr = X[tr], y[tr]
        X_te, y_te = X[te], y[te]

        pipe.fit(X_tr, y_tr)

        p_tr = pipe.predict_proba(X_tr)[:, 1]
        thr = best_threshold_from_train(y_tr, p_tr, mode="f1")

        p_te = pipe.predict_proba(X_te)[:, 1]
        y_pred = (p_te >= thr).astype(int)

        met = summarize_metrics(y_te, p_te, y_pred)
        met['year'] = int(t)
        met['n_test'] = int(te.sum())
        met['thr'] = round(thr, 3)
        per_year.append(met)

    res_df = pd.DataFrame(per_year).sort_values('year')
    results[name] = res_df
    print("\n" + "="*70)
    print(f"[{name}] Expanding (<=t-1 → t)  THRESH={THRESH}")
    print("="*70)
    if not res_df.empty:
        print(res_df[['year','n_test','acc','f1','prec','rec','auc']])
        print("Avg over years:",
              res_df[['acc','f1','prec','rec','auc']].mean(numeric_only=True).to_dict())
    else:
        print("No valid folds (all skipped). Try lowering THRESH or check data coverage.")


    lg = models['Logit'].fit(X, y)
    clf = lg.named_steps['clf']
    ohe = lg.named_steps['pre'].named_transformers_['cat']
    feat_names = list(ohe.get_feature_names_out(cat_cols)) + num_cols
    coef = pd.Series(clf.coef_.ravel(), index=feat_names).sort_values(key=np.abs, ascending=False)
    print("\nTop 10 Logistic Coefficients (abs):")
    print(coef.head(10))

    rfp = models['RF'].fit(X, y)
    ohe = rfp.named_steps['pre'].named_transformers_['cat']
    feat_names = list(ohe.get_feature_names_out(cat_cols)) + num_cols
    importances = pd.Series(rfp.named_steps['clf'].feature_importances_, index=feat_names)\
                   .sort_values(ascending=False)
    print("\nTop 10 RF Feature Importances:")
    print(importances.head(10))

# Save
import os, json, pickle
from pathlib import Path
from datetime import datetime
from sklearn.utils import Bunch
import joblib


ARTIFACT_DIR = Path("artifacts")
ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)


stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
for model_name, df_metrics in results.items():
    if df_metrics is None or len(df_metrics) == 0:
        continue
    csv_path = ARTIFACT_DIR / f"{model_name}_by_year_{stamp}.csv"
    pkl_path = ARTIFACT_DIR / f"{model_name}_by_year_{stamp}.pkl"
    df_metrics.to_csv(csv_path, index=False)
    with open(pkl_path, "wb") as f:
        pickle.dump(df_metrics, f)

summary = {}
cls_ratio_all = y.value_counts(normalize=True).to_dict()
cls_ratio_by_year = (
    data.groupby('year')['y_bin']
        .value_counts(normalize=True)
        .rename('ratio').reset_index()
        .pivot(index='year', columns='y_bin', values='ratio')
        .fillna(0.0)
    )
ratio_csv = ARTIFACT_DIR / f"class_ratio_by_year_{stamp}.csv"
cls_ratio_by_year.to_csv(ratio_csv)

summary["class_ratio_all"] = cls_ratio_all
summary["class_ratio_by_year_csv"] = str(ratio_csv)


final_models = {}
for name, pipe in models.items():
    try:
        pipe.fit(X, y)
        model_path = ARTIFACT_DIR / f"model_{name}_{stamp}.joblib"
        joblib.dump(pipe, model_path)
        final_models[name] = str(model_path)
    except Exception as e:
        final_models[name] = f"ERROR: {e}"

config = dict(
    threshold=THRESH,
    features=num_cols,
    categorical=cat_cols,
    target='acgr_ge_threshold',
    split_strategy="Expanding (<=t-1 -> t)",
    created_at=stamp,
)

manifest = Bunch(
    config=config,
    artifacts=dict(
        results_csv=[str(p) for p in ARTIFACT_DIR.glob(f"*by_year_{stamp}.csv")],
        results_pkl=[str(p) for p in ARTIFACT_DIR.glob(f"*by_year_{stamp}.pkl")],
        models=final_models,
    ),
    summary=summary,
)

with open(ARTIFACT_DIR / f"manifest_{stamp}.json", "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)

print("\n=== Saved Artifacts ===")
print(json.dumps(manifest, ensure_ascii=False, indent=2))