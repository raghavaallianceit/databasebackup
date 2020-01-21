CREATE TABLE cx_cvciq_v3.bi_request_attendees (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  company VARCHAR2(256 BYTE),
  first_name VARCHAR2(256 BYTE),
  last_name VARCHAR2(256 BYTE),
  email VARCHAR2(256 BYTE),
  title VARCHAR2(256 BYTE),
  is_technical CHAR,
  is_decision_maker CHAR,
  is_influencer CHAR,
  designation VARCHAR2(4000 BYTE),
  request_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  is_remote CHAR,
  attendee_type VARCHAR2(30 BYTE),
  attendee_order NUMBER,
  corporate_title VARCHAR2(256 BYTE),
  is_translator CHAR,
  CONSTRAINT bi_request_attendees_pk PRIMARY KEY ("ID")
);