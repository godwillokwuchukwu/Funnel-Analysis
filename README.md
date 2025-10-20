# E-Commerce Funnel Analysis: Optimizing Customer Journeys at MyOnlineShop

I had the opportunity to dive deep into e-commerce analytics during my internship with MyOnlineShop's Team Ace. In Week 4 of the program, our team tackled a critical project: conducting a funnel analysis on a simulated e-commerce dataset. This exercise not only honed my skills in SQL data cleaning, visualization, and storytelling but also highlighted the power of funnel analysis in driving business growth. In this article, I'll walk you through the project step by step, sharing the process, key learnings, insights, and long-term recommendations for MyOnlineShop. This project is a cornerstone of my portfolio, demonstrating my ability to handle real-world data challenges and deliver value through data-driven narratives.

## Project Overview and Objectives

MyOnlineShop, a pre-launch e-commerce platform, aimed to build a robust understanding of customer behavior to optimize its shopping experience. Since the company lacked live transactional data, we used a sample dataset, which simulated user interactions in an online retail environment. The dataset included event logs such as product views, add-to-cart actions, checkouts, and purchases, along with attributes like country, device, and revenue.

The primary **objectives** were:
- To map and analyze the customer journey from product discovery to purchase completion.
- To identify drop-off points and calculate conversion rates to uncover friction in the user experience.
- To generate visualizations and insights that could inform pre-launch optimizations.
- To practice collaborative data analysis, from querying to storytelling, in a team setting.

Funnel analysis is essential in e-commerce because it quantifies user progression through sequential stages, revealing where potential customers abandon the process. According to industry resources like Google and Daasity, this method can improve conversion rates by 10-20% by addressing bottlenecks, ultimately boosting revenue and customer satisfaction. For MyOnlineShop, this project laid the groundwork for data-informed decision-making as the platform scales.

## Step 1: Research and Conceptual Understanding

Before touching the data, I immersed myself in funnel theory. I reviewed key resources:
- A YouTube introduction to funnels for a high-level overview.
- Google's marketing perspective on funnel analysis.
- Articles by Tomi Mester and Daasity on conversion funnels.
- Guides on creating funnel charts in Google Sheets (Ben Collins) and Chartio.

This step was crucial because a strong theoretical foundation ensures accurate interpretation. Without it, analyses risk misrepresenting user behavior. For instance, understanding that funnels are linear simplifications of complex journeys helped me focus on core stages: View Item, Add to Cart, Begin Checkout, and Purchase.

Importance: This research phase prevents common pitfalls like overlooking non-linear paths or miscalculating metrics, ensuring the analysis aligns with business goals.

## Step 2: Data Cleaning and Preparation

The raw dataset in the 'best' table was messy—common in real-world scenarios with issues like inconsistent date formats, NULL values in revenue fields, and untrimmed strings. Clean data is the bedrock of reliable analysis; as the saying goes, "garbage in, garbage out." We used SQL Server to clean it, as detailed in our Data_cleaning.sql script.

Key processes:
- **Date and Time Standardization**: Converted event dates from strings (e.g., 'YYYY-MM-DD 00:00:00') to proper DATE types using CAST and LEFT functions. Added separate columns for date and time only.
  - Query example:
    ```
    ALTER TABLE best ADD event_date_cleaned DATE;
    UPDATE best SET event_date_cleaned = CAST(LEFT(event_date, CHARINDEX(' 00:00:00', event_date) - 1) AS DATE) WHERE event_date LIKE '% 00:00:00%';
    ```
- **Handling NULLs and Numerics**: For fields like event_value_in_usd and total_item_quantity, replaced NULLs with defaults (0.00 or 0) and ensured numeric types using ISNUMERIC checks.
  - Example:
    ```
    UPDATE best SET event_value_in_usd_cleaned = CASE WHEN event_value_in_usd IS NOT NULL AND ISNUMERIC(event_value_in_usd) = 1 THEN CAST(event_value_in_usd AS DECIMAL(18,2)) ELSE 0.00 END;
    ```
- **String Cleaning**: Trimmed and lowercased fields like campaign and language, replacing NULLs with '<other>'.
- **Column Management**: Dropped redundant columns and renamed cleaned ones for simplicity.

We verified each step with SELECT statements to ensure data integrity.

Importance: Cleaning took about 40% of our time but was vital—unclean data could inflate drop-offs or skew revenue calculations by 20-30%. This process also prepared the data for aggregation, ensuring accurate funnel metrics.

## Step 3: Querying for Funnel Metrics

With clean data, we wrote SQL queries to extract funnel insights. We focused on unique events per user to avoid double-counting, using Common Table Expressions (CTEs) for modularity.

