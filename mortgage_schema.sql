-- ============================================================
--  PROJECT: Residential Lending Portfolio Risk & Scenario Analysis
--  Author : Samer Zeeshan  |  github.com/samer-z
--  Source : Exp25 Excel Ch06 HOE Mortgage (upgraded)
--  Tools  : MySQL 8.0 / PostgreSQL 15
-- ============================================================

CREATE TABLE borrowers (
    borrower_id     INT             PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    dob             DATE,
    credit_score    INT,
    annual_income   DECIMAL(12,2),
    employment_type VARCHAR(30),    -- Salaried, Self-Employed, Contract
    state           CHAR(2),
    dti_ratio       DECIMAL(5,3)    -- Debt-to-Income ratio
);

CREATE TABLE properties (
    property_id     INT             PRIMARY KEY AUTO_INCREMENT,
    address         VARCHAR(200),
    city            VARCHAR(60),
    state           CHAR(2),
    zip_code        VARCHAR(10),
    property_type   VARCHAR(30),    -- Single-Family, Condo, Multi-Family, Townhouse
    appraised_value DECIMAL(12,2),
    year_built      INT,
    sq_footage      INT
);

CREATE TABLE loans (
    loan_id         INT             PRIMARY KEY AUTO_INCREMENT,
    borrower_id     INT             NOT NULL,
    property_id     INT             NOT NULL,
    loan_amount     DECIMAL(12,2)   NOT NULL,
    interest_rate   DECIMAL(6,4)    NOT NULL,  -- Annual rate e.g. 0.0675 = 6.75%
    loan_term_months INT            NOT NULL,  -- 120, 180, 240, 360
    loan_type       VARCHAR(20),    -- Fixed, ARM_5_1, ARM_7_1
    origination_date DATE           NOT NULL,
    first_payment_date DATE,
    maturity_date   DATE,
    ltv_ratio       DECIMAL(5,3),   -- Loan-to-Value
    pmi_required    TINYINT(1)      DEFAULT 0,
    loan_status     VARCHAR(20)     DEFAULT 'Current', -- Current, Delinquent, Default, Paid Off
    FOREIGN KEY (borrower_id)  REFERENCES borrowers(borrower_id),
    FOREIGN KEY (property_id)  REFERENCES properties(property_id)
);

CREATE TABLE amortization_schedule (
    schedule_id     INT             PRIMARY KEY AUTO_INCREMENT,
    loan_id         INT             NOT NULL,
    payment_number  INT             NOT NULL,
    payment_date    DATE            NOT NULL,
    beginning_balance DECIMAL(12,2),
    scheduled_payment DECIMAL(10,2),
    principal_portion DECIMAL(10,2),
    interest_portion  DECIMAL(10,2),
    ending_balance    DECIMAL(12,2),
    cumulative_interest DECIMAL(12,2),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE TABLE loan_payments (
    payment_id      INT             PRIMARY KEY AUTO_INCREMENT,
    loan_id         INT             NOT NULL,
    payment_date    DATE,
    amount_paid     DECIMAL(10,2),
    principal_paid  DECIMAL(10,2),
    interest_paid   DECIMAL(10,2),
    days_late       INT             DEFAULT 0,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE INDEX idx_loans_status   ON loans(loan_status);
CREATE INDEX idx_loans_ltv      ON loans(ltv_ratio);
CREATE INDEX idx_borrower_credit ON borrowers(credit_score);
