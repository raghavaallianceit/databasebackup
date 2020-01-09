CREATE TABLE cx_cvciq_v3.bi_request_type_activity (
  "ID" NUMBER NOT NULL,
  request_type_id NUMBER,
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  active_from DATE,
  active_to DATE,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  is_mandatory CHAR,
  unique_id VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  tenant_id NUMBER,
  CONSTRAINT bi_request_type_activity_pk PRIMARY KEY ("ID")
);