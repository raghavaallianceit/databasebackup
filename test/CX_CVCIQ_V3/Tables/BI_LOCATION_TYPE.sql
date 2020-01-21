CREATE TABLE cx_cvciq_v3.bi_location_type (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  is_active CHAR(256 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_location_type_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_location_type_unique UNIQUE ("NAME"),
  CONSTRAINT bi_location_type_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);