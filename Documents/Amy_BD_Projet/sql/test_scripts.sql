---==================================================================
---Pour tester les exceptions, lancer un par un 
---car sinon ça va toujours éxécuter que le premier qu'il trouve
---==================================================================

---affecter un developpeur à un projet
SELECT sp_add_project_developer(5, 12, 
fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala'));

---vérification des exceptions 
SELECT sp_add_project_developer(
    999,   -- projet inexistant
    12,    -- dev existant
    fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala')
);

SELECT sp_add_project_developer(
    5,     -- projet existant
    999,   -- dev inexistant
    fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala')
);
