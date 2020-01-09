CREATE TABLE cx_cvciq_v3.t_rp_report_group (
  "ID" NUMBER NOT NULL,
  group_name VARCHAR2(256 BYTE),
  group_desc VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER(20),
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  CONSTRAINT t_report_group_pkey PRIMARY KEY ("ID")
);