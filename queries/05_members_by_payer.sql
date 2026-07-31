SELECT payer, COUNT(*) AS member_count
FROM std_member_info
GROUP BY payer
ORDER BY member_count DESC, payer;
