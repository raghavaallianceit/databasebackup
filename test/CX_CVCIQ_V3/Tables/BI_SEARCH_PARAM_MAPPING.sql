CREATE TABLE cx_cvciq_v3.bi_search_param_mapping (
  "ID" NUMBER NOT NULL DISABLE,
  location_id NUMBER,
  search_param VARCHAR2(256 BYTE),
  search_field VARCHAR2(256 BYTE),
  search_resource VARCHAR2(256 BYTE),
  criteria_condition VARCHAR2(20 BYTE),
  is_active NUMBER DEFAULT 1,
  unique_id VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  field_condition VARCHAR2(20 BYTE),
  tenant_id NUMBER,
  retrieval_expression VARCHAR2(256 BYTE),
  display_text VARCHAR2(256 BYTE),
  CONSTRAINT bi_search_param_mapping_pk PRIMARY KEY ("ID") DISABLE NOVALIDATE,
  CONSTRAINT bi_search_param_location_fk1 FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
);