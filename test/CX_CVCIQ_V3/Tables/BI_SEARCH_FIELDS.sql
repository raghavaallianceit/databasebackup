CREATE TABLE cx_cvciq_v3.bi_search_fields (
  "ID" NUMBER(38) NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  search_type VARCHAR2(256 BYTE),
  search_param VARCHAR2(256 BYTE),
  display_text VARCHAR2(256 BYTE),
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  is_active NUMBER DEFAULT 1,
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  "VERSION" NUMBER,
  location_id NUMBER,
  tenant_id NUMBER,
  is_default NUMBER DEFAULT 0,
  search_order NUMBER(4),
  CONSTRAINT bi_search_fields_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_search_fields_location_fk1 FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
);