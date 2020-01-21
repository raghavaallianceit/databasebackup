CREATE TABLE cx_cvciq_v3.t_rp_lookup_type (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER,
  is_active CHAR(256 BYTE),
  CONSTRAINT t_rp_lookup_type_pk PRIMARY KEY ("ID")
);