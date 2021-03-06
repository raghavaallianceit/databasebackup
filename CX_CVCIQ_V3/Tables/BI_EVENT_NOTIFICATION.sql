CREATE TABLE cx_cvciq_v3.bi_event_notification (
  "ID" NUMBER NOT NULL,
  target_state VARCHAR2(50 BYTE),
  template_detail_id NUMBER,
  request_type_id NUMBER,
  send_mode VARCHAR2(20 BYTE),
  unique_id VARCHAR2(20 BYTE),
  tenant_id NUMBER,
  "VERSION" NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active NUMBER,
  description VARCHAR2(256 BYTE),
  recipients VARCHAR2(4000 BYTE),
  location_id NUMBER,
  CONSTRAINT bi_event_notification_uk1 UNIQUE (request_type_id,target_state,location_id),
  CONSTRAINT bi_event_notification_fk2 FOREIGN KEY (template_detail_id) REFERENCES cx_cvciq_v3.bi_template_detail ("ID"),
  CONSTRAINT bi_event_notification_loc_fk FOREIGN KEY (location_id) REFERENCES cx_cvciq_v3.bi_location ("ID")
);