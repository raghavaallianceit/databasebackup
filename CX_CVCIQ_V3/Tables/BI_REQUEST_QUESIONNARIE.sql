CREATE TABLE cx_cvciq_v3.bi_request_quesionnarie (
  "ID" NUMBER NOT NULL,
  request_id NUMBER,
  request_type_questionnaire_id NUMBER,
  answer VARCHAR2(4000 BYTE),
  unique_id VARCHAR2(256 BYTE),
  tenant_id NUMBER,
  created_ts TIMESTAMP,
  created_by VARCHAR2(256 BYTE),
  updated_ts TIMESTAMP,
  updated_by VARCHAR2(256 BYTE),
  "VERSION" NUMBER,
  CONSTRAINT bi_request_quesionnarie_pk PRIMARY KEY ("ID"),
  CONSTRAINT bi_req_que_req_typ_que_id_fk FOREIGN KEY (request_type_questionnaire_id) REFERENCES cx_cvciq_v3.bi_request_type_questionnaire ("ID")
);