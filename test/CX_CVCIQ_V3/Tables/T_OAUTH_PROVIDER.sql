CREATE TABLE cx_cvciq_v3.t_oauth_provider (
  "ID" NUMBER(11) NOT NULL,
  code VARCHAR2(10 BYTE),
  "SCOPE" VARCHAR2(256 BYTE),
  "NAME" VARCHAR2(20 BYTE),
  unique_id VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT t_oauth_provider_pk PRIMARY KEY ("ID")
);