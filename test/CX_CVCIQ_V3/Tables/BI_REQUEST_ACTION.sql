CREATE TABLE cx_cvciq_v3.bi_request_action (
  "ID" NUMBER NOT NULL,
  action_name VARCHAR2(52 BYTE),
  unique_id VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  "VERSION" NUMBER,
  display_text VARCHAR2(256 BYTE),
  request_type_id NUMBER,
  tenant_id NUMBER,
  is_active CHAR(256 BYTE)
);