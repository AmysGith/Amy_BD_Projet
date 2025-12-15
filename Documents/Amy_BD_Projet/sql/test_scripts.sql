-- ==============================================================
-- Test des procédures
-- ==============================================================
-- Supposons que nous voulons ajouter le développeur 12 au projet 3
CALL sp_assign_developer_to_project(3, 12, 
fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala'));

-- Vérifier que l’insertion a bien eu lieu
SELECT * FROM projectdeveloper
WHERE projectid = 3 AND devid = 12;

-- Essayer de réassigner le même développeur pour montrer le rollback / gestion d’erreur
CALL sp_assign_developer_to_project(3, 12, 
fn_normalize_student_name('RATSIHOARANA Nomenahitantsoa Amy Andriamalala'));

-- ==============================================================
-- Test des vues
-- ==============================================================
--Visualiser le nombre de bugs pour le projet 1 : 
SELECT * 
FROM mv_bug_count_by_project
WHERE projectid = 1;

-- insérer de nouvelles données dans la table
INSERT INTO bug (
bugid,
student_fullname,
projectid,
title,
description,
severity,
status,
createdby
)
VALUES (
80,
'TEST',
1,
'Bug de test',
'Insertion contrôlée pour démonstration',
'LOW',
'OPEN',
'tester'
);

--re visualiser pour montrer que le nombre ne change pas : 
SELECT * 
FROM mv_bug_count_by_project
WHERE projectid = 1;

--on rafraîchit la vue
REFRESH MATERIALIZED VIEW mv_bug_count_by_project;

--re visualiser pour montrer que le nombre a bien changé : 
SELECT * 
FROM mv_bug_count_by_project
WHERE projectid = 1;

-- ==============================================================
-- Test des TRIGGERS
-- ==============================================================
-- 1) insertion valide : 
INSERT INTO bug (
    bugid, student_fullname, projectid, title, description, severity, status, createdby
)
VALUES (
    81,'Test User',1,'Bug test valide','Ceci est un test','LOW','OPEN','tester'
);

-- 2) insertion invalide : 
INSERT INTO bug (
    bugid, student_fullname, projectid, title, description, severity, status, createdby
)
VALUES (82,'Test User',1,'Bug gravité invalide','Test trigger','VERY_HIGH','OPEN','tester'
);
