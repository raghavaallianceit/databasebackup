CREATE OR REPLACE TRIGGER cx_cvciq_v3." BI_LOCATION_TRIGGER" 
BEFORE INSERT ON cx_cvciq_v3.BI_LOCATION
FOR EACH ROW
DISABLE BEGIN
SELECT BI_LOCATION_SEQ.NEXTVAL
INTO :new.id
FROM dual;
END;
/