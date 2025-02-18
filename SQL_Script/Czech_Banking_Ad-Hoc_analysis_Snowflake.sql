
/* Ad-Hoc ANALYSIS */

-- Clients Age range
SELECT MIN(AGE), MAX(AGE) FROM CLIENT;

-- Total count of MALE and FEMALE clients
SELECT 
SUM(CASE WHEN SEX = 'Male' THEN 1 END) AS TOT_MALE_CLIENTS, 
SUM(CASE WHEN SEX = 'Female' THEN 1 END) AS TOT_FEMALE_CLIETS
FROM CLIENT;

-- MALE and FEMALE client percentage
SELECT 
ROUND((SUM(CASE WHEN SEX = 'Male' THEN 1 END) / COUNT(*)) * 100, 2) AS MALE_CLIENT_PERC, 
ROUND((SUM(CASE WHEN SEX = 'Female' THEN 1 END) / COUNT(*)) * 100, 2) AS FEMALE_CLIENT_PERC
FROM CLIENT;

SELECT * FROM DISTRICT;
SELECT * FROM ACCOUNT;
SELECT * FROM CLIENT;
SELECT * FROM DISPOSITION;
SELECT * FROM CARD;
SELECT * FROM LOAN;
SELECT * FROM ORDER_LIST;
SELECT * FROM TRANSACTIONS;

CREATE OR REPLACE TABLE TRANSACTION_MASTER AS
SELECT C.CLIENT_ID, C.SEX AS GENDER, C.AGE, A.ACCOUNT_ID, A.ACCOUNT_TYPE, D.DISTRICT_CODE, D.DISTRICT_NAME, D.NO_OF_INHABITANTS AS POPULATION, D.NO_OF_CITIES, D.AVERAGE_SALARY, D.REGION, T.TRANS_ID, T.DATE AS TXN_DATE, T.TYPE, T.OPERATION, T.AMOUNT, T.BALANCE, T.PURPOSE, T.BANK, T.ACCOUNT_PARTERN_ID
FROM TRANSACTIONS AS T
INNER JOIN ACCOUNT AS A ON A.ACCOUNT_ID = T.ACCOUNT_ID
INNER JOIN DISTRICT AS D ON A.DISTRICT_ID = D.DISTRICT_CODE
INNER JOIN DISPOSITION AS DI ON DI.ACCOUNT_ID = T.ACCOUNT_ID
INNER JOIN CLIENT AS C ON DI.CLIENT_ID = C.CLIENT_ID;

SELECT * FROM TRANSACTION_MASTER;

SELECT COUNT(DISTINCT CLIENT_ID) FROM TRANSACTION_MASTER;
SELECT COUNT(DISTINCT ACCOUNT_ID) FROM TRANSACTION_MASTER;
SELECT COUNT(DISTINCT DISTRICT_CODE) FROM TRANSACTION_MASTER;

/* 1. WHAT IS THE DEMOGRAPHIC PROFILE OF THE BANK'S CLIENTS AND HOW DOES IT VARY ACROSS DISTRICTS? */

CREATE OR REPLACE TABLE DEMOGRAPHIC_DATA_KPI AS
SELECT C.DISTRICT_ID, D.DISTRICT_NAME, D.NO_OF_CITIES, D.NO_OF_INHABITANTS AS POPULATION, D.REGION, D.AVERAGE_SALARY,
AVG(C.AGE) AS AVG_AGE,
SUM(CASE WHEN SEX = 'Male' THEN 1 END) AS MALE_CLIENTS, 
SUM(CASE WHEN SEX = 'Female' THEN 1 END) AS FEMALE_CLIENTS,
COUNT(*) AS TOT_CLIENTS,
ROUND((MALE_CLIENTS / COUNT(*)) * 100, 2) AS MALE_CLIENT_PERC, 
ROUND((FEMALE_CLIENTS / COUNT(*)) * 100, 2) AS FEMALE_CLIENT_PERC, 
ROUND((MALE_CLIENTS/FEMALE_CLIENTS), 2) AS MALE_FEMALE_CLIENT_RATIO
FROM CLIENT AS C
INNER JOIN DISTRICT AS D ON C.DISTRICT_ID = D.DISTRICT_CODE
GROUP BY 1,2,3,4,5,6
ORDER BY 1;

