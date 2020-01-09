CREATE TABLE cx_cvciq_v3.bi_location_user_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  active_to DATE,
  tenant_id NUMBER,
  location_id NUMBER,
  user_id NUMBER,
  role_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active CHAR(256 BYTE),
  "VERSION" NUMBER,
  active_from DATE
);