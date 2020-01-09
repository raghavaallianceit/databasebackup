CREATE TABLE cx_cvciq_v3.bi_notification_header (
  "ID" NUMBER,
  status_message VARCHAR2(256 BYTE),
  originator_id VARCHAR2(256 BYTE),
  originator_type VARCHAR2(256 BYTE),
  sender VARCHAR2(256 BYTE),
  sender_friendly VARCHAR2(256 BYTE),
  external_id VARCHAR2(256 BYTE),
  notification_data VARCHAR2(256 BYTE),
  status VARCHAR2(256 BYTE),
  insert_at TIMESTAMP,
  insert_by VARCHAR2(256 BYTE),
  update_at TIMESTAMP,
  update_by VARCHAR2(256 BYTE)
);