CREATE TABLE cx_cvciq_v3.t_oauth_refresh_token (
  "ID" NUMBER(11) NOT NULL,
  external_id VARCHAR2(128 BYTE),
  token VARCHAR2(256 BYTE),
  auth_code VARCHAR2(256 BYTE),
  account_id NUMBER(11),
  created_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  modified_at TIMESTAMP,
  modified_by VARCHAR2(256 BYTE),
  oauth_provider_id NUMBER(11),
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT t_oauth_refresh_token_pk PRIMARY KEY ("ID"),
  CONSTRAINT oauth_account_id FOREIGN KEY (account_id) REFERENCES cx_cvciq_v3.bi_user ("ID"),
  CONSTRAINT oauth_provider_details_id_fk FOREIGN KEY (oauth_provider_id) REFERENCES cx_cvciq_v3.t_oauth_provider_detail ("ID")
);