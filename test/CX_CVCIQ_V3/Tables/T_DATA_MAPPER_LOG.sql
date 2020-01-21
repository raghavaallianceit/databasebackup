CREATE TABLE cx_cvciq_v3.t_data_mapper_log (
  "ID" NUMBER NOT NULL,
  request_id NUMBER,
  message VARCHAR2(1024 BYTE),
  date_time TIMESTAMP,
  status NUMBER DEFAULT 1,
  CONSTRAINT t_data_mapper_log_pk PRIMARY KEY ("ID")
);