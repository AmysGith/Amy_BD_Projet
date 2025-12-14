CREATE OR REPLACE FUNCTION sp_add_project_developer(
    p_projectid INT,
    p_devid INT,
    p_student_fullname TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Vérification existence projet
    IF NOT EXISTS (SELECT 1 FROM project WHERE projectid = p_projectid) THEN
        RAISE EXCEPTION 'Le projet % est inexistant', p_projectid;
    END IF;

    -- Vérification existence développeur
    IF NOT EXISTS (SELECT 1 FROM developer WHERE devid = p_devid) THEN
        RAISE EXCEPTION 'Développeur % inexistant', p_devid;
    END IF;

    -- Insertion dans projectdeveloper
    INSERT INTO projectdeveloper(projectid, devid, student_fullname)
    VALUES (p_projectid, p_devid, p_student_fullname);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Affectation projet=% / dev=% déjà existante', p_projectid, p_devid;
    WHEN OTHERS THEN
        RAISE;
END;
$$;




