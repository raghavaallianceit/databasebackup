CREATE TABLE cx_cvciq_v3.bi_lookup_type_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  code VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  is_active CHAR(256 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  parent_id NUMBER
);