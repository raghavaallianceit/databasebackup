CREATE TABLE cx_cvciq_v3.bi_role_trans_notif (
  "ID" NUMBER(20) NOT NULL,
  unique_id VARCHAR2(256 BYTE),
  role_transition_id NUMBER(20),
  template_id NUMBER(20),
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP(3),
  updated_ts TIMESTAMP(3),
  "VERSION" NUMBER(6),
  auto_send NUMBER,
  request_type_id NUMBER,
  "METHOD" VARCHAR2(20 BYTE),
  recipients VARCHAR2(4000 BYTE),
  tenant_id NUMBER,
  is_active CHAR(256 BYTE)
);