CREATE OR REPLACE TRIGGER cx_cvciq_v3."BI_PROPERTY_TRIGGER" 
 BEFORE INSERT ON cx_cvciq_v3.BI_PROPERTY
 FOR EACH ROW
BEGIN
 SELECT BI_PROPERTY_SEQ.NEXTVAL
 INTO :new.id
 FROM dual;
END;
/