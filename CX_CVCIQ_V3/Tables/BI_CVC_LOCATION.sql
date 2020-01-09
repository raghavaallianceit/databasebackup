CREATE TABLE cx_cvciq_v3.bi_cvc_location (
  "ID" NUMBER(15),
  "NAME" VARCHAR2(80 CHAR),
  address VARCHAR2(120 CHAR),
  "STATE" VARCHAR2(100 CHAR),
  city VARCHAR2(100 CHAR),
  country VARCHAR2(100 CHAR),
  timezone VARCHAR2(60 CHAR),
  loc_type VARCHAR2(80 CHAR),
  technical_setup VARCHAR2(5 CHAR),
  created_by VARCHAR2(80 CHAR) NOT NULL,
  created_date DATE NOT NULL,
  updated_by VARCHAR2(80 CHAR),
  updated_date DATE,
  req_can_be_ac VARCHAR2(5 CHAR),
  req_can_book_rooms VARCHAR2(5 CHAR),
  used_in_edr VARCHAR2(5 CHAR),
  time_from DATE,
  time_to DATE,
  contact_us VARCHAR2(500 CHAR),
  room_setup VARCHAR2(5 BYTE),
  "ORGANIZATION" VARCHAR2(5 BYTE),
  hotel VARCHAR2(5 CHAR),
  transportation VARCHAR2(5 CHAR),
  catering VARCHAR2(5 CHAR),
  special_days VARCHAR2(5 CHAR),
  sunday VARCHAR2(5 CHAR),
  saturday VARCHAR2(5 CHAR),
  self_service VARCHAR2(5 CHAR),
  email_from VARCHAR2(255 CHAR),
  agenda_display VARCHAR2(3 CHAR),
  request_time NUMBER,
  "HYBRID" VARCHAR2(5 CHAR),
  code VARCHAR2(20 BYTE),
  "CAPACITY" NUMBER(3),
  room_type VARCHAR2(80 CHAR),
  assignable VARCHAR2(5 CHAR),
  location_id NUMBER,
  room_location VARCHAR2(200 CHAR),
  room_location_1 VARCHAR2(200 CHAR),
  repository VARCHAR2(1000 CHAR),
  "PRIVATE" VARCHAR2(5 CHAR),
  additional_info VARCHAR2(1000 CHAR),
  process_flag VARCHAR2(5 CHAR)
);