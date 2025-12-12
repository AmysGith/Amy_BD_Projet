DROP TABLE IF EXISTS projectdeveloper CASCADE;
DROP TABLE IF EXISTS bugfix CASCADE;
DROP TABLE IF EXISTS releases CASCADE;
DROP TABLE IF EXISTS bug CASCADE;
DROP TABLE IF EXISTS developer CASCADE;
DROP TABLE IF EXISTS project CASCADE;


CREATE TABLE project (
    projectid INT PRIMARY KEY,
    student_fullname TEXT,
    name TEXT,
    client TEXT,
    startdate DATE,
    enddate DATE,
    version TEXT
);

CREATE TABLE developer (
    devid INT PRIMARY KEY,
    student_fullname TEXT,
    name TEXT,
    email TEXT,
    specialty TEXT
);

CREATE TABLE bug (
    bugid INT PRIMARY KEY,
    student_fullname TEXT,
    projectid INT REFERENCES project(projectid),
    title TEXT,
    description TEXT,
    severity TEXT,
    status TEXT,
    createdby TEXT
);

CREATE TABLE releases (
    releaseid INT PRIMARY KEY,
    student_fullname TEXT,
    projectid INT REFERENCES project(projectid),
    version TEXT,
    releasedate DATE,
    notes TEXT
);

CREATE TABLE bugfix (
    fixid INT PRIMARY KEY,
    student_fullname TEXT,
    bugid INT REFERENCES bug(bugid),
    devid INT REFERENCES developer(devid),
    fixdate DATE,
    description TEXT
);

CREATE TABLE projectdeveloper (
    projectid INT REFERENCES project(projectid),
    devid INT REFERENCES developer(devid),
    student_fullname TEXT,
    PRIMARY KEY (projectid, devid)
);
