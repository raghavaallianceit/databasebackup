CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_user (created_by,created_date,first_name,"ID",is_super,last_name,occ_access,phone,title,updated_by,updated_date) AS
SELECT CREATED_BY,
CREATED_DATE,
FIRST_NAME,
ID,
IS_SUPER,
LAST_NAME,
OCC_ACCESS,
PHONE,
TITLE,
UPDATED_BY,
UPDATED_DATE FROM cx_cvc.CVC_USER;