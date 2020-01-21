CREATE TABLE cx_cvciq_v3.bi_cxd_data (
  "ID" NUMBER NOT NULL,
  request_id NUMBER,
  json_data VARCHAR2(4000 BYTE),
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER(20),
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active CHAR(256 BYTE),
  CONSTRAINT bi_cxd_data_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_cxd_data_request_fk FOREIGN KEY (request_id) REFERENCES cx_cvciq_v3.bi_request ("ID"),
  CONSTRAINT bi_cxd_data_tenant_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);