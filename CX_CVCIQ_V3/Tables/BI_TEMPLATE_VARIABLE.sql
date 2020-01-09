CREATE TABLE cx_cvciq_v3.bi_template_variable (
  "ID" NUMBER NOT NULL,
  "NAME" VARCHAR2(50 BYTE),
  description VARCHAR2(126 BYTE),
  unique_id VARCHAR2(56 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active NUMBER,
  CONSTRAINT bi_template_variables_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_template_variables_uk1 UNIQUE ("NAME")
);