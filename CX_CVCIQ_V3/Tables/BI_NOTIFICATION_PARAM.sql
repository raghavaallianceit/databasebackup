CREATE TABLE cx_cvciq_v3.bi_notification_param (
  "ID" NUMBER,
  sender_email_address VARCHAR2(256 BYTE),
  sender_friendly_name VARCHAR2(256 BYTE),
  external_id VARCHAR2(256 BYTE),
  template_id VARCHAR2(256 BYTE),
  insert_at TIMESTAMP,
  insert_by VARCHAR2(256 BYTE),
  update_at TIMESTAMP,
  update_by VARCHAR2(256 BYTE)
);