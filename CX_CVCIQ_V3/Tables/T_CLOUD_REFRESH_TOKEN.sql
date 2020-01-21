CREATE TABLE cx_cvciq_v3.t_cloud_refresh_token (
  "ID" NUMBER(11) NOT NULL,
  external_id VARCHAR2(128 BYTE),
  token VARCHAR2(256 BYTE),
  auth_code VARCHAR2(256 BYTE),
  account_id NUMBER(11),
  client_type_id NUMBER(11),
  created_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  modified_at TIMESTAMP,
  modified_by VARCHAR2(256 BYTE),
  idx_token VARCHAR2(8 BYTE),
  device_id NUMBER(11),
  CONSTRAINT t_cloud_refresh_token_pk PRIMARY KEY ("ID"),
  CONSTRAINT refresh_account_id FOREIGN KEY (account_id) REFERENCES cx_cvciq_v3.bi_user ("ID"),
  CONSTRAINT reresh_client_type_id FOREIGN KEY (client_type_id) REFERENCES cx_cvciq_v3.t_client_type ("ID")
);