CREATE TABLE cx_cvciq_v3.t_rp_report_parameter (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  param_key VARCHAR2(256 BYTE),
  param_value VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER(20),
  CONSTRAINT t_rp_report_parameter_pk PRIMARY KEY ("ID")
);