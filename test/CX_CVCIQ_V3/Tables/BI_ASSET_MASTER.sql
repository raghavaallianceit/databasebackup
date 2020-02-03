CREATE TABLE cx_cvciq_v3.bi_asset_master (
  "ID" NUMBER,
  unique_id VARCHAR2(256 BYTE),
  "TYPE" VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT bi_asset_master_unique UNIQUE ("TYPE","NAME"),
  CONSTRAINT bi_asset_master_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);