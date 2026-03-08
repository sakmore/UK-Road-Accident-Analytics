
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ROADSAFE_WH;
USE DATABASE ROADSAFE_PROJ;

-- Q1. Fatal collisions by season
-- Which time of year sees the most fatal accidents

SELECT
    d.season,
    SUM(f.collision_count)          AS total_collisions,
    SUM(f.is_fatal_flag)            AS fatal_collisions,
    ROUND(SUM(f.is_fatal_flag) * 100.0
        / SUM(f.collision_count), 2) AS fatal_pct
FROM GOLD.fact_collisions f
JOIN GOLD.dim_date d ON d.date_key = f.date_key
GROUP BY d.season
ORDER BY fatal_pct DESC;

--Summer records the highest number of fatal collisions (368, 1.57%), followed by Spring (293, 1.34%) and Winter (266, 1.34%). Autumn has the lowest fatality rate (273, 1.18%). Overall, summer is the riskiest season for fatal accidents.



-- Q2. Collision severity breakdown by urban vs rural area
-- Are fatal collisions more common in rural or urban areas?

SELECT
    f.urban_or_rural_area,
    s.collision_severity,
    SUM(f.collision_count) AS total_collisions,
    ROUND(SUM(f.collision_count) * 100.0
        / SUM(SUM(f.collision_count)) OVER (PARTITION BY f.urban_or_rural_area), 2) AS pct_within_area
FROM GOLD.fact_collisions f
JOIN GOLD.dim_severity s ON s.severity_key=f.severity_key
WHERE f.urban_or_rural_area is not null
group by f.urban_or_rural_area, s.collision_severity
order by pct_within_area desc;

--Rural areas show a higher share of fatal collisions (2.50%) compared to urban areas (0.85%). Urban collisions are mostly slight (76.6%), while rural collisions have a larger proportion of serious (26.6%) and fatal outcomes. Overall, rural crashes are more severe.


-- Q3. Day of week with most collisions and fatalities
-- Are weekends or weekdays more dangerous?

SELECT 
    d.day_of_week,
    d.week_type,
    SUM(f.collision_count)           AS total_collisions,
    SUM(f.is_fatal_flag)             AS fatal_collisions,
    ROUND(SUM(f.is_fatal_flag) * 100.0
        / SUM(f.collision_count), 2) AS fatal_pct

FROM GOLD.fact_collisions f
JOIN GOLD.dim_date d ON d.date_key=f.date_key
group by d.day_of_week, d.week_type
order by fatal_pct desc;

--Weekend days show slightly higher fatal collision rates than weekdays. Sunday has the highest fatality percentage (1.85%), followed by Saturday (1.50%). Among weekdays, Monday (1.43%) and Tuesday (1.33%) are riskiest, while Wednesday records the lowest fatality rate (1.08%). Overall, weekends are more dangerous in terms of fatal collisions.


-- Q4. Fatal collisions by weather condition
-- Does bad weather lead to more fatal accidents?

SELECT 
    w.weather_conditions,
    SUM(f.collision_count)           AS total_collisions,
    SUM(f.is_fatal_flag)             AS fatal_collisions,
    ROUND(SUM(f.is_fatal_flag) * 100.0
        / SUM(f.collision_count), 2) AS fatal_pct

FROM GOLD.fact_collisions f
JOIN GOLD.dim_weather w ON w.weather_key=f.weather_key
group by w.weather_conditions
order by fatal_pct desc;

--Fatal collisions are most common in bad weather with high winds: “Raining with high winds” (2.78%) and “Fine with high winds” (2.50%). Normal conditions like “Fine without high winds” are lower (1.39%). High winds clearly raise fatality risk.


-- Q5. Collisions by road type and speed limit
-- Which road types and speed limits are most dangerous?
SELECT
    r.road_type,
    r.speed_limit,
    SUM(f.collision_count)           AS total_collisions,
    SUM(f.is_fatal_flag)             AS fatal_collisions,
    ROUND(SUM(f.is_fatal_flag) * 100.0
        / SUM(f.collision_count), 2) AS fatal_pct
    
FROM GOLD.fact_collisions f
JOIN GOLD.dim_road r ON r.road_key=f.road_key
WHERE r.road_type != 'Unknown' AND r.speed_limit > 0
GROUP BY r.road_type,r.speed_limit
ORDER BY fatal_pct desc;

-- Q6. Road surface conditions vs collision severity
-- Are wet or icy roads linked to more serious accidents?

SELECT 
    r.road_surface_conditions,
    s.collision_severity,
    SUM(f.collision_count)           AS total_collisions,
    ROUND(SUM(f.collision_count) * 100.0
        / SUM(SUM(f.collision_count)) OVER (PARTITION BY r.road_surface_conditions), 2)     AS pct_within_surface

