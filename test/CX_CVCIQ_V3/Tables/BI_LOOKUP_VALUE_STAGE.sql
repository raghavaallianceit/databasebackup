CREATE TABLE cx_cvciq_v3.bi_lookup_value_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  code VARCHAR2(256 BYTE),
  "VALUE" VARCHAR2(256 BYTE),
  parent_id NUMBER,
  is_active CHAR(6 BYTE),
  active_from TIMESTAMP WITH LOCAL TIME ZONE,
  active_to TIMESTAMP WITH LOCAL TIME ZONE,
  tenant_id NUMBER,
  lookup_type_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  "VERSION" NUMBER
);