/* https://www.w3schools.com/sql/sql_create_table.asp */
CREATE TABLE IF NOT EXISTS KF4005A (
    perms CHAR(10),
    links INT(6),
    userID VARCHAR(30),
    groupID VARCHAR(30),
    size INT(10),
    modified DATETIME,
    filePath VARCHAR(200) PRIMARY KEY
);

/*
https://dev.mysql.com/doc/refman/8.0/en/load-data.html
https://stackoverflow.com/questions/18838000/mysql-csv-import-datetime-value
*/
LOAD DATA LOCAL INFILE 'filedata.txt' INTO TABLE KF4005A
FIELDS TERMINATED BY ' '
OPTIONALLY ENCLOSED BY '"';

SELECT filePath, perms, userID, groupID, modified FROM KF4005A