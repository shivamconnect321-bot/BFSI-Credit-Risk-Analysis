-- ============================================================
-- BFSI Credit Risk Analysis — SQL Phase
-- Database  : bfsi_credit_risk
-- Table     : bfsi_app
-- Author    : Shivam
-- Tool      : MySQL 8.0
-- Rows      : 51,336
-- Target    : Approved_Flag (P1 = Lowest Risk → P4 = Highest Risk)
-- ============================================================

USE bfsi_credit_risk;

-- ============================================================
-- QUERY 1: Risk Tier Distribution
-- Business Question: What is the proportion of customers
-- in each risk category?
-- ============================================================

SELECT 
    Approved_Flag,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM bfsi_app
GROUP BY Approved_Flag
ORDER BY Approved_Flag;

-- Finding: P2 dominates at ~63%. Default risk (P3+P4) = ~27% of total applicants.


-- ============================================================
-- QUERY 2: Average Credit Score by Risk Tier
-- Business Question: Does credit score clearly separate
-- low-risk from high-risk customers?
-- ============================================================

SELECT 
    Approved_Flag,
    ROUND(AVG(Credit_Score), 2) AS avg_credit_score,
    ROUND(MIN(Credit_Score), 2) AS min_credit_score,
    ROUND(MAX(Credit_Score), 2) AS max_credit_score
FROM bfsi_app
GROUP BY Approved_Flag
ORDER BY Approved_Flag;

-- Finding: Credit score decreases cleanly P1 → P4.
-- Strong indicator of risk tier. Best single separator in dataset.


-- ============================================================
-- QUERY 3: Missed Payments Analysis by Risk Tier
-- Business Question: Do higher-risk customers miss more payments?
-- ============================================================

SELECT 
    Approved_Flag,
    ROUND(AVG(Tot_Missed_Pmnt), 2) AS avg_missed_payments,
    MAX(Tot_Missed_Pmnt) AS max_missed_payments
FROM bfsi_app
GROUP BY Approved_Flag
ORDER BY Approved_Flag;

-- Finding: Missed payments is NOT a clean risk separator.
-- Counter-intuitive signal — confirms EDA finding.


-- ============================================================
-- QUERY 4: Default Rate Calculation
-- Business Question: What percentage of applicants are
-- high-risk (P3 or P4)?
-- ============================================================

SELECT
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN Approved_Flag IN ('P3', 'P4') THEN 1 ELSE 0 END) AS default_risk_customers,
    ROUND(SUM(CASE WHEN Approved_Flag IN ('P3', 'P4') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM bfsi_app;

-- Finding: ~26% of applicants fall in default risk category.
-- Significant NPA exposure for the bank.


-- ============================================================
-- QUERY 5: Education-wise Risk Breakdown
-- Business Question: Does education level influence
-- risk tier distribution?
-- ============================================================

SELECT 
    EDUCATION,
    Approved_Flag,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY EDUCATION), 2) AS pct_within_education
FROM bfsi_app
GROUP BY EDUCATION, Approved_Flag
ORDER BY EDUCATION, Approved_Flag;

-- Finding: Default risk exists across all education levels.
-- Education alone is not a reliable risk predictor.


-- ============================================================
-- QUERY 6: High Risk Customer Profile
-- Business Question: What does a typical high-risk
-- customer look like?
-- ============================================================

SELECT
    ROUND(AVG(Credit_Score), 2) AS avg_credit_score,
    ROUND(AVG(Tot_Missed_Pmnt), 2) AS avg_missed_payments,
    ROUND(AVG(NETMONTHLYINCOME), 2) AS avg_monthly_income,
    ROUND(AVG(AGE), 2) AS avg_age,
    COUNT(*) AS total_high_risk_customers
FROM bfsi_app
WHERE Approved_Flag IN ('P3', 'P4');

-- Finding: Profile of customers most likely to default.
-- Useful for building early warning systems.


-- ============================================================
-- QUERY 7: Credit Score Bucketing
-- Business Question: How are customers distributed
-- across credit score bands?
-- ============================================================

SELECT
    CASE 
        WHEN Credit_Score >= 750 THEN 'Excellent (750+)'
        WHEN Credit_Score >= 700 THEN 'Good (700-749)'
        WHEN Credit_Score >= 650 THEN 'Fair (650-699)'
        ELSE 'Poor (Below 650)'
    END AS credit_score_band,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM bfsi_app
GROUP BY credit_score_band
ORDER BY MIN(Credit_Score) DESC;

-- Finding: Majority of customers fall in 650-700 range.
-- Confirms normal distribution observed in EDA.


-- ============================================================
-- QUERY 8: Risk Ranking by Credit Score (Window Function)
-- Business Question: Rank customers within each risk tier
-- by their credit score.
-- ============================================================

SELECT
    PROSPECTID,
    Approved_Flag,
    Credit_Score,
    RANK() OVER(PARTITION BY Approved_Flag ORDER BY Credit_Score DESC) AS rank_within_tier
FROM bfsi_app
ORDER BY Approved_Flag, rank_within_tier
LIMIT 20;

-- Finding: Demonstrates use of window functions for
-- within-group ranking — useful for priority scoring models.

-- ============================================================
-- END OF SQL ANALYSIS
-- ============================================================