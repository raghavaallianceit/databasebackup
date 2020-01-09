CREATE TABLE cx_cvciq_v3.bi_topic_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  code VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  topic_type_id NUMBER,
  parent_id NUMBER,
  asset_detail_id NUMBER,
  additional_info NVARCHAR2(2000),
  is_active CHAR(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER
);