SELECT * FROM DEMOGRAPHIC_DATA_KPI;

/* 2. HOW THE BANKS HAVE PERFORMED OVER THE YEARS. GIVE THEIR DETAILED ANALYSIS YEAR & MONTH-WISE. */

-- To get every month's latest transaction balance, assuming month-end transaction as 'Credit'. (given by client)

CREATE OR REPLACE TABLE ACC_LATEST_TXNS_WITH_BALANCE AS

WITH LATEST_TXN_INFO AS (
SELECT ACCOUNT_ID, YEAR(DATE) AS TXN_YEAR, MONTH(DATE) AS TXN_MONTH, 
MAX(DATE) AS LATEST_TXN_DATE
FROM TRANSACTIONS
GROUP BY 1,2,3
ORDER BY 1,2,3)

SELECT LTI.*, T.BALANCE
FROM TRANSACTIONS AS T
INNER JOIN LATEST_TXN_INFO AS LTI ON T.ACCOUNT_ID = LTI.ACCOUNT_ID AND T.DATE = LTI.LATEST_TXN_DATE
WHERE T.TYPE = 'Credit' -- This assumption is given by client, every month end txn data is 'credit'
ORDER BY T.ACCOUNT_ID, LTI.TXN_YEAR, LTI.TXN_MONTH;

SELECT * FROM ACC_LATEST_TXNS_WITH_BALANCE;

-- Finding key performance indicators for bank transactions.

CREATE OR REPLACE TABLE BANKING_KPI AS
SELECT ALTB.TXN_YEAR, ALTB.TXN_MONTH, T.BANK, A.ACCOUNT_TYPE,
COUNT(DISTINCT ALTB.ACCOUNT_ID) AS TOT_ACCOUNT,
COUNT(DISTINCT T.TRANS_ID) AS TOT_TXNS,
COUNT(CASE WHEN T.TYPE = 'Credit' THEN 1 END) AS DEPOSIT_COUNT,
COUNT(CASE WHEN T.TYPE = 'Withdrawal' THEN 1 END) AS WITHDRAWAL_COUNT,
SUM(ALTB.BALANCE) AS TOT_BALANCE,
ROUND((DEPOSIT_COUNT/TOT_TXNS)*100, 2) AS DEPOSIT_PERC,
ROUND((WITHDRAWAL_COUNT/TOT_TXNS)*100, 2) AS WITHDRAWAL_PERC,
NVL(TOT_BALANCE/TOT_ACCOUNT, 0) AS AVG_BALANCE, -- if the result is null, NVL will replace that null value with 0.
ROUND(TOT_TXNS/TOT_ACCOUNT, 0) AS TPA -- Transactions per account
FROM TRANSACTIONS AS T
INNER JOIN ACC_LATEST_TXNS_WITH_BALANCE AS ALTB ON T.ACCOUNT_ID = ALTB.ACCOUNT_ID
LEFT OUTER JOIN ACCOUNT AS A ON T.ACCOUNT_ID = A.ACCOUNT_ID
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4;

SELECT * FROM BANKING_KPI;

SELECT TXN_YEAR, BANK, SUM(AVG_BALANCE) AS TOT_AVG_BALANCE
FROM BANKING_KPI
GROUP BY 1,2
ORDER BY TOT_AVG_BALANCE DESC;

