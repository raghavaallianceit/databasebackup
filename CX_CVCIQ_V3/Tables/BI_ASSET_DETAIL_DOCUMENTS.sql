CREATE TABLE cx_cvciq_v3.bi_asset_detail_documents (
  "ID" NUMBER NOT NULL,
  document_name VARCHAR2(256 BYTE),
  document_content_type VARCHAR2(256 BYTE),
  document_size NUMBER,
  asset_detail_id NUMBER,
  document_type VARCHAR2(20 BYTE),
  "DOCUMENT" BLOB,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active CHAR(256 BYTE),
  "VERSION" NUMBER
);