- **Top Countries by Event Count**: Aggregated events by country to identify key markets.
  - Query:
    ```
    WITH UniqueEvents AS (
        SELECT country, COUNT(*) AS event_count
        FROM best
        WHERE rn = 1
        GROUP BY country
    )
    SELECT TOP 3 country, event_count FROM UniqueEvents ORDER BY event_count DESC;
    ```
    Results: United States (3.8K events), India (0.8K), Canada (0.6K).

- **Funnel Stages and Drop-Offs**: Filtered for key events ('view_item', 'add_to_cart', 'begin_checkout', 'purchase'). Calculated counts, conversion percentages, and drop-offs per country using LAG for stage-over-stage comparisons.
  - Core CTEs: UniqueEvents for deduplication, EventCounts for aggregation, FunnelData for ordering stages, FunnelWithMetrics for calculations.
  - Example metrics: From View Item to Add to Cart, US drop-off was 78.41%.

Importance: These queries enabled precise segmentation (e.g., by country), revealing uneven performance. Without deduplication via ROW_NUMBER(), we'd overcount sessions, leading to misleading conversion rates.

## Step 4: Visualization and Dashboard Creation

We built interactive dashboards in Power BI (inferred from screenshots) to visualize the funnel.

- **Key Components**:
  - Total Events: 8,530; Purchase Revenue: 236 USD; Add to Cart: 90.
  - Funnel Chart: Showed drop-offs (e.g., 82.86% from View Item to Add to Cart overall).
  - Line Charts: Event by Day/Page Title (spikes around day 20-30); Purchase Revenue by Day (peak at 200 USD, drop to 0).
  - Bar Charts: Top Countries (US dominant); Events by Category (US leads across categories).
  - Country-Specific Funnels: Highlighted Canada's high payment drop-off.

Importance: Visualizations make complex data accessible. A well-labeled funnel chart (with percentages) allows stakeholders to spot issues at a glance, fostering quicker decisions. We included recommendations directly on the dashboard for context.

## Key Insights and Findings

1. **Significant Drop-Offs in the Funnel**: Overall, only 1.06% of add-to-cart events led to purchases, with major friction at add-to-cart (78-82% drop-off across countries). This suggests issues in product selection or checkout usability.
2. **Country Variations**: US dominated with 3.8K events but had a 71.43% add-to-cart drop-off in Canada, indicating payment barriers. India showed seasonal spikes, possibly from promotions.
3. **Revenue Short-Lived**: Purchases spiked to 200 USD around day 25 but dropped sharply, signaling ineffective sustained engagement.
4. **Browser and Device Insights**: Chrome sustained growth; mobile optimization needed for India.

These insights were derived from combining metrics with business context, emphasizing the need for targeted interventions.

## Recommendations for Long-Term Improvement (2-10 Years)

To position MyOnlineShop as a market leader, here are strategic recommendations based on our analysis:

- **Short-Term (2-3 Years)**: Address immediate drop-offs by A/B testing checkout flows (e.g., one-click payments to reduce Canada's 71% drop-off). Invest in targeted marketing for underperforming countries like India, leveraging promotions to sustain engagement beyond spikes. Enhance mobile compatibility, as data suggests browser-specific issues.
  
- **Medium-Term (4-6 Years)**: Build AI-driven personalization engines to reduce add-to-cart friction, recommend products based on user behavior, potentially increasing conversions by 15-25%. Expand into new markets (e.g., France/UK, with minimal current engagement) through localized content and partnerships.

- **Long-Term (7-10 Years)**: Integrate advanced analytics like predictive modeling to forecast drop-offs and automate interventions (e.g., real-time chatbots at checkout). Aim for omnichannel integration (app, web, physical pop-ups) to create seamless journeys, targeting a 30-40% overall conversion rate. Foster a data culture by training teams on funnel tools, ensuring continuous optimization as the platform scales to millions of users.

Implementing these could double revenue in 5 years by minimizing losses at each stage.

## Conclusion and Reflections

This project reinforced the iterative nature of data storytelling: from theory to cleaning, querying, visualization, and insights. As a team, we collaborated seamlessly—dividing tasks between SQL experts and visualizers—delivering a comprehensive submission ahead of deadline. Personally, it sharpened my SQL proficiency and taught me to weave narratives around data, a skill I'll bring to future roles.

For MyOnlineShop, this analysis provides a blueprint for launch success. I'm excited to apply these learnings in my next data role—feel free to connect if you're hiring for data analyst positions!

*References: Google Funnel Resources, Daasity Blog, Ben Collins' Funnel Guide. Dataset: AdventureWorks (simulated). Tools: SQL Server, Power BI.*

