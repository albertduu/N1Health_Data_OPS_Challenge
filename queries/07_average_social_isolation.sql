SELECT AVG(s.social_isolation_score) AS average_score
FROM std_member_info AS m
JOIN model_scores_by_zip AS s
  ON CAST(m.zip_code AS INTEGER) = s.zcta;
