CREATE TABLE cx_cvciq_v3.cvc_request_process (
  request_id NUMBER(15) NOT NULL,
  company_name VARCHAR2(100 CHAR),
  event_start_date DATE,
  host_name VARCHAR2(80 CHAR),
  country VARCHAR2(100 CHAR),
  "LOCATION" VARCHAR2(80 CHAR),
  status VARCHAR2(80 CHAR),
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  bi_request_id NUMBER(15),
  cvc_status VARCHAR2(64 BYTE),
  ac_id VARCHAR2(250 BYTE),
  CONSTRAINT cvc_request_process_pk PRIMARY KEY (request_id)
);