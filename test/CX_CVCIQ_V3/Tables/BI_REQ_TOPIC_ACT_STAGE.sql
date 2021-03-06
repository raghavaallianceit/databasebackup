CREATE TABLE cx_cvciq_v3.bi_req_topic_act_stage (
  "ID" NUMBER NOT NULL,
  request_activity_day_id NUMBER,
  duration NUMBER,
  room NUMBER,
  request_type_activity_id NUMBER,
  topic VARCHAR2(4000 BYTE),
  sub_topic VARCHAR2(256 BYTE),
  optional_topic VARCHAR2(4000 BYTE),
  notes VARCHAR2(4000 BYTE),
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  attribute_info VARCHAR2(20 BYTE),
  no_of_attendees NUMBER(5),
  created_ts TIMESTAMP,
  updated_ts TIMESTAMP,
  activity_start_time TIMESTAMP,
  request_id NUMBER,
  activity_date DATE,
  cvc_id NUMBER
);