CREATE OR REPLACE TRIGGER cx_cvciq_v3."BI_ASSET_DETAIL_DOCUMENTS_TRIG" 
 BEFORE INSERT ON cx_cvciq_v3.BI_ASSET_DETAIL_DOCUMENTS
 FOR EACH ROW
BEGIN
 SELECT BI_ASSET_DETAIL_DOCUMENTS_SEQ.NEXTVAL
 INTO :new.id
 FROM dual;
END;
/