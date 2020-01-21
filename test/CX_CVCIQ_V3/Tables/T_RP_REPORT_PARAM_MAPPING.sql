CREATE TABLE cx_cvciq_v3.t_rp_report_param_mapping (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  input_param VARCHAR2(256 BYTE),
  trans_param VARCHAR2(256 BYTE),
  report_id NUMBER(20) NOT NULL,
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER(20),
  is_required NUMBER(1) DEFAULT 1,
  CONSTRAINT t_rp_report_param_mapping_pkey PRIMARY KEY ("ID"),
  CONSTRAINT fk_report_id FOREIGN KEY (report_id) REFERENCES cx_cvciq_v3.t_rp_report ("ID")
);