CREATE TABLE cx_cvciq_v3.bi_cvc_presenter_info (
  cvc_request_id NUMBER,
  entry_name VARCHAR2(1000 BYTE),
  presenter_id NUMBER,
  topic_id NUMBER,
  first_name VARCHAR2(255 BYTE),
  last_name VARCHAR2(255 BYTE),
  primary_email VARCHAR2(500 BYTE),
  presenter_status VARCHAR2(255 BYTE),
  designation VARCHAR2(4000 BYTE),
  created_by VARCHAR2(255 BYTE),
  updated_by VARCHAR2(255 BYTE),
  presenter VARCHAR2(256 BYTE)
);