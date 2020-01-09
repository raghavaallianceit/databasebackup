CREATE TABLE cx_cvciq_v3.bi_template_master (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  "TYPE" VARCHAR2(256 BYTE),
  is_active CHAR(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  "VERSION" NUMBER,
  CONSTRAINT bi_template_master_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_template_master_unique UNIQUE ("NAME"),
  CONSTRAINT bi_template_master_tenantid_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);