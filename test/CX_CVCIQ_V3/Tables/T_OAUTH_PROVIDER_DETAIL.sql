CREATE TABLE cx_cvciq_v3.t_oauth_provider_detail (
  "ID" NUMBER(11) NOT NULL,
  external_id VARCHAR2(256 BYTE),
  created_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  modified_at TIMESTAMP,
  modified_by VARCHAR2(256 BYTE),
  client_name VARCHAR2(256 BYTE),
  client_id VARCHAR2(256 BYTE),
  client_secret VARCHAR2(256 BYTE),
  authorize_url VARCHAR2(256 BYTE),
  access_token_url VARCHAR2(256 BYTE),
  redirect_url VARCHAR2(256 BYTE),
  provider_id NUMBER(11),
  revoke_token_url VARCHAR2(256 BYTE),
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT t_oauth_provider_detail_pk PRIMARY KEY ("ID"),
  CONSTRAINT oauth_provider_id_fk FOREIGN KEY (provider_id) REFERENCES cx_cvciq_v3.t_oauth_provider ("ID")
);