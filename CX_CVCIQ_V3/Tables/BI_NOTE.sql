CREATE TABLE cx_cvciq_v3.bi_note (
  "ID" NUMBER NOT NULL,
  user_id NUMBER,
  content_type VARCHAR2(100 BYTE),
  "CONTENT" VARCHAR2(4000 BYTE),
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  note_date DATE,
  user_name VARCHAR2(256 BYTE),
  location_id NUMBER,
  note_start_date DATE,
  note_end_date DATE,
  CONSTRAINT note_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_note_location_fk FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
);