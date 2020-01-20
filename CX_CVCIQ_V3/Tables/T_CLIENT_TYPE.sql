CREATE TABLE cx_cvciq_v3.t_client_type (
  "ID" NUMBER(11) NOT NULL,
  external_id VARCHAR2(128 BYTE),
  friendly_name VARCHAR2(256 BYTE),
  description VARCHAR2(512 BYTE),
  ra_session_time_out NUMBER(11),
  ra_session_max_time_out NUMBER(11),
  publish_status VARCHAR2(256 BYTE),
  "VERSION" NUMBER(11),
  download_url VARCHAR2(256 BYTE),
  price NUMBER(11),
  last_released_at DATE,
  client_size NUMBER(11),
  created_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  modified_at TIMESTAMP,
  modified_by VARCHAR2(256 BYTE),
  status VARCHAR2(256 BYTE),
  expiration_time NUMBER(11),
  client_secret VARCHAR2(256 BYTE),
  refresh_token_supported NUMBER(11),
  implicit_grant_supported NUMBER(11),
  auth_code_grant_supported NUMBER(11),
  api_method_check_required NUMBER(11),
  account_consent_type VARCHAR2(256 BYTE),
  password_grant_supported NUMBER(11),
  idx_token VARCHAR2(8 BYTE),
  credentials_supported NUMBER(11),
  client_credentials_grant_user VARCHAR2(256 BYTE) DEFAULT 'ADMIN',
  logo_url_1 VARCHAR2(256 BYTE),
  logo_url_2 VARCHAR2(256 BYTE),
  terms_and_conditions VARCHAR2(256 BYTE),
  CONSTRAINT t_client_type_pk PRIMARY KEY ("ID")
);