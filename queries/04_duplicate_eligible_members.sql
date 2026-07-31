WITH combined(member_id, start_date, end_date) AS (
    SELECT trim(CAST(Person_Id AS TEXT)),
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____'
                THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2)
                ELSE date(trim(eligibility_start_date)) END,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____'
                THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2)
                ELSE date(trim(eligibility_end_date)) END FROM roster_1
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END, CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END FROM roster_2
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END, CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END FROM roster_3
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END, CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END FROM roster_4
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END, CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END FROM roster_5
),
eligible AS (
    SELECT member_id FROM combined
    WHERE start_date <= :year_end AND end_date >= :year_start
)
SELECT COUNT(*) AS member_count FROM (
    SELECT member_id FROM eligible GROUP BY member_id HAVING COUNT(*) > 1
);
