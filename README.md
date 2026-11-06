
# Movie Data Analysis & Insights (SQL)

An end-to-end SQL data pipeline and exploratory data analysis (EDA) project built using MySQL to clean raw movie data and extract key business metrics.

---

## Technical Highlights

* **Data Cleaning & Standardization:** Handled missing values, removed duplicate records, and converted date formats (`STR_TO_DATE`).
* **Statistical Analysis:** Calculated Mean vs. Median ratings to analyze distribution skewness.
* **Advanced SQL Concepts:** Utilized CTEs, subqueries, `CASE WHEN` logic, and Window Functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`, `LAG`, `NTILE`).
* **Performance Analytics:** Created cumulative running totals, lag comparisons for revenue differences, and top-grossing movie segmentations.

---

## Key SQL Techniques Used

```sql
-- Example: Window functions for ranking & chronological comparison
SELECT original_title,
       LAG(release_date) OVER(ORDER BY revenue DESC) AS pre_movie_date,
       revenue - LAG(revenue) OVER(ORDER BY revenue DESC) AS revenue_diff
FROM movies_import;
