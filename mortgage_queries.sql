-- ============================================================
--  MORTGAGE / LENDING: Analytical SQL Queries
--  Author: Samer Zeeshan  |  github.com/samer-z
-- ============================================================

-- ── Q1: Portfolio Risk Stratification by LTV Band ───────────
-- Classify the loan book by risk tier — core underwriting metric
SELECT
    CASE
        WHEN l.ltv_ratio < 0.70  THEN '< 70% (Low Risk)'
        WHEN l.ltv_ratio < 0.80  THEN '70–80% (Standard)'
        WHEN l.ltv_ratio < 0.90  THEN '80–90% (Elevated – PMI Required)'
        WHEN l.ltv_ratio < 0.95  THEN '90–95% (High Risk)'
        ELSE                          '≥ 95% (Very High Risk)'
    END                                     AS ltv_band,
    COUNT(*)                                AS loan_count,
    SUM(l.loan_amount)                      AS total_exposure,
    ROUND(AVG(l.interest_rate) * 100, 3)   AS avg_rate_pct,
    ROUND(AVG(b.credit_score), 0)           AS avg_credit_score,
    ROUND(AVG(b.dti_ratio) * 100, 2)        AS avg_dti_pct,
    SUM(CASE WHEN l.loan_status != 'Current' THEN 1 ELSE 0 END)
                                            AS non_current_loans,
    ROUND(
        SUM(CASE WHEN l.loan_status != 'Current' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                       AS delinquency_rate_pct
FROM loans l
JOIN borrowers b ON l.borrower_id = b.borrower_id
GROUP BY ltv_band
ORDER BY MIN(l.ltv_ratio);


-- ── Q2: Monthly Payment Calculator & Amortization Summary ───
-- For any loan: scheduled payment, total interest, total cost
SELECT
    l.loan_id,
    CONCAT(b.first_name, ' ', b.last_name)                 AS borrower,
    p.property_type,
    p.state,
    l.loan_amount,
    ROUND(l.interest_rate * 100, 3)                        AS rate_pct,
    l.loan_term_months,
    l.loan_type,
    -- Monthly payment = P * [r(1+r)^n] / [(1+r)^n - 1]
    ROUND(
        l.loan_amount
        * (l.interest_rate / 12)
        * POW(1 + l.interest_rate / 12, l.loan_term_months)
        / (POW(1 + l.interest_rate / 12, l.loan_term_months) - 1)
    , 2)                                                    AS monthly_payment,
    -- Total paid over life of loan
    ROUND(
        l.loan_amount
        * (l.interest_rate / 12)
        * POW(1 + l.interest_rate / 12, l.loan_term_months)
        / (POW(1 + l.interest_rate / 12, l.loan_term_months) - 1)
        * l.loan_term_months
    , 2)                                                    AS total_paid,
    -- Total interest = total paid - principal
    ROUND(
        l.loan_amount
        * (l.interest_rate / 12)
        * POW(1 + l.interest_rate / 12, l.loan_term_months)
        / (POW(1 + l.interest_rate / 12, l.loan_term_months) - 1)
        * l.loan_term_months - l.loan_amount
    , 2)                                                    AS total_interest_cost,
    ROUND(l.ltv_ratio * 100, 1)                            AS ltv_pct,
    b.credit_score
FROM loans l
JOIN borrowers b   ON l.borrower_id  = b.borrower_id
JOIN properties p  ON l.property_id  = p.property_id
ORDER BY l.loan_amount DESC;


-- ── Q3: Rate Sensitivity — Payment Impact of ±2% Rate Move ─
-- What happens to the portfolio if rates change?
SELECT
    l.loan_id,
    l.loan_amount,
    ROUND(l.interest_rate * 100, 3)                 AS current_rate_pct,
    -- Current payment
    ROUND(l.loan_amount*(l.interest_rate/12)*POW(1+l.interest_rate/12,l.loan_term_months)
        /(POW(1+l.interest_rate/12,l.loan_term_months)-1), 2) AS current_payment,
    -- Rate -1%
    ROUND(l.loan_amount*((l.interest_rate-0.01)/12)*POW(1+(l.interest_rate-0.01)/12,l.loan_term_months)
        /(POW(1+(l.interest_rate-0.01)/12,l.loan_term_months)-1), 2) AS payment_rate_minus_1pct,
    -- Rate -2%
    ROUND(l.loan_amount*((l.interest_rate-0.02)/12)*POW(1+(l.interest_rate-0.02)/12,l.loan_term_months)
        /(POW(1+(l.interest_rate-0.02)/12,l.loan_term_months)-1), 2) AS payment_rate_minus_2pct,
    -- Rate +1%
    ROUND(l.loan_amount*((l.interest_rate+0.01)/12)*POW(1+(l.interest_rate+0.01)/12,l.loan_term_months)
        /(POW(1+(l.interest_rate+0.01)/12,l.loan_term_months)-1), 2) AS payment_rate_plus_1pct,
    -- Rate +2%
    ROUND(l.loan_amount*((l.interest_rate+0.02)/12)*POW(1+(l.interest_rate+0.02)/12,l.loan_term_months)
        /(POW(1+(l.interest_rate+0.02)/12,l.loan_term_months)-1), 2) AS payment_rate_plus_2pct
FROM loans l
WHERE l.loan_type LIKE 'ARM%'   -- Rate sensitivity most relevant for ARMs
ORDER BY l.loan_amount DESC;


-- ── Q4: DTI Risk Quintile Ranking ───────────────────────────
SELECT
    b.borrower_id,
    CONCAT(b.first_name, ' ', b.last_name)          AS borrower,
    b.credit_score,
    ROUND(b.dti_ratio * 100, 1)                     AS dti_pct,
    l.loan_amount,
    ROUND(l.ltv_ratio * 100, 1)                     AS ltv_pct,
    l.loan_status,
    NTILE(5) OVER (ORDER BY b.dti_ratio DESC)        AS risk_quintile,
    CASE NTILE(5) OVER (ORDER BY b.dti_ratio DESC)
        WHEN 1 THEN 'Very High Risk'
        WHEN 2 THEN 'High Risk'
        WHEN 3 THEN 'Moderate Risk'
        WHEN 4 THEN 'Low Risk'
        ELSE        'Very Low Risk'
    END                                              AS risk_label
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
ORDER BY b.dti_ratio DESC;


-- ── Q5: Geographic Portfolio Concentration ──────────────────
SELECT
    p.state,
    COUNT(l.loan_id)                    AS loan_count,
    SUM(l.loan_amount)                  AS total_exposure,
    ROUND(AVG(l.ltv_ratio)*100, 2)      AS avg_ltv_pct,
    ROUND(AVG(b.credit_score), 0)       AS avg_credit_score,
    ROUND(AVG(b.dti_ratio)*100, 2)      AS avg_dti_pct,
    SUM(CASE WHEN l.loan_status = 'Delinquent' OR l.loan_status = 'Default'
             THEN l.loan_amount ELSE 0 END) AS at_risk_exposure,
    ROUND(
        SUM(l.loan_amount) * 100.0
        / SUM(SUM(l.loan_amount)) OVER (), 2
    )                                   AS portfolio_concentration_pct
FROM loans l
JOIN borrowers b   ON l.borrower_id = b.borrower_id
JOIN properties p  ON l.property_id = p.property_id
GROUP BY p.state
ORDER BY total_exposure DESC;


-- ── Q6: Prepayment & Payoff Analysis ────────────────────────
-- Identify loans being paid off early (>2 months ahead of schedule)
SELECT
    l.loan_id,
    CONCAT(b.first_name,' ',b.last_name)            AS borrower,
    l.loan_amount,
    l.origination_date,
    l.maturity_date,
    SUM(lp.principal_paid)                          AS total_principal_paid,
    l.loan_amount - SUM(lp.principal_paid)          AS remaining_balance,
    -- Expected balance at this point per amortization schedule
    a.ending_balance                                AS scheduled_balance,
    ROUND((a.ending_balance - (l.loan_amount - SUM(lp.principal_paid)))
        / a.ending_balance * 100, 1)               AS ahead_of_schedule_pct
FROM loans l
JOIN borrowers b ON l.borrower_id = b.borrower_id
JOIN loan_payments lp ON l.loan_id = lp.loan_id
JOIN amortization_schedule a ON l.loan_id = a.loan_id
    AND a.payment_number = (
        SELECT COUNT(*) FROM loan_payments lp2
        WHERE lp2.loan_id = l.loan_id
    )
GROUP BY l.loan_id, b.first_name, b.last_name, l.loan_amount,
         l.origination_date, l.maturity_date, a.ending_balance
HAVING ahead_of_schedule_pct > 5
ORDER BY ahead_of_schedule_pct DESC;
