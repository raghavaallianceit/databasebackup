CREATE TABLE cx_cvciq_v3.bi_location_user (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  active_to DATE,
  tenant_id NUMBER,
  location_id NUMBER,
  user_id NUMBER,
  role_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  "VERSION" NUMBER,
  active_from DATE,
  is_active CHAR,
  CONSTRAINT bi_location_user_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_location_user_fk1 FOREIGN KEY (user_id) REFERENCES cx_cvciq_v3.bi_user ("ID")
);