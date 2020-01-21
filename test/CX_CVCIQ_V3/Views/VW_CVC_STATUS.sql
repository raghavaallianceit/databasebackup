CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_status (created_by,created_date,description,"ID",order_numb,updated_by,updated_date) AS
SELECT CREATED_BY,
CREATED_DATE,
DESCRIPTION,
ID,
ORDER_NUMB,
UPDATED_BY,
UPDATED_DATE FROM cx_cvc.CVC_STATUS;