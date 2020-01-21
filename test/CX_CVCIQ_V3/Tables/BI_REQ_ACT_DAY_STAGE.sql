CREATE TABLE cx_cvciq_v3.bi_req_act_day_stage (
  "ID" NUMBER NOT NULL,
  request_id NUMBER,
  arrival VARCHAR2(10 BYTE),
  adjourn VARCHAR2(10 BYTE),
  main_room NUMBER,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  event_date DATE,
  attribute1 VARCHAR2(10 BYTE),
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  arrival_ts TIMESTAMP,
  adjourn_ts TIMESTAMP
);