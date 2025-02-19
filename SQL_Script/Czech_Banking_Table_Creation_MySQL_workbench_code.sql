CREATE DATABASE CZECH_BANK;
USE CZECH_BANK;

/* TABLE CREATION */

CREATE TABLE DISTRICT (
    District_Code INT PRIMARY KEY,
    District_Name VARCHAR(100),
    Region VARCHAR(100),
    No_of_Inhabitants INT,
    No_of_Municipalities_with_Inhabitants_less_499 INT,
    No_of_Municipalities_with_Inhabitants_btw_500_to_1999 INT,
    No_of_Municipalities_with_Inhabitants_btw_2000_to_9999 INT,
    No_of_Municipalities_with_Inhabitants_greater_10000 INT,
    No_of_Cities INT,
    Ratio_of_Urban_Inhabitants FLOAT,
    Average_Salary INT,
    No_of_Entrepreneurs_per_1000_Inhabitants INT,
    No_of_Committed_Crime_2017 INT,
    No_of_Committed_Crime_2018 INT
);

CREATE TABLE ACCOUNT (
    Account_id INT PRIMARY KEY,
    District_id INT,
    Frequency VARCHAR(40),
    Date DATE,
    Account_type VARCHAR(40),
    Card_Assigned VARCHAR(20),
    FOREIGN KEY (District_id) REFERENCES DISTRICT(District_Code)
);

CREATE TABLE CLIENT (
    Client_id INT PRIMARY KEY,
    Sex VARCHAR(10),
    Birth_Date DATE,
    District_id INT,
    FOREIGN KEY (District_id) REFERENCES DISTRICT(District_Code)
);

CREATE TABLE DISPOSITION (
    Disp_id INT PRIMARY KEY,
    Client_id INT,
    Account_id INT,
    Type VARCHAR(10),
    FOREIGN KEY (Client_id) REFERENCES CLIENT(Client_id),
    FOREIGN KEY (Account_id) REFERENCES ACCOUNT(Account_id)
);

CREATE TABLE CARD (
    Card_id INT PRIMARY KEY,
    Disp_id INT,
    Type VARCHAR(20),
    Issued DATE,
    FOREIGN KEY (Disp_id) REFERENCES DISPOSITION(Disp_id)
);

CREATE TABLE LOAN (
    Loan_id INT PRIMARY KEY,
    Account_id INT,
    Date DATE,
    Amount INT,
    Duration INT,
    Payments INT,
    Status VARCHAR(40),
    FOREIGN KEY (Account_id) REFERENCES ACCOUNT(Account_id)
);

CREATE TABLE ORDER_LIST (
    Order_id INT PRIMARY KEY,
    Account_id INT,
    Bank_to VARCHAR(100),
    Account_to INT,
    Amount FLOAT,
    FOREIGN KEY (Account_id) REFERENCES ACCOUNT(Account_id)
);

CREATE TABLE TRANSACTIONS (
    Trans_id INT PRIMARY KEY,
    Account_id INT,
    Date DATE,
    Type VARCHAR(30),
    Operation VARCHAR(50),
    Amount INT,
    Balance FLOAT,
    Purpose VARCHAR(50),
    Bank VARCHAR(50),
    Account_Partern_id INT,
    FOREIGN KEY (Account_id) REFERENCES ACCOUNT(Account_id)
);











