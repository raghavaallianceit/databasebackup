CREATE TABLE cx_cvciq_v3.bi_request_type (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  active_from DATE,
  active_to DATE,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  code VARCHAR2(20 BYTE),
  CONSTRAINT bi_workflow_request_type_pk PRIMARY KEY ("ID")
);