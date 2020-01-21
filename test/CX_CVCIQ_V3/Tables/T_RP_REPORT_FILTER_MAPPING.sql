CREATE TABLE cx_cvciq_v3.t_rp_report_filter_mapping (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  parameter_name VARCHAR2(256 BYTE),
  db_column_name VARCHAR2(256 BYTE),
  report_id NUMBER(20) NOT NULL,
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER(20) DEFAULT 0,
  CONSTRAINT t_rp_report_filter_mapping_pk PRIMARY KEY ("ID")
);