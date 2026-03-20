-- SET NOCOUNT ON;
-- SELECT
--     DB_NAME() AS DatabaseName,
--     dp.name AS Username,
--     CAST(STRING_AGG(r.name, ', ') AS VARCHAR(MAX)) AS Roles
-- FROM
--     sys.database_principals dp
-- LEFT JOIN
--     sys.database_role_members rm ON dp.principal_id = rm.member_principal_id
-- LEFT JOIN
--     sys.database_principals r ON rm.role_principal_id = r.principal_id
-- WHERE
--     dp.type IN ('S', 'U', 'G', 'R', 'A')  -- SQL users, Windows users, groups, DB roles, Application roles
--     -- AND dp.principal_id > 4
-- GROUP BY
--     dp.name;
SET NOCOUNT ON;
SELECT
    DB_NAME() AS DatabaseName,
    COALESCE(dp.name, 'Not mapped') AS DatabaseUser,
    COALESCE(STRING_AGG(r.name, ', '), 'No roles') AS Roles,
    sp.name AS ServerLogin,
    COALESCE(STRING_AGG(sr.name, ', '), 'No server roles') AS ServerRoles
FROM sys.server_principals sp
LEFT JOIN sys.database_principals dp
    ON sp.sid = dp.sid
LEFT JOIN sys.database_role_members rm
    ON dp.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r
    ON rm.role_principal_id = r.principal_id
LEFT JOIN sys.server_role_members srm
    ON sp.principal_id = srm.member_principal_id
LEFT JOIN sys.server_principals sr
    ON srm.role_principal_id = sr.principal_id
WHERE sp.type IN ('S','U','G')      -- SQL, Windows users, groups
  AND sp.principal_id > 4            -- exclude system logins like sa=1
GROUP BY dp.name, sp.name;