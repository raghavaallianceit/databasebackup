CREATE TABLE cx_cvciq_v3.bi_location_parameter (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(250 BYTE),
  location_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  tenant_id NUMBER,
  "VERSION" NUMBER,
  is_active CHAR,
  param_name VARCHAR2(256 BYTE),
  param_display_text VARCHAR2(1000 BYTE),
  param_value VARCHAR2(2000 BYTE),
  param_description VARCHAR2(2000 BYTE),
  param_type VARCHAR2(256 BYTE),
  param_validation VARCHAR2(2000 BYTE),
  param_display_type VARCHAR2(256 BYTE),
  is_required CHAR,
  is_modifiable CHAR,
  CONSTRAINT bi_location_parameter_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_location_parameter_fk1 FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
)
ENABLE ROW MOVEMENT;