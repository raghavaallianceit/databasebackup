CREATE TABLE cx_cvciq_v3.bi_role_stage (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR(6 BYTE),
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_role_pk1 PRIMARY KEY ("ID"),
  CONSTRAINT bi_role_unique1 UNIQUE ("NAME")
);