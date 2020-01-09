CREATE TABLE cx_cvciq_v3.bi_procedure_log (
  "ID" NUMBER,
  proc_name VARCHAR2(100 BYTE),
  attribute1 VARCHAR2(200 BYTE),
  attribute2 NUMBER,
  error_message VARCHAR2(2000 BYTE),
  error_code VARCHAR2(2000 BYTE),
  date_time TIMESTAMP,
  additional_info VARCHAR2(2000 BYTE)
);