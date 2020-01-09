CREATE TABLE cx_cvciq_v3.bi_presenter (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  first_name VARCHAR2(256 BYTE),
  last_name VARCHAR2(256 BYTE),
  title VARCHAR2(256 BYTE),
  is_active CHAR(6 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  designation VARCHAR2(4000 BYTE),
  primary_email VARCHAR2(100 BYTE),
  secondary_email VARCHAR2(100 BYTE),
  location_id NUMBER,
  is_executive CHAR(6 BYTE),
  CONSTRAINT bi_presenter_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_presenter_loc_fk FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
);