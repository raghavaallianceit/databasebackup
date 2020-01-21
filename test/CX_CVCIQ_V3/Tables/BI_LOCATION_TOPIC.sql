CREATE TABLE cx_cvciq_v3.bi_location_topic (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  is_active CHAR(6 BYTE),
  "VERSION" NUMBER,
  tenant_id NUMBER,
  topic_id NUMBER,
  location_id NUMBER,
  CONSTRAINT bi_location_topic_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_location_topic_unique UNIQUE (location_id,topic_id),
  CONSTRAINT bi_location_topic_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID"),
  CONSTRAINT bi_location_topic_topic_id_fk FOREIGN KEY (topic_id) REFERENCES cx_cvciq_v3.bi_topic ("ID")
);