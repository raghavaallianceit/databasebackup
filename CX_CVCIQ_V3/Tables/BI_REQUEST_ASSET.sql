CREATE TABLE cx_cvciq_v3.bi_request_asset (
  "ID" NUMBER NOT NULL,
  asset_type_id NUMBER,
  asset_id NUMBER,
  request_id NUMBER,
  unique_id VARCHAR2(20 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(20 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_request_asset_pk PRIMARY KEY ("ID")
);