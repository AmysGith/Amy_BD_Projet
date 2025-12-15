-- ==============================================================
-- PROCÉDURE MÉTIER : ASSIGNATION D’UN DÉVELOPPEUR À UN PROJET
-- En PostgreSQL, il n'existe pas d'équivalent exact du TRY…CATCH de T-SQL.
-- Ici, le bloc EXCEPTION WHEN OTHERS THEN agit comme un CATCH : 
-- toute erreur levée dans la procédure est interceptée et un message clair est renvoyé.
-- De plus, PostgreSQL exécute automatiquement la procédure dans la transaction en cours.
-- Si une erreur survient, toutes les modifications effectuées dans la procédure sont annulées (atomicité),
-- donc il n'est pas nécessaire d'écrire explicitement BEGIN TRAN / COMMIT / ROLLBACK pour ce cas simple.
-- ==============================================================
CREATE OR REPLACE PROCEDURE sp_assign_developer_to_project(
    p_projectid INT,
    p_devid INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_error_message TEXT;
BEGIN
    -- Commence la transaction explicite
    BEGIN
        -- Vérification de l'existence du projet
        IF NOT EXISTS (SELECT 1 FROM project WHERE projectid = p_projectid) THEN
            RAISE EXCEPTION 'Projet % inexistant', p_projectid;
        END IF;

        -- Vérification de l'existence du développeur
        IF NOT EXISTS (SELECT 1 FROM developer WHERE devid = p_devid) THEN
            RAISE EXCEPTION 'Développeur % inexistant', p_devid;
        END IF;

        -- Vérifie qu’il n’est pas déjà assigné
        IF EXISTS (
            SELECT 1 FROM projectdeveloper 
            WHERE projectid = p_projectid AND devid = p_devid
        ) THEN
            RAISE EXCEPTION 'Développeur % déjà assigné au projet %', p_devid, p_projectid;
        END IF;

        -- Insertion dans la table de liaison
        INSERT INTO projectdeveloper(projectid, devid)
        VALUES (p_projectid, p_devid);

        -- Commit implicite à la fin de la procédure
        RAISE NOTICE 'Succès : Développeur % assigné au projet %', p_devid, p_projectid;

    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
        -- Rejette toute la transaction en cas d'erreur
        RAISE EXCEPTION 'ERREUR CRITIQUE lors de l''assignation : %', v_error_message;
    END;
END;
$$;

-- ==============================================================
-- VUES MATERIALISEES 
-- voir combien il y a de bugs sur un projet
-- ==============================================================
CREATE MATERIALIZED VIEW mv_bug_count_by_project AS
SELECT
    p.projectid,
    p.name AS project_name,
    COUNT(b.bugid) AS total_bugs
FROM project p
LEFT JOIN bug b
    ON p.projectid = b.projectid
GROUP BY
    p.projectid,
    p.name;

CREATE UNIQUE INDEX idx_mv_bug_count_by_project
ON mv_bug_count_by_project(projectid);

