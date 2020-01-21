CREATE TABLE cx_cvciq_v3.bi_api_method_acl (
  "ID" NUMBER NOT NULL,
  api_method_id NUMBER,
  role_id NUMBER,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER
);