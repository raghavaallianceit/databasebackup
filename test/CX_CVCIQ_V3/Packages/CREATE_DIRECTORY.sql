CREATE OR REPLACE PACKAGE cx_cvciq_v3."CREATE_DIRECTORY" AS 
PROCEDURE createdirectory(directory_name IN VARCHAR2, directory_path 
IN VARCHAR2); 
END create_directory;
/