CREATE OR REPLACE TRIGGER cx_cvciq_v3."BI_TEMPLATE_DETAIL_TRIGGER"
BEFORE INSERT ON cx_cvciq_v3.BI_TEMPLATE_DETAIL
FOR EACH ROW
BEGIN
SELECT BI_TEMPLATE_DETAIL_SEQ.NEXTVAL
INTO :new.id
FROM dual;
END;
/