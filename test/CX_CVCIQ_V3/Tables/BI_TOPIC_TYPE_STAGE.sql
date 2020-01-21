CREATE TABLE cx_cvciq_v3.bi_topic_type_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  "TYPE" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  parent_id NUMBER
);