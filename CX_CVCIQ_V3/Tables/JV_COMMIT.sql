CREATE TABLE cx_cvciq_v3.jv_commit (
  commit_pk NUMBER NOT NULL,
  author VARCHAR2(200 BYTE),
  commit_date TIMESTAMP,
  commit_id NUMBER(22,2),
  CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk)
);