# BFSI Credit Risk Analysis
### End-to-End Data Analytics Project | Excel · Power Query · Python · Power BI · MySQL

> Analyzed 51,336 loan applicants across 87 variables to identify default risk patterns for a leading Indian bank — uncovering that credit score is the strongest P1→P4 separator while missed payments alone is a weak and counter-intuitive signal.

---

## Business Problem

A leading Indian bank needs to distinguish loan applicants likely to **repay (P1/P2)** from those likely to **default (P3/P4)** — using internal tradeline behavior and external CIBIL credit profiles — to reduce NPA exposure and strengthen credit decisions.

**26% of applicants (13,334 customers) fall in the default risk category (P3+P4).** Identifying them early is critical.

---

## Dataset

**Source:** [Leading Indian Bank and CIBIL Real-World Dataset — Kaggle](https://www.kaggle.com/datasets/saurabhbadole/leading-indian-bank-and-cibil-real-world-dataset)

This is a real-world dataset representing loan applicants of a leading Indian bank. It contains two separate files — internal bank tradeline data and external CIBIL credit bureau data — joined on a unique customer identifier (PROSPECTID). The dataset covers customer demographics, credit history, delinquency behavior, enquiry patterns, and a risk classification target variable (Approved_Flag).

| Dataset | Rows | Columns | Contains |
|---------|------|---------|--------|
| Internal Bank Dataset | 51,336 | 26 | Tradeline behavior — active/closed loans, missed payments, tradeline age |
| External CIBIL Dataset | 51,336 | 62 | Credit score, delinquency history, enquiries, demographics |
| **Merged Dataset (Final)** | **51,336** | **87** | Inner join on PROSPECTID |

**Target Variable:** `Approved_Flag`

| Risk Tier | Count | Percentage | Meaning |
|-----------|-------|------------|---------|
| P1 | 5,803 | 11.3% | Lowest risk — strongest applicants |
| P2 | 32,199 | 62.7% | Moderate risk — largest segment |
| P3 | 7,452 | 14.5% | High risk |
| P4 | 5,882 | 11.5% | Highest risk — likely defaulters |

> **Note:** Dataset is imbalanced. P2 dominates at 63%. Default risk (P3+P4) = 26% of total applicants.

---

## Project Pipeline

Raw Data → Excel Cleaning → Power Query Merge → Python EDA → Power BI Dashboard → MySQL SQL Analysis

---

## Phase 1 — Data Understanding (Excel)

- Explored both datasets independently before merging
- Identified `-99999` as coded missing values across 22 CIBIL columns — 3,20,712 affected cells (~10% of dataset)
- Two missing value types identified:
  - **Type 1 — Logically missing:** Delinquency fields blank because customer never defaulted
  - **Type 2 — Genuinely missing:** Utilization and enquiry fields
- Credit Score: Min = 469, Max = 811, Avg = 679.86
- Missed Payments: Avg = 0.55, Max = 34 — large gap signals extreme outliers
- Education: 7 categories — SSC, 12TH, GRADUATE, UNDER GRADUATE, POST-GRADUATE, PROFESSIONAL, OTHERS

![Raw Internal Bank Data](Screenshots/01_raw_internal_bank_data.png.png)
![CIBIL Missing Values -99999](Screenshots/03_missing_values_99999.png.png)

---

## Phase 2 — Data Cleaning & Merging (Excel + Power Query)

- Created clean working copies — originals untouched
- Treated `-99999` in `Age_Oldest_TL` and `Age_Newest_TL` with **0** (not median — these customers genuinely have no credit history; median replacement would fabricate history)
- Enquiry columns (CC_enq, PL_enq variants) — median = 0, exactly 6,322 missing each — same customer cohort missing across all enquiry fields
- Duplicate check: **0 duplicate PROSPECTIDs** in both datasets ✓
- Merged using **Power Query Inner Join** on PROSPECTID
- Final: **51,336 rows × 87 columns**

![Missing Value Treatment Categories](Screenshots/04b_missing_value_treatment_category.png)
![Median Replacement Values](Screenshots/04c_missing_value_median_replacements.png)
![Merged Dataset 87 Columns](Screenshots/04_merged_cleaned_dataset.png.png)
![Power Query Merge Result](Screenshots/05_power_query_merge_result.png.png)
![Power Query NestedJoin on PROSPECTID](Screenshots/06_power_query_nested_join.png.png)

---

## Phase 3 — Exploratory Data Analysis (Python)

**Libraries:** Pandas, Matplotlib, Seaborn | **Environment:** Jupyter Notebook

### Visualizations
- Bar chart: Approved_Flag distribution
- Box plot: Credit Score by risk tier
- Bar chart: Average missed payments by risk tier
- Histogram: Credit Score distribution
- Stacked bar: Education vs risk tier breakdown

### Key EDA Findings

| Finding | Insight |
|---------|---------|
| P2 dominates at 63% | Dataset is heavily imbalanced |
| Credit score: 715.95 (P1) → 645.63 (P4) | Strongest single risk predictor |
| Missed payments: no clean P1→P4 pattern | Weak and counter-intuitive signal |
| Default risk across all education levels | Education is not a reliable filter |
| Credit scores concentrated at 650–700 | Majority are borderline-quality applicants |

![Approved Flag Distribution](Screenshots/07_python_approved_flag_distribution.png.png)
![Credit Score Box Plot by Risk Tier](Screenshots/08_python_credit_score_boxplot.png.png)
---

## Phase 4 — Power BI Dashboard

**5 Visuals:**
- 4 KPI Cards: Total Applicants · Default Rate · Avg Credit Score · Avg Missed Payments
- Donut Chart: Risk tier distribution
- Bar Chart: Credit score by risk tier
- Bar Chart: Missed payments by risk tier
- Stacked Bar: Education-wise risk breakdown

**Slicer:** Approved_Flag — filters all visuals dynamically

**Dashboard Narrative:** Credit score separates risk tiers cleanly. Missed payments does not. Default risk is education-agnostic — the bank cannot use education level as a screening filter.

![Power BI Dashboard Overview](Screenshots/12_powerbi_dashboard_overview.png.png)
![Power BI Dashboard Filtered to P4](Screenshots/13_powerbi_dashboard_p4_filter.png.png)

---

## Phase 5 — SQL Analysis (MySQL 8.0)

**Database:** `bfsi_credit_risk` | **Table:** `bfsi_app` | **Rows:** 51,336

| # | Business Question | SQL Concept Used |
|---|-------------------|-----------------|
| 1 | What is the P1–P4 split? | GROUP BY + Window Function |
| 2 | How does credit score vary by risk tier? | AVG, MIN, MAX + GROUP BY |
| 3 | Do missed payments separate risk tiers? | AVG + GROUP BY |
| 4 | What is the total default rate? | CASE WHEN + aggregation |
| 5 | Does education influence risk? | Window Function — PARTITION BY |
| 6 | What does a typical defaulter look like? | Multi-column AVG + WHERE filter |
| 7 | How are customers distributed by credit score band? | CASE WHEN bucketing |
| 8 | Rank customers within each risk tier | RANK() Window Function |

### SQL Key Results
- Default rate confirmed at **26.98%** — 13,334 high-risk applicants
- Credit score avg: **715.95 (P1) → 645.63 (P4)** — 70-point gap between best and worst tier
- Largest segment: **Fair credit score band (650–699)**
- Education has no consistent relationship with risk tier

![SQL Query 1 - Risk Tier Distribution](Screenshots/14_sql_query1_risk_tier_distribution.png.png)
![SQL Query 2 - Credit Score by Tier](Screenshots/15_sql_query2_credit_score_by_tier.png.png)
![SQL Query 3 - Missed Payments](Screenshots/16_sql_query3_missed_payments.png.png)
![SQL Query 4 - Default Rate](Screenshots/17_sql_query4_default_rate.png.png)
![SQL Query 5 - Education Risk Breakdown](Screenshots/18_sql_query5_education_risk_breakdown.png.png)
![SQL Query 6 - High Risk Customer Profile](Screenshots/19_sql_query6_high_risk_customer_profile.png.png)
![SQL Query 7 - Credit Score Bucketing](Screenshots/20_sql_query7_credit_score_bucketing.png.png)
![SQL Query 8 - Rank Window Function](Screenshots/21_sql_query8_rank_window_function.png.png)

---

## Key Business Insights

| # | Insight | Business Impact |
|---|---------|----------------|
| 1 | Credit score is the strongest single risk predictor | Prioritize credit score in approval models |
| 2 | 26% default risk — 13,334 applicants | Significant NPA exposure requiring immediate action |
| 3 | Missed payments alone cannot identify defaulters | Must be combined with credit score for reliable screening |
| 4 | Education does not predict default risk | Remove education as a standalone filter — it creates bias without value |
| 5 | P2 (63%) is the largest opportunity segment | Converting borderline P2 → P1 has highest portfolio value |

---

## Business Recommendations

Based on analysis of 51,336 loan applicants across 87 variables, the following actions are recommended to the credit risk team:

| # | Recommendation | Data Evidence |
|---|---------------|---------------|
| 1 | **Implement a 650 credit score floor** — applicants below 650 should require additional collateral or guarantor before approval | P4 avg credit score = 645.63; Poor band (below 650) = 2,704 customers at highest default risk |
| 2 | **Replace missed payments as standalone filter** — combine it with credit score for reliable screening | P1 customers average 0.96 missed payments — higher than P3 (0.53) and P4 (0.66); using missed payments alone rejects good customers |
| 3 | **Remove education as a credit screening criterion** — it adds no predictive value and creates regulatory bias risk | P2 dominates at 60-65% across every education category from SSC to POST-GRADUATE |
| 4 | **Launch a P2 upgrade program** — targeted engagement with borderline P2 customers to improve credit behavior | P2 = 32,199 customers (62.7%); converting even 10% to P1 behavior adds ~3,200 low-risk accounts to portfolio |
| 5 | **Build an early warning system for P3 accounts** — proactive intervention before P3 rolls to P4 | P3 = 7,452 customers (14.5%); avg credit score 667 vs P4's 645 — a 22-point gap that intervention can preserve |

### Key Risk Thresholds Identified

| Metric | Safe Zone | Warning Zone | Danger Zone |
|--------|-----------|--------------|-------------|
| Credit Score | Above 700 | 650 – 699 | Below 650 |
| Risk Tier | P1 / P2 | P3 | P4 |
| Default Exposure | 0% | 14.5% | 11.5% |

> **Bottom Line:** Credit score is the single most reliable variable for loan approval decisions. A combined scorecard using credit score as primary filter and missed payments as secondary signal will reduce NPA exposure more effectively than any education or demographic-based screening.---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| Microsoft Excel | Data understanding, cleaning |
| Power Query | Dataset merging (Inner Join on PROSPECTID) |
| Python — Pandas, Matplotlib, Seaborn | EDA, visualizations |
| Jupyter Notebook | Python environment |
| Power BI Desktop | Interactive dashboard, DAX measures |
| MySQL 8.0 + MySQL Workbench | SQL analysis — 8 business queries |

---

## Project Files

| File | Description |
|------|-------------|
| `Internal_Bank_Dataset.xlsx` | Raw internal bank tradeline data |
| `External_Cibil_Dataset.xlsx` | Raw external CIBIL credit data |
| `BFSI_Merged_Dataset.xlsx` | Cleaned and merged dataset (87 columns) |
| `BFSI_Credit_Risk_Analysis.ipynb` | Python EDA notebook (5 visualizations) |
| `BFSI_credit_risk_dashboard.pbix` | Power BI dashboard file |
| `BFSI_Credit_Risk_SQL_Analysis.sql` | MySQL queries (8 business questions) |

---

## Author

**Shivam Gupta**
B.Com (Hons) | Shaheed Bhagat Singh College, University of Delhi (2024)
NISM Research Analyst Certified

📧 shivamconnect321@gmail.com
🔗 [LinkedIn](https://www.linkedin.com/in/shivam-gupta-ab453a237/)
![Credit Score Histogram](Screenshots/09_python_credit_score_histogram.png.png)
![Missed Payments by Risk Tier](Screenshots/10_python_missed_payments.png.png)
![Education Level by Risk Category](Screenshots/11_python_education_risk_breakdown.png.png)
