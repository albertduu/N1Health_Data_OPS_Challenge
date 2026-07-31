DROP TABLE IF EXISTS std_member_info;

CREATE TABLE std_member_info AS
WITH combined_rosters AS (
    SELECT trim(CAST(Person_Id AS TEXT)) AS member_id,
           trim(First_Name) AS member_first_name,
           trim(Last_Name) AS member_last_name,
           CASE WHEN trim(Dob) LIKE '__/__/____'
                THEN substr(trim(Dob), 7, 4) || '-' ||
                     substr(trim(Dob), 1, 2) || '-' ||
                     substr(trim(Dob), 4, 2)
                ELSE date(trim(Dob)) END AS date_of_birth,
           trim(Street_Address) AS main_address, trim(City) AS city,
           CASE WHEN upper(trim(State)) IN ('CA', 'CALIFORNIA') THEN 'CA'
                ELSE upper(trim(State)) END AS state,
           printf('%05d', CAST(Zip AS INTEGER)) AS zip_code, trim(payer) AS payer,
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____'
                THEN substr(trim(eligibility_start_date), 7, 4) || '-' ||
                     substr(trim(eligibility_start_date), 1, 2) || '-' ||
                     substr(trim(eligibility_start_date), 4, 2)
                ELSE date(trim(eligibility_start_date)) END AS eligibility_start_date,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____'
                THEN substr(trim(eligibility_end_date), 7, 4) || '-' ||
                     substr(trim(eligibility_end_date), 1, 2) || '-' ||
                     substr(trim(eligibility_end_date), 4, 2)
                ELSE date(trim(eligibility_end_date)) END AS eligibility_end_date,
           1 AS source_roster FROM roster_1
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), trim(First_Name), trim(Last_Name),
           CASE WHEN trim(Dob) LIKE '__/__/____' THEN substr(trim(Dob),7,4)||'-'||substr(trim(Dob),1,2)||'-'||substr(trim(Dob),4,2) ELSE date(trim(Dob)) END,
           trim(Street_Address), trim(City), CASE WHEN upper(trim(State)) IN ('CA','CALIFORNIA') THEN 'CA' ELSE upper(trim(State)) END,
           printf('%05d',CAST(Zip AS INTEGER)), trim(payer),
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END, 2 FROM roster_2
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), trim(First_Name), trim(Last_Name),
           CASE WHEN trim(Dob) LIKE '__/__/____' THEN substr(trim(Dob),7,4)||'-'||substr(trim(Dob),1,2)||'-'||substr(trim(Dob),4,2) ELSE date(trim(Dob)) END,
           trim(Street_Address), trim(City), CASE WHEN upper(trim(State)) IN ('CA','CALIFORNIA') THEN 'CA' ELSE upper(trim(State)) END,
           printf('%05d',CAST(Zip AS INTEGER)), trim(payer),
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END, 3 FROM roster_3
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), trim(First_Name), trim(Last_Name),
           CASE WHEN trim(Dob) LIKE '__/__/____' THEN substr(trim(Dob),7,4)||'-'||substr(trim(Dob),1,2)||'-'||substr(trim(Dob),4,2) ELSE date(trim(Dob)) END,
           trim(Street_Address), trim(City), CASE WHEN upper(trim(State)) IN ('CA','CALIFORNIA') THEN 'CA' ELSE upper(trim(State)) END,
           printf('%05d',CAST(Zip AS INTEGER)), trim(payer),
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END, 4 FROM roster_4
    UNION ALL SELECT trim(CAST(Person_Id AS TEXT)), trim(First_Name), trim(Last_Name),
           CASE WHEN trim(Dob) LIKE '__/__/____' THEN substr(trim(Dob),7,4)||'-'||substr(trim(Dob),1,2)||'-'||substr(trim(Dob),4,2) ELSE date(trim(Dob)) END,
           trim(Street_Address), trim(City), CASE WHEN upper(trim(State)) IN ('CA','CALIFORNIA') THEN 'CA' ELSE upper(trim(State)) END,
           printf('%05d',CAST(Zip AS INTEGER)), trim(payer),
           CASE WHEN trim(eligibility_start_date) LIKE '__/__/____' THEN substr(trim(eligibility_start_date),7,4)||'-'||substr(trim(eligibility_start_date),1,2)||'-'||substr(trim(eligibility_start_date),4,2) ELSE date(trim(eligibility_start_date)) END,
           CASE WHEN trim(eligibility_end_date) LIKE '__/__/____' THEN substr(trim(eligibility_end_date),7,4)||'-'||substr(trim(eligibility_end_date),1,2)||'-'||substr(trim(eligibility_end_date),4,2) ELSE date(trim(eligibility_end_date)) END, 5 FROM roster_5
),
eligible_2025 AS (
    SELECT * FROM combined_rosters
    WHERE eligibility_start_date <= :year_end
      AND eligibility_end_date >= :year_start
),
ranked_members AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY member_id
        ORDER BY eligibility_end_date DESC, eligibility_start_date DESC,
                 source_roster DESC
    ) AS row_rank
    FROM eligible_2025
)
SELECT member_id, member_first_name, member_last_name, date_of_birth,
       main_address, city, state, zip_code, payer, eligibility_start_date,
       eligibility_end_date
FROM ranked_members WHERE row_rank = 1;

CREATE UNIQUE INDEX IF NOT EXISTS idx_std_member_info_member_id
    ON std_member_info(member_id);
CREATE INDEX IF NOT EXISTS idx_std_member_info_zip_code
    ON std_member_info(zip_code);
CREATE INDEX IF NOT EXISTS idx_std_member_info_eligibility
    ON std_member_info(eligibility_start_date, eligibility_end_date);
