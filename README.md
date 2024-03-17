# Sales Analysis Using Python and SQL

In this project, I have analysed mothly sales data of an Ecommerce shop for year 2019 using Python and SQL.

In python - pandas, matplotlib and seaborn library is used for analysis.

This Project includes:
1) Data Cleaning
2) Feature Engineering
3) EDA

Data Cleaning is also done is SQL.

Following questions are answered while analysis:
1) Best Month for Sales and Quantity Sold ?
2) Which City Sold the Most Product ?
3) Best Time to Display Advertisements to Maximize the Likelihood of Customer’s Buying Product ?
4) Which Product Sold the Most ?
5) Which Products Most Often Sold Together ? (Pair of 2 and 3 both analysed)
6) Month on Month Sales Growth% ?

To answer the above questions in Python following methods of pandas, matplotlib and seaborn are used:
1) Concatenated multiple csvs together to create a new DataFrame (pd.concat)
2) Added columns
3) Parsed cells as strings to make new columns (.str)
4) Used the .apply() method
5) Used groupby to perform aggregate analysis
6) Plotted bar charts and line graphs to visualize our results

To answer the above questions in SQL following methods are used:
1) Cleaned data with update, alter and delete commands
2) Used window function 
3) Used groupby to perform aggregate analysis
4) Used substring_index and substring function for city and state string extraction from address column

