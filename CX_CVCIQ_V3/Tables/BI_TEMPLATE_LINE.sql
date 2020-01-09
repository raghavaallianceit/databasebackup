CREATE TABLE cx_cvciq_v3.bi_template_line (
  "ID" NUMBER,
  template_header_id NUMBER,
  "VERSION" NUMBER,
  body_location VARCHAR2(256 BYTE),
  subject VARCHAR2(256 BYTE),
  insert_by VARCHAR2(256 BYTE),
  update_by VARCHAR2(256 BYTE),
  update_at TIMESTAMP,
  insert_at TIMESTAMP,
  external_id VARCHAR2(256 BYTE)
);