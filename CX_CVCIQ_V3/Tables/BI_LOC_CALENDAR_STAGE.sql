CREATE TABLE cx_cvciq_v3.bi_loc_calendar_stage (
  "ID" NUMBER,
  unique_id VARCHAR2(250 BYTE),
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  location_id NUMBER,
  request_id NUMBER,
  additional_info VARCHAR2(4000 BYTE),
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  tenant_id NUMBER,
  "VERSION" NUMBER,
  is_active CHAR(256 BYTE),
  is_all_day_event VARCHAR2(20 BYTE),
  activity_id NUMBER
);