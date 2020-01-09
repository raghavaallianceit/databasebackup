CREATE TABLE cx_cvciq_v3.bi_request_technical_detail (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  request_id NUMBER,
  item VARCHAR2(256 BYTE),
  requirement CLOB,
  requirement_detail CLOB,
  CONSTRAINT bi_request_technical_detai_pk PRIMARY KEY ("ID") USING INDEX cx_cvciq_v3.bi_request_technical_detail_pk
);