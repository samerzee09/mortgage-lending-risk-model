# Residential Lending Portfolio Risk & Scenario Analysis

**Author:** Samer Zeeshan | [LinkedIn](https://linkedin.com/in/samer-zeeshan-759417212) | [GitHub](https://github.com/samerzee09)
**Tools:** SQL (MySQL 8.0) · Microsoft Excel (Advanced) · Power BI-style Dashboard
**Source Data:** DePaul University — Exp25 Excel Ch06 HOE Mortgage

---

## Project Overview

A mortgage portfolio risk model evaluating loan performance, LTV risk stratification, and interest rate scenario impacts across a $284M residential lending portfolio. Demonstrates SQL-based amortization logic, Excel financial function modeling, and a tabbed interactive dashboard for credit risk and rate sensitivity analysis.

---

## Skills Demonstrated

**SQL:** 5-table schema, CASE-based LTV risk stratification, NTILE() window function for DTI quintiles, in-SQL PMT payment calculation, DATEDIFF for loan aging, geographic concentration window functions

**Advanced Excel:** PMT / IPMT / PPMT amortization schedules, 2-variable Data Table for rate/term sensitivity, Scenario Manager (Base / Optimistic / Pessimistic), XIRR/XNPV for cash flow analysis

**Dashboard / Power BI-style:** Portfolio KPI cards, LTV distribution with delinquency dual-axis chart, monthly originations, credit score histogram, loan type donut, DTI quintile bar, rate scenario comparison, risk summary table

---

## Key SQL Queries

| Query | Technique |
|-------|-----------|
| LTV risk band stratification with delinquency rate | CASE WHEN, GROUP BY, delinquency rate calc |
| In-SQL monthly payment (PMT) + total interest | PMT formula: (rate * principal) / (1 - (1+rate)^-n) |
| Rate sensitivity: payment change at +/-1% / +/-2% | Parameterized PMT with rate offsets |
| DTI quintile segmentation | NTILE(5) OVER window function |
| Geographic portfolio concentration | SUM() OVER partition, concentration_pct window |
| Prepayment analysis by loan type | DATEDIFF, CASE, GROUP BY loan_type |

---

## Key Findings

- Loans with LTV >= 95% showed an 18.8% delinquency rate vs. only 1.2% for LTV < 70% — a 15x difference validating LTV as the strongest default predictor
- - A +2% rate increase would raise the average monthly payment by $312 (+21.4%), with disproportionate impact on borrowers in DTI quintiles 4 and 5
  - - Conventional loans represented 62% of originations but just 48% of delinquency volume, outperforming FHA and ARM products on credit quality
    - - Illinois and Indiana accounted for 74% of portfolio balance — geographic concentration risk requiring diversification
      - - Portfolio average credit score of 724 and average LTV of 78.4% indicate a moderate-risk book, with 3.8% delinquency rate
       
        - ---

        ## Files in This Repo

        | File | Description |
        |------|-------------|
        | `schema.sql` | 5-table schema: borrowers, properties, loans, amortization_schedule, loan_payments |
        | `queries.sql` | 6 analytical SQL queries with inline comments |
        | `dashboard.html` | Interactive risk dashboard — open in any browser (no server required) |

        ---

        ## How to Run

        1. Import `schema.sql` into MySQL Workbench or any MySQL 8.0+ instance
        2. 2. Load loan and borrower data matching the schema
           3. 3. Run queries from `queries.sql` — each query is independently executable
              4. 4. Open `dashboard.html` in Chrome or Edge for the full interactive dashboard
                
                 5. ---
                
                 6. ## Dashboard Preview
                
                 7. - 6 KPI cards: Portfolio Balance ($284M), Avg LTV (78.4%), Delinquency Rate (3.8%), Avg Credit Score (724), Avg Interest Rate (6.84%), Active Loans (1,847)
                    - - LTV distribution bar chart with delinquency rate overlay (dual Y-axis)
                      - - Monthly originations trend
                        - - Credit score histogram distribution
                          - - Loan type mix donut (Conventional / FHA / VA / ARM)
                            - - DTI quintile bar chart
                              - - Rate scenario model: monthly payment impact at -2%, -1%, Base, +1%, +2%
                                - - Risk summary table with LTV bands and delinquency rates
