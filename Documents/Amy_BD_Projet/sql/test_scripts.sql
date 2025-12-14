-- Supposons que nous voulons ajouter le développeur 12 au projet 3
CALL sp_assign_developer_to_project(3, 12, 
fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala'));

-- Vérifier que l’insertion a bien eu lieu
SELECT * FROM projectdeveloper
WHERE projectid = 3 AND devid = 12;

-- Essayer de réassigner le même développeur pour montrer le rollback / gestion d’erreur
CALL sp_assign_developer_to_project(3, 12, 
fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala'));