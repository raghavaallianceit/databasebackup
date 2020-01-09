CREATE TABLE cx_cvciq_v3.bi_ui_property (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  service VARCHAR2(256 BYTE),
  key_name VARCHAR2(256 BYTE),
  key_value VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER(20),
  tenant_id NUMBER,
  is_active CHAR,
  is_exposed CHAR,
  CONSTRAINT table2_pk PRIMARY KEY ("ID")
);