CREATE TABLE cx_cvciq_v3.bi_template_detail_cc (
  template_detail_id NUMBER,
  sendcc VARCHAR2(256 BYTE),
  CONSTRAINT bi_template_detail_cc_id_fk FOREIGN KEY (template_detail_id) REFERENCES cx_cvciq_v3.bi_template_detail ("ID")
);