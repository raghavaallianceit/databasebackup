CREATE TABLE cx_cvciq_v3.bi_audit (
  "ID" NUMBER,
  object_type VARCHAR2(40 BYTE),
  object_id NUMBER,
  user_email VARCHAR2(100 BYTE),
  user_name VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  activity_time TIMESTAMP,
  status_code VARCHAR2(100 BYTE),
  audit_event_type VARCHAR2(200 BYTE),
  additional_info VARCHAR2(2000 BYTE),
  unique_id VARCHAR2(256 BYTE)
);