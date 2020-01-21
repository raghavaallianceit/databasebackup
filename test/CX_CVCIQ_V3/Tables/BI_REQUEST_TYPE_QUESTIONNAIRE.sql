CREATE TABLE cx_cvciq_v3.bi_request_type_questionnaire (
  "ID" NUMBER NOT NULL,
  request_type_id NUMBER,
  question VARCHAR2(500 BYTE),
  description VARCHAR2(20 BYTE),
  active_from DATE,
  active_to DATE,
  question_type VARCHAR2(256 BYTE),
  lookup_type VARCHAR2(256 BYTE),
  is_mandatory CHAR,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_rqst_type_qtionre_pk PRIMARY KEY ("ID")
);