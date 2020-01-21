CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_lookup_values (code,created_by,created_date,description,"ID",lov_name,updated_by,updated_date,value1,value2,value3,value4,value5) AS
SELECT CODE,
CREATED_BY,
CREATED_DATE,
DESCRIPTION,
ID,
LOV_NAME,
UPDATED_BY,
UPDATED_DATE,
VALUE1,
VALUE2,
VALUE3,
VALUE4,
VALUE5 FROM cx_cvc.CVC_LOOKUP_VALUES;