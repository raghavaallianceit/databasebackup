CREATE TABLE cx_cvciq_v3.bi_request_type_state (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  state_code VARCHAR2(256 BYTE),
  state_name VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP(3),
  updated_ts TIMESTAMP(3),
  "VERSION" NUMBER(6),
  request_type_id NUMBER,
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  cvc_state VARCHAR2(256 BYTE),
  CONSTRAINT bi_state_pk PRIMARY KEY ("ID")
);