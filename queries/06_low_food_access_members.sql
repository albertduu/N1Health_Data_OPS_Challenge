SELECT COUNT(*) AS member_count
FROM std_member_info AS m
JOIN model_scores_by_zip AS s
  ON CAST(m.zip_code AS INTEGER) = s.zcta
WHERE s.food_access_score < :food_access_threshold;
