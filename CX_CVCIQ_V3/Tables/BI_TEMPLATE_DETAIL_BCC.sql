CREATE TABLE cx_cvciq_v3.bi_template_detail_bcc (
  template_detail_id NUMBER,
  sendbcc VARCHAR2(256 BYTE),
  CONSTRAINT bi_template_detail_bcc_id_fk FOREIGN KEY (template_detail_id) REFERENCES cx_cvciq_v3.bi_template_detail ("ID")
);