/* PROFITABILITY:
-- Since no revenue information is available in this dataset, the client wants to determine the profitability for each bank using the average balance they maintain in a financial year(1st April - 31st March).
-- Profitability conditions:
1. If the average balance is greater than or equal to 5M, the bank earns 5% interest on its total balance for that year.
2. If the average balance is between 3M and 5M, the bank earns 3% interest on its total balance for that year.
3. If the average balance is between 1M and 3M, the bank earns 1% interest on its total balance for that year.
4. If the average balance is less than 1M, the bank earns no interest.

-- The currency used in this dataset is CZK. We need to find the profitability in USD using the following conversion rates:
    - 1 CZK = 0.046735 USD 
    - 1 CZK = 3.836706 INR */

-- Creating a financial year-based sorting
SELECT TXN_YEAR, TXN_MONTH, 
    CASE 
        WHEN TXN_MONTH >= 4 
            THEN CONCAT(TXN_YEAR, '-', TXN_YEAR + 1) 
        ELSE CONCAT(TXN_YEAR - 1, '-', TXN_YEAR)
    END AS FINANCIAL_YEAR,
    SUM(TOT_BALANCE) AS TOT_BALANCE, SUM(AVG_BALANCE) AS TOT_AVG_BALANCE
FROM BANKING_KPI
GROUP BY 1,2,3
ORDER BY 1,2;

-- Creating a profitability table based on conditions
CREATE OR REPLACE TABLE BANK_PROFITABILITY AS 
SELECT TXN_YEAR, BANK,
    CASE 
        WHEN TXN_MONTH >= 4 
            THEN CONCAT(TXN_YEAR, '-', TXN_YEAR + 1) 
        ELSE CONCAT(TXN_YEAR - 1, '-', TXN_YEAR)
    END AS FINANCIAL_YEAR,
    SUM(AVG_BALANCE) AS TOT_AVG_BALANCE_IN_CZK,
    SUM(TOT_BALANCE) AS TOT_BALANCE_IN_CZK, 
    (TOT_AVG_BALANCE_IN_CZK * 0.046735) AS TOT_AVG_BALANCE_IN_USD,
    (TOT_BALANCE_IN_CZK * 0.046735) AS TOT_BALANCE_IN_USD,
    CASE
        WHEN TOT_AVG_BALANCE_IN_USD >= 5000000 THEN 5
        WHEN TOT_AVG_BALANCE_IN_USD >=3000000 AND TOT_AVG_BALANCE_IN_USD < 5000000 THEN 3
        WHEN TOT_AVG_BALANCE_IN_USD >=1000000 AND TOT_AVG_BALANCE_IN_USD < 3000000 THEN 1
        ELSE 0
    END AS INTEREST_RATE_IN_PERC,
    CASE
        WHEN TOT_AVG_BALANCE_IN_USD >= 5000000 THEN (TOT_BALANCE_IN_USD * 0.05)
        WHEN TOT_AVG_BALANCE_IN_USD >=3000000 AND TOT_AVG_BALANCE_IN_USD < 5000000 THEN (TOT_BALANCE_IN_USD * 0.03)
        WHEN TOT_AVG_BALANCE_IN_USD >=1000000 AND TOT_AVG_BALANCE_IN_USD < 3000000 THEN (TOT_BALANCE_IN_USD * 0.01)
        ELSE 0
    END AS PROFIT_EARNED_IN_USD
    
FROM BANKING_KPI
GROUP BY 1,2,3
ORDER BY 1,2;

SELECT * FROM BANK_PROFITABILITY;

-- Banks count based on the interest they earned
SELECT INTEREST_RATE_IN_PERC, COUNT(INTEREST_RATE_IN_PERC) AS BANK_COUNT
FROM BANK_PROFITABILITY
GROUP BY 1
ORDER BY 1 DESC;

SELECT * FROM BANK_PROFITABILITY
WHERE INTEREST_RATE_IN_PERC = 0;

-- Banks performance based on their profit
SELECT TXN_YEAR, FINANCIAL_YEAR, BANK, SUM(PROFIT_EARNED_IN_USD) AS TOT_PROFIT
FROM BANK_PROFITABILITY
GROUP BY 1,2,3
ORDER BY 4 DESC;

