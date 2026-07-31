SELECT COUNT(DISTINCT member_id) AS member_count
FROM std_member_info
WHERE eligibility_start_date <= :april_end
  AND eligibility_end_date >= :april_start;
