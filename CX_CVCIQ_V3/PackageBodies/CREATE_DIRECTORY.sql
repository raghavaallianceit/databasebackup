CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."CREATE_DIRECTORY" as 
PROCEDURE createdirectory(directory_name IN VARCHAR2, directory_path 
IN VARCHAR2) IS 
l_exec_string VARCHAR2(1024):= 'CREATE OR REPLACE DIRECTORY '; 
l_directory_name_stripped VARCHAR2(1024); 
l_directory_name_dstripped VARCHAR2(1024); 
l_directory_name_validated VARCHAR2(1024); 
l_directory_validated VARCHAR2(1024); 
BEGIN 
l_directory_name_stripped := REPLACE(directory_name,'''',''); 
l_directory_name_dstripped := REPLACE(l_directory_name_stripped,'"',''); 
l_directory_name_validated := DBMS_ASSERT.simple_sql_name(l_directory_name_dstripped); 
l_directory_validated := REPLACE(directory_path,'.',''); 
IF instr(l_directory_validated,'/u01/thisismypath') = 1 
THEN 
l_exec_string := l_exec_string||l_directory_name_validated ||' AS 
'||''''||l_directory_validated||'''' ; 
EXECUTE IMMEDIATE (l_exec_string); 
l_exec_string := 'GRANT READ, WRITE ON DIRECTORY 
'||l_directory_name_validated ||' TO '||user; 
EXECUTE IMMEDIATE (l_exec_string); 
END IF; 
END createdirectory; 
END create_directory;
/