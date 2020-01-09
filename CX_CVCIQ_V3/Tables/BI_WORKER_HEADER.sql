CREATE TABLE cx_cvciq_v3.bi_worker_header (
  "ID" NUMBER,
  external_id VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  max_retry NUMBER,
  retry_interval NUMBER,
  status VARCHAR2(256 BYTE),
  insert_at TIMESTAMP,
  insert_by VARCHAR2(256 BYTE),
  update_at TIMESTAMP,
  update_by VARCHAR2(256 BYTE)
);