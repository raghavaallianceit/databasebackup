CREATE TABLE cx_cvciq_v3.bi_property (
  "ID" NUMBER NOT NULL,
  service VARCHAR2(256 BYTE),
  key_name VARCHAR2(256 BYTE),
  key_value VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  unique_id VARCHAR2(256 BYTE),
  "VERSION" NUMBER(20),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  is_exposed CHAR(256 BYTE),
  CONSTRAINT bi_property_pk PRIMARY KEY ("ID"),
  CONSTRAINT tenant_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);