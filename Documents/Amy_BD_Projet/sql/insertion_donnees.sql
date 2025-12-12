
COPY project(projectid, student_fullname, name, client, startdate, enddate, version)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\projects.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM project;


COPY developer (devid, student_fullname, name, email, specialty)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\developers.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM developer;


COPY bug(bugid, student_fullname, projectid, title, description, severity, status, createdby)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\bugs.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM bug;


COPY releases (releaseid, student_fullname, projectid, version, releasedate,notes)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\releases.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM releases;


COPY bugfix(fixid, student_fullname, bugid, devid, fixdate,description)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\bugfixes.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM bugfix;


COPY projectdeveloper(projectid, devid, student_fullname)
FROM 'C:\Program Files\PostgreSQL\16\fichierCSV\project_developers.csv'
WITH (
  FORMAT csv,
  HEADER,
  DELIMITER ',',
  ENCODING 'UTF8'
);
SELECT * FROM projectdeveloper;