WITH project_year_dev AS (
    SELECT
        p.projectid,
        p.name AS project_name,
        EXTRACT(YEAR FROM p.startdate) AS year,
        pd.devid
    FROM project p
    JOIN projectdeveloper pd ON p.projectid = pd.projectid
)
SELECT
    project_name,
    COUNT(devid) FILTER (WHERE year = 2024) AS "2024"
FROM project_year_dev
GROUP BY project_name
ORDER BY project_name;
