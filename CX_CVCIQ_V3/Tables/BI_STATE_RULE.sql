CREATE TABLE cx_cvciq_v3.bi_state_rule (
  "ID" NUMBER NOT NULL,
  state_id NUMBER,
  request_type_id NUMBER,
  rule_name VARCHAR2(256 BYTE),
  rule_desc VARCHAR2(256 BYTE),
  rule_expr VARCHAR2(256 BYTE),
  unique_id VARCHAR2(256 BYTE),
  active_from DATE,
  active_to DATE,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  CONSTRAINT bi_state_rule_pk PRIMARY KEY ("ID")
);