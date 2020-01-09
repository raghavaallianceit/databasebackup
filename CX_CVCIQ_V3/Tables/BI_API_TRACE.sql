CREATE TABLE cx_cvciq_v3.bi_api_trace (
  "ID" NUMBER(20),
  unique_id VARCHAR2(256 BYTE),
  api_method_id VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE),
  exec_start_time TIMESTAMP,
  exec_end_time TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  created_at TIMESTAMP(3),
  updated_at TIMESTAMP(3),
  "VERSION" NUMBER,
  request_body CLOB,
  response_body CLOB,
  execution_time NUMBER
);