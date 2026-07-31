SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT member_id) AS distinct_member_count
FROM std_member_info;
