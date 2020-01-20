CREATE TABLE cx_cvciq_v3.t_client_type_api_method (
  "ID" NUMBER(11) NOT NULL,
  external_id VARCHAR2(128 BYTE),
  client_type_id NUMBER(11),
  api_method_id NUMBER(11),
  created_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  modified_at TIMESTAMP,
  modified_by VARCHAR2(256 BYTE),
  idx_token VARCHAR2(8 BYTE),
  CONSTRAINT t_client_type_api_pk PRIMARY KEY ("ID"),
  CONSTRAINT client_client_type_id FOREIGN KEY (client_type_id) REFERENCES cx_cvciq_v3.t_client_type ("ID"),
  CONSTRAINT ser_api_method_id FOREIGN KEY (api_method_id) REFERENCES cx_cvciq_v3.t_api_method ("ID")
);