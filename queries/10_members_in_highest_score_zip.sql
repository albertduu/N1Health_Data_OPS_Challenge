SELECT
    member_id,
    member_first_name,
    member_last_name,
    zip_code
FROM std_member_info
WHERE CAST(zip_code AS INTEGER) IN (
    SELECT zcta
    FROM model_scores_by_zip
    WHERE algorex_sdoh_composite_score = (
        SELECT MAX(algorex_sdoh_composite_score)
        FROM model_scores_by_zip
    )
)
ORDER BY member_last_name, member_first_name, member_id;