FROM GOLD.fact_collisions f
JOIN GOLD.dim_road r     ON r.road_key     = f.road_key
JOIN GOLD.dim_severity s ON s.severity_key = f.severity_key
WHERE r.road_surface_conditions IS NOT NULL
GROUP BY r.road_surface_conditions, s.collision_severity
ORDER BY pct_within_surface desc;

--On wet/damp roads, 23.8% of crashes are serious and 1.53% fatal, compared to dry roads with 23.8% serious and 1.31% fatal. Frost/ice surfaces also show 23.5% serious crashes. Flooded roads, though rare, are most dangerous with 4.1% fatal. Overall, adverse surfaces raise the share of serious and fatal outcomes versus dry roads.


-- Q7. Collisions by vehicle type
-- Which vehicle types are most commonly involved in accidents?

SELECT
    v.vehicle_type,
    COUNT(*)                         AS vehicles_involved,
    ROUND(COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (), 2)  AS pct_of_total
FROM GOLD.fact_vehicles f
JOIN GOLD.dim_vehicle v ON v.vehicle_key = f.vehicle_key
GROUP BY v.vehicle_type
ORDER BY pct_of_total DESC;

--Cars dominate collisions (77%), with vans/light goods vehicles next (7%). Pedal cycles (3.5%) and motorcycles (2–3%) form smaller shares, while heavy goods vehicles, buses, and taxis each contribute around 1–2%. Rare types like agricultural vehicles, minibuses, scooters, trams, or horses are negligible (<0.3%).


-- Q8. Driver age band vs fatal collisions
-- Which age group of drivers is involved in the most fatal accidents?
SELECT
    dd.age_band_of_driver,
    COUNT(*) AS vehicles_involved,
    SUM(fc.is_fatal_flag) AS fatal_collisions,
    ROUND(SUM(fc.is_fatal_flag) * 100.0 / COUNT(*), 2) AS fatal_pct
FROM GOLD.fact_vehicles fv
JOIN GOLD.dim_driver dd
    ON dd.driver_key = fv.driver_key
JOIN GOLD.fact_collisions fc
    ON fc.collision_index = fv.collision_index
WHERE dd.age_band_of_driver NOT LIKE '%Unknown%'
GROUP BY dd.age_band_of_driver
ORDER BY fatal_pct DESC;

--Fatality rates are highest among drivers over 75 (2.27%), followed by 66–75 (1.62%) and 16–20 (1.57%). Middle‑aged groups like 26–35 (1.04%) and 46–55 (1.02%) have lower fatality percentages. In short, the oldest and youngest drivers face the greatest fatal risk.


-- CASUALTY DEMOGRAPHICS

-- Q9. Casualties by gender and severity
-- Are male or female casualties more likely to be fatally injured?
SELECT
    dc.gender,
    dc.casualty_severity,
    SUM(fc.casualty_count) AS total_casualties,
    ROUND(
        SUM(fc.casualty_count) * 100.0
        / SUM(SUM(fc.casualty_count)) OVER (PARTITION BY dc.gender),
        2
    ) AS pct_within_gender
FROM GOLD.fact_casualties fc
JOIN GOLD.dim_casualty dc
    ON dc.casualty_key = fc.casualty_key
WHERE dc.gender IS NOT NULL
GROUP BY dc.gender, dc.casualty_severity
ORDER BY dc.gender, dc.casualty_severity DESC;

--Male casualties show a higher fatality rate (1.53%) compared to females (0.74%). Men also have a larger share of serious injuries (29.6% vs 25.5%), while women have slightly more slight injuries (73.7% vs 68.9%). Overall, male casualties are more likely to be seriously or fatally injured than female casualties.

-- Q10. Casualty type breakdown by age group
-- Which age groups are most at risk as pedestrians, cyclists, or passengers?

SELECT
    c.age_band,
    c.casualty_type,
    SUM(f.casualty_count) AS total_casualties,
    SUM(f.is_fatal) AS fatal_casualties,
    ROUND(SUM(f.is_fatal) * 100.0 / SUM(f.casualty_count), 2) AS fatal_pct
FROM GOLD.fact_casualties f
JOIN GOLD.dim_casualty c
    ON c.casualty_key = f.casualty_key
WHERE c.age_band IS NOT NULL
  AND c.casualty_type IS NOT NULL
GROUP BY c.age_band, c.casualty_type
ORDER BY fatal_pct DESC;

--Fatality rates are highest for older pedestrians (Over 75 at 6.25%) and motorcyclists aged 26–35 (6.21%) and 56–65 (5.91%). Young motorcyclists (16–20 at 5.59%) and children aged 0–5 as vehicle drivers (5.71%) also show elevated fatality risk. Overall, motorcyclists across age bands and elderly pedestrians face the greatest fatality percentages.