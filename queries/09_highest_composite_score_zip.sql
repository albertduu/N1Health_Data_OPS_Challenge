SELECT
    algorex_sdoh_composite_score AS composite_score,
    printf('%05d', zcta) AS zip_code
FROM model_scores_by_zip
WHERE algorex_sdoh_composite_score = (
    SELECT MAX(algorex_sdoh_composite_score)
    FROM model_scores_by_zip
)
ORDER BY zcta;
