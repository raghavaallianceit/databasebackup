CREATE TABLE cx_cvciq_v3.bi_search_field_mapping (
  "ID" NUMBER NOT NULL,
  search_key VARCHAR2(256 BYTE),
  search_value VARCHAR2(1000 BYTE),
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  updated_ts TIMESTAMP,
  is_active CHAR,
  CONSTRAINT bi_search_field_mapping_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_search_field_tenant_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);