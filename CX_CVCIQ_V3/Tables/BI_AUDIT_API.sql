CREATE TABLE cx_cvciq_v3.bi_audit_api (
  "ID" NUMBER,
  user_email VARCHAR2(100 BYTE),
  user_name VARCHAR2(256 BYTE),
  operation_code VARCHAR2(300 BYTE),
  description VARCHAR2(2000 BYTE),
  "PATH" VARCHAR2(300 BYTE),
  http_method VARCHAR2(1000 BYTE),
  java_method VARCHAR2(1000 BYTE),
  request_time NUMBER,
  error_description VARCHAR2(2000 BYTE),
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE)
);