CREATE TABLE cx_cvciq_v3.bi_topic_type (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  "TYPE" VARCHAR2(256 BYTE),
  description VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE),
  created_ts TIMESTAMP WITH LOCAL TIME ZONE,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP WITH LOCAL TIME ZONE,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  parent_id NUMBER,
  CONSTRAINT bi_topic_type_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_topic_type_unique UNIQUE ("TYPE",parent_id),
  CONSTRAINT bi_topic_type_id_fk FOREIGN KEY (parent_id) REFERENCES cx_cvciq_v3.bi_topic_type ("ID"),
  CONSTRAINT bi_topic_type_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES cx_cvciq_v3.bi_tenant ("ID")
);