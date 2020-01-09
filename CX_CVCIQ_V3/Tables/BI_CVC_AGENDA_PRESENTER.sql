CREATE TABLE cx_cvciq_v3.bi_cvc_agenda_presenter (
  "ID" NUMBER,
  topic_id NUMBER,
  "TYPE" VARCHAR2(255 BYTE),
  first_name VARCHAR2(255 BYTE),
  last_name VARCHAR2(255 BYTE),
  primary_email VARCHAR2(500 BYTE),
  secondary_email VARCHAR2(500 BYTE),
  presenter_status VARCHAR2(255 BYTE),
  suggested_presenter_title VARCHAR2(4000 BYTE),
  request_activity_day_id NUMBER,
  topic VARCHAR2(500 BYTE),
  topic_activity_id NUMBER,
  created_by VARCHAR2(255 BYTE),
  updated_by VARCHAR2(255 BYTE)
);