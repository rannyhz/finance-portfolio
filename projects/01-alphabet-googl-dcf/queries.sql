-- Alphabet (GOOGL) SQL query library
-- Source data: SEC EDGAR 10-K filings, FY2022-FY2025 ($ in millions)


-- ============================================================
-- Q1 — SCHEMA CREATION
-- ============================================================
-- Example Schema Creation
CREATE TABLE alphabet_income_statement (...);
CREATE TABLE alphabet_balance_sheet (...);
CREATE TABLE alphabet_cash_flow (...);

-- ============================================================
-- Q2 — INSERT HISTORICAL DATA
-- ============================================================
-- Insert Statements
INSERT INTO alphabet_income_statement VALUES
(2022, 282836, 162450, 29243, 26280, 1068, -126203, ...);

-- ============================================================
-- Q3 — PROFITABILITY MARGIN ANALYSIS
-- ============================================================
SELECT fiscal_year,
  ROUND(gross_profit / total_revenue, 4) AS gross_margin,
  ROUND(op_income / total_revenue, 4) AS op_margin
FROM alphabet_income_statement;

-- ============================================================
-- Q4 — GROWTH RATES & CAGR
-- ============================================================
WITH lag_data AS (
  SELECT fiscal_year, total_revenue,
  LAG(total_revenue) OVER(ORDER BY fiscal_year) as prev_rev
  FROM alphabet_income_statement
)
SELECT fiscal_year, (total_revenue - prev_rev)/prev_rev AS rev_yoy
FROM lag_data;

-- ============================================================
-- Q5 — RETURN METRICS (ROE/ROA/ROIC)
-- ============================================================
SELECT i.fiscal_year,
  i.net_income / ((b.total_equity + LAG(b.total_equity) OVER(ORDER BY b.fiscal_year))/2) AS roe
FROM alphabet_income_statement i
JOIN alphabet_balance_sheet b ON i.fiscal_year = b.fiscal_year;

-- ============================================================
-- Q6 — LIQUIDITY & LEVERAGE ANALYSIS
-- ============================================================
SELECT fiscal_year,
  total_current_assets / current_liabs AS current_ratio,
  (cash_equiv + marketable_sec) - long_term_debt AS net_cash
FROM alphabet_balance_sheet;

-- ============================================================
-- Q7 — FREE CASH FLOW & CAPITAL ALLOCATION
-- ============================================================
SELECT fiscal_year,
  cfo + capex AS free_cash_flow,
  (cfo + capex) / i.total_revenue AS fcf_margin
FROM alphabet_cash_flow c
JOIN alphabet_income_statement i ON c.fiscal_year = i.fiscal_year;

-- ============================================================
-- Q8 — SEGMENT REVENUE MIX & CONCENTRATION
-- ============================================================
SELECT fiscal_year,
  google_search / total_revenue AS search_pct,
  google_cloud / total_revenue AS cloud_pct
FROM alphabet_income_statement;

-- ============================================================
-- Q9 — DCF PROJECTION ENGINE
-- ============================================================
WITH RECURSIVE projections AS (
  SELECT 2025 AS yr, 402836 AS rev, 0 AS period
  UNION ALL
  SELECT yr+1, rev * 1.15, period+1 FROM projections WHERE period < 10
)
SELECT * FROM projections;

-- ============================================================
-- Q10 — SENSITIVITY: WACC × TERMINAL GROWTH
-- ============================================================
WITH wacc_rates AS (SELECT 0.075 AS w, 0.085, 0.095, 0.105, 0.115),
     tgr_rates AS (SELECT 0.025 AS t, 0.030, 0.035, 0.040, 0.045)
SELECT * FROM wacc_rates CROSS JOIN tgr_rates;
