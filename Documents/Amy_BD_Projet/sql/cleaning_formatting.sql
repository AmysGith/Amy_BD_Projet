-- ==============================================================
-- Correction des erreurs de format : chaque mot commence
-- par une majuscule et le reste est en minuscule
-- ==============================================================

-- Table project
UPDATE project
SET name = INITCAP(TRIM(name)),
    client = INITCAP(TRIM(client)),
    student_fullname = fn_normalize_student_name(student_fullname);

-- Table developer
UPDATE developer
SET name = INITCAP(TRIM(name)),
    specialty = INITCAP(TRIM(specialty)),
    email = LOWER(TRIM(email)),
    student_fullname = fn_normalize_student_name(student_fullname);

-- Table bug
UPDATE bug
SET title = INITCAP(TRIM(title)),
    description = INITCAP(TRIM(description)),
    severity = INITCAP(TRIM(severity)),
    status = INITCAP(TRIM(status)),
    createdby = INITCAP(TRIM(createdby)),
    student_fullname = fn_normalize_student_name(student_fullname);

-- Table releases
UPDATE releases
SET version = INITCAP(TRIM(version)),
    notes = INITCAP(TRIM(notes)),
    student_fullname = fn_normalize_student_name(student_fullname);

-- Table bugfix
UPDATE bugfix
SET description = INITCAP(TRIM(description)),
    student_fullname = fn_normalize_student_name(student_fullname);

-- Table projectdeveloper
UPDATE projectdeveloper
SET student_fullname = fn_normalize_student_name(student_fullname);

-- =========================================
-- NETTOYAGE DES DONNÉES : SUPPRESSION DES DOUBLONS
-- =========================================

-- 1.1 Table enfant BUGFIX
WITH bugfix_duplicates AS (
    SELECT fixid,
           ROW_NUMBER() OVER (
               PARTITION BY bugid, devid, fixdate, description
               ORDER BY fixid
           ) AS rn
    FROM bugfix
)
DELETE FROM bugfix
WHERE fixid IN (
    SELECT fixid 
    FROM bugfix_duplicates
    WHERE rn > 1
);

-- 1.2 Table BUG (parent de BUGFIX)
CREATE TEMP TABLE bug_mapping AS
WITH bug_duplicates AS (
    SELECT bugid,
           ROW_NUMBER() OVER (
               PARTITION BY projectid, title, description, severity, status, createdby
               ORDER BY bugid
           ) AS rn,
           FIRST_VALUE(bugid) OVER (
               PARTITION BY projectid, title, description, severity, status, createdby
               ORDER BY bugid
           ) AS keep_bugid
    FROM bug
)
SELECT bugid AS old_bugid, keep_bugid AS new_bugid
FROM bug_duplicates
WHERE rn > 1;

-- Mettre à jour BUGFIX avec les bons bugid
UPDATE bugfix
SET bugid = bm.new_bugid
FROM bug_mapping bm
WHERE bugfix.bugid = bm.old_bugid;

-- Supprimer les doublons dans BUG
DELETE FROM bug
WHERE bugid IN (SELECT old_bugid FROM bug_mapping);

DROP TABLE IF EXISTS bug_mapping;

-- 1.3 Table RELEASES (enfant de PROJECT)
WITH release_duplicates AS (
    SELECT releaseid,
           ROW_NUMBER() OVER (
               PARTITION BY projectid, version, releasedate, notes
               ORDER BY releaseid
           ) AS rn
    FROM releases
)
DELETE FROM releases
WHERE releaseid IN (
    SELECT releaseid
    FROM release_duplicates
    WHERE rn > 1
);

-- 1.4 Table PROJECT (parent)
CREATE TEMP TABLE project_mapping AS
WITH project_duplicates AS (
    SELECT projectid,
           name, client, startdate, enddate, version,
           ROW_NUMBER() OVER (
               PARTITION BY name, client, startdate, enddate, version
               ORDER BY projectid
           ) AS rn,
           FIRST_VALUE(projectid) OVER (
               PARTITION BY name, client, startdate, enddate, version
               ORDER BY projectid
           ) AS keep_projectid
    FROM project
)
SELECT projectid AS old_projectid, keep_projectid AS new_projectid
FROM project_duplicates
WHERE rn > 1;

-- Mettre à jour les tables enfants avec les bons projectid
UPDATE bug
SET projectid = pm.new_projectid
FROM project_mapping pm
WHERE bug.projectid = pm.old_projectid;

UPDATE releases
SET projectid = pm.new_projectid
FROM project_mapping pm
WHERE releases.projectid = pm.old_projectid;

-- 1.5 Table DEVELOPER (parent)
CREATE TEMP TABLE developer_mapping AS
WITH developer_duplicates AS (
    SELECT devid,
           name, email, specialty,
           ROW_NUMBER() OVER (
               PARTITION BY name, email, specialty
               ORDER BY devid
           ) AS rn,
           FIRST_VALUE(devid) OVER (
               PARTITION BY name, email, specialty
               ORDER BY devid
           ) AS keep_devid
    FROM developer
)
SELECT devid AS old_devid, keep_devid AS new_devid
FROM developer_duplicates
WHERE rn > 1;

-- Mettre à jour BUGFIX avec les bons devid
UPDATE bugfix
SET devid = dm.new_devid
FROM developer_mapping dm
WHERE bugfix.devid = dm.old_devid;

-- 1.6 Table PROJECTDEVELOPER (table de liaison)
-- Fusionner tous les doublons créés par la mise à jour des IDs
CREATE TEMP TABLE projectdeveloper_clean AS
SELECT DISTINCT 
    COALESCE(pm.new_projectid, pd.projectid) AS projectid,
    COALESCE(dm.new_devid, pd.devid) AS devid,
    pd.student_fullname
FROM projectdeveloper pd
LEFT JOIN project_mapping pm ON pd.projectid = pm.old_projectid
LEFT JOIN developer_mapping dm ON pd.devid = dm.old_devid;

-- Vider la table originale
TRUNCATE TABLE projectdeveloper;

-- Réinsérer uniquement les paires uniques
INSERT INTO projectdeveloper (projectid, devid, student_fullname)
SELECT projectid, devid, student_fullname
FROM projectdeveloper_clean;

DROP TABLE IF EXISTS projectdeveloper_clean;

-- Supprimer les projets doublons
DELETE FROM project
WHERE projectid IN (SELECT old_projectid FROM project_mapping);

DROP TABLE IF EXISTS project_mapping;

-- Supprimer les développeurs doublons
DELETE FROM developer
WHERE devid IN (SELECT old_devid FROM developer_mapping);

DROP TABLE IF EXISTS developer_mapping;

-- ==============================================================
-- Correction des erreurs erreurs injectées dans les emails
-- ==============================================================


-- Corriger les emails NULL
--    COALESCE : si email est NULL, on le remplace
--    par un email construit à partir du nom
UPDATE developer
SET email = COALESCE(
    email,
    LOWER(REPLACE(name, ' ', '.')) || '@gmail.com'
);


-- Correction des emails invalides (validation simple)
--    Regex basique : quelquechose@quelquechose.domaine
UPDATE developer
SET email = LOWER(REPLACE(name, ' ', '.')) || '@gmail.com'
WHERE email !~ '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$';


-- Sécurisation supplémentaire
--    Cas où des caractères invalides subsistent
--    (ex: chiffres injectés, symboles étranges)
UPDATE developer
SET email =
    REGEXP_REPLACE(
        LOWER(REPLACE(name, ' ', '.')) || '@gmail.com',
        '[^a-z.@]',
        '',
        'g'
    );


