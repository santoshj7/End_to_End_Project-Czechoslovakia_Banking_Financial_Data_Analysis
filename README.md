
# End-to-End Project - Czechoslovakia Banking Financial Data Analysis

This comprehensive financial data analysis project covers end-to-end processes, including data cleaning, cloud platform integration and automation, data transformation, data analysis, and data visualization using a variety of analytical tools. The dataset has over a million records spread across 8 different tables, providing a robust foundation for insightful analysis and decision-making.


## Introduction:

The Czechoslovakia Bank has provided a dataset containing information about its financial activities for the past 6 years. The dataset consists of the following tables:

- **Account**: This table contains information about the accounts held by the bank's clients. It includes the account ID, the date the account was opened, the associated client ID, and the account type.

- **Card**: This table contains information about the card issued by the bank. It includes the card ID, the date the card was issued, and the card type.

- **Client**: This table contains information about the bank's clients. It includes the client ID, the client's birthdate, gender, and the district where the client lives.

- **Disposition**: This table contains information about the relationship between clients and their accounts. It includes the disposition ID, the client ID associated with the disposition, and the type of disposition (e.g., owner,authorized person, etc.).

- **District**: This table contains information about the various districts in Czechoslovakia. It includes the district ID, the name of the district, and various demographic and economic indicators for the district.

- **Loan**: This table contains information about the loans issued by the bank. It includes the loan ID, the date the loan was issued, the account ID associated with the loan, the amount of the loan.

- **Order**: This table contains information about the orders issued by the bank's clients. It includes the order ID, the account ID associated with the order, the date the order was issued, and a description of the order.

- **Transaction**: This table contains information about the transactions made by the bank's clients. It includes the transaction ID, the account ID associated with the transaction, the transaction date, the type of transaction, and the transaction amount.

## Ad-hoc Data Analysis:

The Czechoslovakia Bank wants to analyse its financial data to gain insights and make informed decisions. The bank needs to identify trends, patterns, and potential risks in its financial operations. They also want to explore the possibility of introducing new financial products or services based on their analysis.

The bank has identified the following questions as important for their analysis:
- What is the demographic profile of the bank's clients and how does it vary across districts?
- How the banks have performed over the years. Give their detailed analysis year & month-wise.
- What are the most common types of accounts and how do they differ in terms of usage and profitability?
- Which types of cards are most frequently used by the bank's clients and what is the overall profitability of the credit card business?
- What are the major expenses of the bank and how can they be reduced to improve profitability?
- What is the bank’s loan portfolio and how does it vary across different purposes and client segments?
- How can the bank improve its customer service and satisfaction levels?
- Can the bank introduce new financial products or services to attract more customers and increase profitability?

The objective of this analysis is to provide the Czechoslovakia Bank with actionable insights that can help them make informed decisions about their financial operations. The analysis will involve data cleaning, exploratory data analysis, and predictive modeling to identify patterns and trends in the data.


## Datasets:

- This project involves datasets manually created by my Trainer, [Anand Jha](https://github.com/anandjha90). It includes over 1 million randomly generated records across 8 tables.

## Analytical Tools:
For this project, I used the following tools and technologies: 
- **Excel, AWS, Snowflake, MySQL Workbench, and Power BI.**

## Project Features and Workflow:

This project involves various steps:
- Utilized both **Excel** and **Snowflake** for [data cleaning and transformation](https://github.com/santoshj7/End_to_End_Project-Czechoslovakia_Banking_Financial_Data_Analysis/blob/main/Data%20Manipulation%20and%20Cleaning%20work.docx). Employed formulas in Excel and SQL commands in Snowflake for this purpose.
- Created an [Entity Relationship (ER) diagram](https://github.com/santoshj7/End_to_End_Project-Czechoslovakia_Banking_Financial_Data_Analysis/tree/main/Entity_Relationship_(ER)_Diagram) using **MySQL Workbench ER model**, which illustrates the relationships between tables.
- Data ingestion was accomplished through the integration of two cloud platforms. **AWS S3** storage bucket was integrated with **Snowflake**, with the necessary relationship Policies, IAM Roles, and stage creation. After successfully creating the stage, data was automatically ingested into the respective tables in Snowflake via Snowpipes.
- Developed the necessary custom tables in Snowflake using SQL code for analysis.
- Connected data from Snowflake to **Power BI** for creating various visualizations and analyses.
- Recognizing that only the transaction table is updated regularly based on the client's previous behavior, the entire process from data injection to final report building was automated using **Stored Procedures** and **Tasks**. All necessary custom table's codes were written in Stored Procedures and then automated through different Tasks with varied schedules to prevent code execution overlaps.
- Following the report creation in Power BI, the report update was automated using **Scheduled Refresh**. The refresh time was set according to the task execution times, with some buffer time.
- As a result, whenever data is loaded into the **S3 bucket**, it is automatically ingested into the **Snowflake table**. **Stored Procedures** are triggered automatically through the **Tasks** according to their scheduled times. The new data is updated in our custom tables. Since the tables are already connected to the **Power BI report**, the new data gets automatically refreshed according to the **Scheduled Refresh** timing in **Power BI**. This ensures that the entire process is automated, and the final report is dynamically updated.

## Demo:

The final report encompasses several key sections, including Demographic Profile, Transactions Overview, Credit Card Transactions Overview, Loan Portfolio, Accounts & Transaction Growth, and Banks Performance & Profitability. The report has dynamic filters, which are used to obtain different insights. The report concludes with detailed insights and recommendations based on the analysis.
- Access an [Interactive Power BI Report](https://project.novypro.com/EQ0nMf) showcasing project's results and visualizations.


## Screenshots

![Report Page 1-4](https://github.com/santoshj7/End_to_End_Project-Czechoslovakia_Banking_Financial_Data_Analysis/blob/main/Final_Report/Images/1-4.png)
![Report Page 5-8](https://github.com/santoshj7/End_to_End_Project-Czechoslovakia_Banking_Financial_Data_Analysis/blob/main/Final_Report/Images/5-8.png)


## Feedback

If you have any feedback, please reach out to me at jsantosh7296@gmail.com

