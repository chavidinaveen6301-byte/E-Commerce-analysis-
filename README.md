# Olist E-Commerce SQL Analytics Project

End-to-end SQL analysis of the **Olist Brazilian E-Commerce** dataset — covering sales performance, customer behavior, product performance, seller performance, order fulfillment, and payment behavior. Built entirely in MySQL using joins, views, window functions, and conditional aggregation to turn raw transactional tables into business-ready insights.

---

## 📌 Project Overview

Olist is a Brazilian e-commerce marketplace connecting sellers with customers nationwide. This project analyzes Olist's transactional data to answer real business questions around revenue trends, customer retention, product/category performance, seller reliability, delivery delays, and payment behavior — the kind of analysis a Data Analyst would deliver to support strategic decision-making.

**Database:** `olistdb` (MySQL)
**Language:** SQL (MySQL 8+ — uses window functions `LAG()`, CTEs, and views)

---

## 🗂️ Tables Used

| Table | Description |
|---|---|
| `olist_orders_dataset` | Order-level data: status, timestamps, delivery dates |
| `olist_order_items_dataset` | Line items per order: product, seller, price, freight |
| `olist_order_payments_dataset` | Payment type, installments, payment value |
| `olist_order_reviews_dataset` | Customer review scores per order |
| `olist_customers_dataset` | Customer IDs, city, state |
| `olist_sellers_dataset` | Seller IDs, city, state |
| `olist_products_dataset` | Product category (Portuguese) |
| `product_category_name_translation` | Maps Portuguese category names to English |

## 🧱 Views Created

| View | Purpose |
|---|---|
| `order_sales` (replaces `vw_customer_sales`) | Joins customers + orders + payments + reviews for sales/customer analysis |
| `product_analysis` | Joins customers + orders + order items + products + category translation + sellers for product/seller analysis |

---

## 📊 Analysis Sections & Business Questions

### 1. Sales Performance
- Total sales revenue
- Total completed (delivered) orders
- Monthly sales trend & **month-over-month growth %** (via `LAG()` window function)
- Monthly order volume
- Average Order Value (AOV) by month
- Revenue growth using a CTE, restricted to delivered orders
- Top revenue-generating cities/states (drill-down for a selected month)
- Revenue contribution by payment method
- Product category sales for a given month (delivered orders only)

### 2. Customer Analysis
- Total unique customers (`customer_unique_id`)
- **Repeat vs. new customer split** (via subquery + `CASE` on order count)
- Average Order Value (AOV)
- Customer distribution by state and city
- Average review score overall, by state, and by city
- Order volume by payment method
- Purchasing trends over time — by month and by day of week (`DAYNAME()`)

### 3. Product Performance
- Best-selling product categories (by order count)
- Highest revenue-generating categories (Top 5)
- Lowest-performing categories (Bottom 5)
- Average product price by category
- Categories with highest order quantity
- Revenue contribution % by category (category revenue ÷ total revenue)
- Product sales trend over time (monthly)

### 4. Seller Performance
- Total active sellers (sellers with items handed to carrier)
- Total revenue from top 10 sellers
- Top sellers by order count (≥ 1,000 orders)
- Seller distribution by state
- Average delivery time by seller (purchase → carrier handoff)
- Average seller review rating

### 5. Order & Delivery Analysis
- Total orders placed
- Delay in days per order (delivered date vs. estimated date)
- Count and **percentage of delayed orders**
- Overall order success rate (% delivered)
- Order status distribution (delivered, shipped, canceled, etc.)
- Monthly cancellation trend
- Monthly order volume trend
- Average delivery time (purchase → customer delivery)

### 6. Payment Analysis
- Revenue by payment type (Credit Card, Boleto, Voucher, Debit Card)
- Average payment value
- Installment count distribution
- Average number of installments
- Revenue by installment range (formatted in K/M for readability)
- Order count by payment type

---

## 💡 Key Insights

- **Revenue: R$16,008,872.12** across **96,478** completed (delivered) orders.
- **Credit Card** is the dominant payment method — ~78% of revenue (R$12.54M), followed by **Boleto** at ~18% (R$2.87M).
- **São Paulo (SP)** and **Rio de Janeiro (RJ)** are the top two revenue-generating states.
- Monthly revenue is driven mainly by **order volume fluctuation**, not basket size — AOV stays relatively flat month to month.
- **November** saw a sharp +42.36% MoM revenue jump (likely Black Friday-driven), followed by a steep drop in December.
- **May** was the strongest month overall — highest revenue and highest AOV.

---

## 🛠️ Tech Stack

- **MySQL** — querying, views, CTEs, window functions (`LAG`, `OVER`)
- **SQL techniques used:** JOINs across 6+ tables, subqueries, `CASE` logic, conditional aggregation, `DATEDIFF()`, `DAYNAME()`, percentage/growth calculations, top-N filtering

---

## 📁 Repository Structure

```
├── olist_project.sql   # Full SQL script: views + all business-question queries
└── README.md           # Project documentation (this file)
```

---

## ▶️ How to Run

1. Import the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) into a MySQL database named `olistdb`.
2. Ensure table names match those referenced in `olist_project.sql` (e.g. `olist_orders_dataset`, `olist_order_items_dataset`, etc.).
3. Run `olist_project.sql` in order — it creates the `order_sales` and `product_analysis` views first, which later queries depend on.
4. Execute individual query blocks (grouped by section/comment headers) to reproduce each analysis.

---

## 📈 Possible Next Steps

- Connect this SQL layer to Power BI / Tableau for an interactive dashboard.
- Add cohort-based retention analysis for repeat customers.
- Extend seller analysis with late-delivery rate per seller (currently only avg. delivery time is tracked).

---

## Author

Chavidi Naveen
chavidinaveen6301@gmail.com
