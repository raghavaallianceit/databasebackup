CREATE GLOBAL TEMPORARY TABLE cx_cvciq_v3.bidoc_glob_temp (
  "ID" NUMBER NOT NULL,
  document_name VARCHAR2(256 BYTE),
  document_content_type VARCHAR2(256 BYTE),
  document_size NUMBER,
  "DOCUMENT" BLOB,
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_by VARCHAR2(256 BYTE),
  created_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  is_active CHAR(256 BYTE),
  "VERSION" NUMBER,
  request_id NUMBER,
  document_type VARCHAR2(20 BYTE)
)
ON COMMIT PRESERVE ROWS;