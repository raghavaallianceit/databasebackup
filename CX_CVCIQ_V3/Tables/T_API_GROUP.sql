CREATE TABLE cx_cvciq_v3.t_api_group (
  "ID" NUMBER(11) NOT NULL,
  unique_id VARCHAR2(128 BYTE),
  friendly_name VARCHAR2(256 BYTE),
  description VARCHAR2(512 BYTE),
  authorization_msg VARCHAR2(256 BYTE),
  group_sequence NUMBER(11),
  consent_message_id NUMBER(11),
  detailed_consent_message_id NUMBER(11),
  created_ts TIMESTAMP NOT NULL,
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_ts TIMESTAMP NOT NULL,
  updated_by TIMESTAMP NOT NULL,
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT t_api_group_pk PRIMARY KEY ("ID")
);