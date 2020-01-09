CREATE TABLE cx_cvciq_v3.bi_worker_line (
  "ID" NUMBER,
  worker_header_id NUMBER,
  line_output VARCHAR2(2000 BYTE),
  status VARCHAR2(256 BYTE),
  max_retry NUMBER,
  curr_retry NUMBER,
  retry_interval NUMBER,
  insert_at TIMESTAMP,
  update_at TIMESTAMP,
  insert_by VARCHAR2(256 BYTE),
  update_by VARCHAR2(256 BYTE),
  external_id VARCHAR2(256 BYTE),
  line_input CLOB
);