SELECT TXN_YEAR, BANK, SUM(PROFIT_EARNED_IN_USD) AS TOT_PROFIT
FROM BANK_PROFITABILITY
GROUP BY 1,2
ORDER BY 3 DESC;

/* 3. WHAT ARE THE MOST COMMON TYPES OF ACCOUNTS AND HOW DO THEY DIFFER IN TERMS OF USAGE AND PROFITABILITY? */

SELECT ACCOUNT_TYPE, SUM(TOT_ACCOUNT) AS TOT_ACCOUNT, SUM(TOT_TXNS) AS TOT_TXNS, 
SUM(DEPOSIT_COUNT) AS DEPOSIT_COUNT, SUM(WITHDRAWAL_COUNT) AS WITHDRAWAL_COUNT, SUM(TOT_BALANCE) AS TOT_BALANCE, 
SUM(AVG_BALANCE) AS TOT_AVG_BALANCE,
FROM BANKING_KPI
GROUP BY 1
ORDER BY TOT_TXNS DESC, TOT_BALANCE DESC;

SELECT BANK, ACCOUNT_TYPE, SUM(TOT_ACCOUNT) AS TOT_ACCOUNT, SUM(TOT_TXNS) AS TOT_TXNS, 
SUM(DEPOSIT_COUNT) AS DEPOSIT_COUNT, SUM(WITHDRAWAL_COUNT) AS WITHDRAWAL_COUNT, SUM(TOT_BALANCE) AS TOT_BALANCE, 
SUM(AVG_BALANCE) AS TOT_AVG_BALANCE,
FROM BANKING_KPI
GROUP BY 1,2
ORDER BY TOT_TXNS DESC, TOT_BALANCE DESC;

SELECT TXN_YEAR, BANK, ACCOUNT_TYPE, SUM(TOT_ACCOUNT) AS TOT_ACCOUNT, SUM(TOT_TXNS) AS TOT_TXNS, 
SUM(DEPOSIT_COUNT) AS DEPOSIT_COUNT, SUM(WITHDRAWAL_COUNT) AS WITHDRAWAL_COUNT, SUM(TOT_BALANCE) AS TOT_BALANCE, 
SUM(AVG_BALANCE) AS TOT_AVG_BALANCE,
FROM BANKING_KPI
GROUP BY 1,2,3
ORDER BY TOT_TXNS DESC, TOT_BALANCE DESC;

/* 4. WHICH TYPES OF CARDS ARE MOST FREQUENTLY USED BY THE BANK'S CLIENTS AND WHAT IS THE OVERALL PROFITABILITY OF THE CREDIT CARD BUSINESS? */

SELECT * FROM TRANSACTIONS
WHERE OPERATION = 'Credit card withdrawal';

CREATE OR REPLACE TABLE CREDIT_CARD_TXNS AS

WITH CREDIT_CARD_INFO AS (
SELECT A.ACCOUNT_ID, CI.SEX AS GENDER, CI.AGE, A.ACCOUNT_TYPE, C.CARD_ID, C.ISSUED AS CARD_ISSUED_DATE, C.TYPE AS CARD_TYPE
FROM ACCOUNT AS A 
INNER JOIN DISPOSITION AS D ON A.ACCOUNT_ID = D.ACCOUNT_ID
INNER JOIN CARD AS C ON D.DISP_ID = C.DISP_ID 
INNER JOIN CLIENT AS CI ON CI.CLIENT_ID = D.CLIENT_ID)

SELECT T.TRANS_ID, CCI.*, T.bank, YEAR(T.date) AS TXN_YEAR, MONTH(T.DATE) AS TXN_MONTH, T.date AS TXN_DATE, T.amount AS TXN_AMOUNT, T.operation
FROM TRANSACTIONS AS T 
INNER JOIN CREDIT_CARD_INFO AS CCI ON T.ACCOUNT_ID = CCI.ACCOUNT_ID
WHERE OPERATION = 'Credit card withdrawal';

SELECT * FROM CREDIT_CARD_TXNS;

