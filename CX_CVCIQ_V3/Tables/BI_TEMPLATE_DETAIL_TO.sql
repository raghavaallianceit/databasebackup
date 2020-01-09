CREATE TABLE cx_cvciq_v3.bi_template_detail_to (
  template_detail_id NUMBER,
  send_to VARCHAR2(256 BYTE),
  CONSTRAINT bi_template_detail_to_id_fk FOREIGN KEY (template_detail_id) REFERENCES cx_cvciq_v3.bi_template_detail ("ID")
);