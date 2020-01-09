CREATE TABLE cx_cvciq_v3.bi_extended_privilege (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  role_id NUMBER,
  extended_privilege_enabled CHAR,
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  "VERSION" NUMBER,
  is_active CHAR(6 BYTE),
  CONSTRAINT bi_extended_privilege_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_extended_privilege_uk1 UNIQUE (role_id),
  CONSTRAINT bi_extended_privilege_fk1 FOREIGN KEY (role_id) REFERENCES cx_cvciq_v3.bi_role ("ID")
);