SELECT CARD_TYPE, COUNT(DISTINCT TRANS_ID) AS TOT_CARD_TXNS, SUM(TXN_AMOUNT) AS TOT_TXN_AMOUNT
FROM CREDIT_CARD_TXNS
GROUP BY 1
ORDER BY TOT_CARD_TXNS DESC, TOT_TXN_AMOUNT DESC;

SELECT BANK, CARD_TYPE, COUNT(DISTINCT TRANS_ID) AS TOT_CARD_TXNS, SUM(TXN_AMOUNT) AS TOT_TXN_AMOUNT
FROM CREDIT_CARD_TXNS
GROUP BY 1,2
ORDER BY TOT_CARD_TXNS DESC, TOT_TXN_AMOUNT DESC;

SELECT TXN_YEAR, BANK, CARD_TYPE, COUNT(DISTINCT TRANS_ID) AS TOT_CARD_TXNS, SUM(TXN_AMOUNT) AS TOT_TXN_AMOUNT
FROM CREDIT_CARD_TXNS
GROUP BY 1,2,3
ORDER BY TOT_CARD_TXNS DESC, TOT_TXN_AMOUNT DESC;

/* 5. WHAT IS THE BANK’S LOAN PORTFOLIO AND HOW DOES IT VARY ACROSS DIFFERENT PURPOSES AND CLIENT SEGMENTS? */

CREATE OR REPLACE TABLE LOAN_TXNS AS

WITH LOAN_PORTFOLIO AS (
SELECT C.CLIENT_ID, C.SEX, C.AGE, D.DISTRICT_NAME, D.NO_OF_INHABITANTS AS POPULATION, D.REGION,
A.ACCOUNT_ID, A.ACCOUNT_TYPE, L.LOAN_ID, L.DATE AS LOAN_TAKEN_DATE, 
L.AMOUNT AS LOAN_AMOUNT, L.DURATION, L.PAYMENTS AS EMI, L.STATUS
FROM LOAN AS L
INNER JOIN ACCOUNT AS A ON A.ACCOUNT_ID = L.ACCOUNT_ID
INNER JOIN DISTRICT AS D ON A.DISTRICT_ID = D.DISTRICT_CODE
INNER JOIN DISPOSITION AS DIS ON A.ACCOUNT_ID = DIS.ACCOUNT_ID
INNER JOIN CLIENT AS C ON DIS.CLIENT_ID = C.CLIENT_ID
WHERE TYPE = 'OWNER')

SELECT T.TRANS_ID, YEAR(T.DATE) AS TXN_YEAR, MONTH(T.DATE) AS TXN_MONTH, T.DATE AS TXN_DATE, LP.ACCOUNT_ID, LP.ACCOUNT_TYPE, T.TYPE AS TXN_TYPE, T.OPERATION, T.AMOUNT AS TXN_AMOUNT, T.PURPOSE, T.BANK, T.ACCOUNT_PARTERN_ID, LP.LOAN_ID, LP.LOAN_TAKEN_DATE, LP.LOAN_AMOUNT, LP.DURATION, LP.EMI, LP.STATUS, LP.CLIENT_ID, LP.SEX AS GENDER, LP.AGE, LP.DISTRICT_NAME, LP.POPULATION, LP.REGION
FROM LOAN_PORTFOLIO AS LP
LEFT OUTER JOIN TRANSACTIONS AS T ON T.ACCOUNT_ID = LP.ACCOUNT_ID AND T.AMOUNT = LP.EMI;

SELECT * FROM LOAN_TXNS;

SELECT YEAR(LOAN_TAKEN_DATE) AS YEAR, GENDER, ACCOUNT_TYPE, STATUS, COUNT(DISTINCT LOAN_ID) AS TOT_LOANS, SUM(DISTINCT LOAN_AMOUNT) AS TOT_LOAN_AMOUNT
FROM LOAN_TXNS
GROUP BY 1,2,3,4
ORDER BY TOT_LOAN_AMOUNT DESC;

