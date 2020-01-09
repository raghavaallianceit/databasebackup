CREATE TABLE cx_cvciq_v3.bi_role_state_action (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  from_state_id NUMBER(20),
  to_state_id NUMBER(20),
  role_id NUMBER(20),
  created_by VARCHAR2(256 BYTE) DEFAULT 'DBUSER',
  updated_by VARCHAR2(256 BYTE) DEFAULT 'DBUSER',
  created_ts TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
  updated_ts TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
  "VERSION" NUMBER(6) DEFAULT 0,
  action_id NUMBER,
  request_type_id NUMBER,
  transition_handler VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  CONSTRAINT bi_state_role_trans_pk PRIMARY KEY ("ID")
);