CREATE TABLE cx_cvciq_v3.bi_vendor_tags (
  vendor_id NUMBER,
  tags VARCHAR2(256 BYTE),
  CONSTRAINT bi_vendor_tags_vendor_id_fk FOREIGN KEY (vendor_id) REFERENCES cx_cvciq_v3.bi_vendor ("ID")
);