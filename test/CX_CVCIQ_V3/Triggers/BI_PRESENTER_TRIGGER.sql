CREATE OR REPLACE TRIGGER cx_cvciq_v3."BI_PRESENTER_TRIGGER" 
 BEFORE INSERT ON cx_cvciq_v3.BI_PRESENTER
 FOR EACH ROW
BEGIN
 SELECT BI_PRESENTER_SEQ.NEXTVAL
 INTO :new.id
 FROM dual;
END;
/