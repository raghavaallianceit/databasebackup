CREATE TABLE cx_cvciq_v3.bi_state_notification (
  "ID" NUMBER NOT NULL,
  state_id NUMBER,
  recipient_expr VARCHAR2(256 BYTE),
  template_external_id VARCHAR2(256 BYTE),
  active_from DATE,
  active_to DATE,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_state_notification_pk PRIMARY KEY ("ID")
);