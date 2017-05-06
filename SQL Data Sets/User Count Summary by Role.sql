SELECT role.`role`, COUNT(*) AS Total FROM users, role, user_role
WHERE users.`user_id`=user_role.`user_id`
AND role.`role`=user_role.`role`
GROUP BY role.`role`