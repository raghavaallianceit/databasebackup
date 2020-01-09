CREATE TABLE cx_cvciq_v3.bi_api_method (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  friendly_name VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  created_at TIMESTAMP(3),
  updated_at TIMESTAMP(3),
  "VERSION" NUMBER(20),
  requires_check_trustedapp NUMBER,
  requires_check_role NUMBER,
  is_audited NUMBER,
  audit_message VARCHAR2(512 BYTE),
  is_readonly NUMBER,
  trace_metrics NUMBER,
  trace_request NUMBER,
  requires_check_show_id NUMBER
);