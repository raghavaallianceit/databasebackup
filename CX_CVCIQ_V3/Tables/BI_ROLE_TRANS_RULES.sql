CREATE TABLE cx_cvciq_v3.bi_role_trans_rules (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  validation_rule VARCHAR2(256 BYTE),
  validation_message VARCHAR2(256 BYTE),
  state_id NUMBER(20) NOT NULL,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP(3),
  updated_ts TIMESTAMP(3),
  "VERSION" NUMBER(6),
  request_type_id NUMBER,
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  location_id NUMBER,
  CONSTRAINT bi_role_trans_rules_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_role_trans_rules_loc_fk FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID"),
  CONSTRAINT bi_trans_rules_tenant_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);