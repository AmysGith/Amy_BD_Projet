-- ==============================================================
-- UDF : Normalisation des noms d'étudiants
-- ==============================================================

CREATE OR REPLACE FUNCTION fn_normalize_student_name(fullname TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si le nom est NULL, on retourne NULL
    IF fullname IS NULL THEN
        RETURN NULL;
    END IF;

    -- Nettoyage + capitalisation correcte
    RETURN INITCAP(
        LOWER(
            TRIM(fullname)
        )
    );
END;
$$;
