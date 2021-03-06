CREATE TABLE cx_cvciq_v3.bi_vendor (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  is_active CHAR(6 BYTE),
  "NAME" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  address1 VARCHAR2(256 BYTE),
  address2 VARCHAR2(256 BYTE),
  city VARCHAR2(256 BYTE),
  "STATE" VARCHAR2(256 BYTE),
  country VARCHAR2(256 BYTE),
  contact_name VARCHAR2(256 BYTE),
  contact_email VARCHAR2(256 BYTE),
  contact_phone VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  zipcode VARCHAR2(256 BYTE),
  location_id NUMBER,
  CONSTRAINT bi_vendor_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_vendor_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);