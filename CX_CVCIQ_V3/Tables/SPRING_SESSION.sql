CREATE TABLE cx_cvciq_v3.spring_session (
  session_id CHAR(36 BYTE) NOT NULL,
  last_access_time NUMBER(19) NOT NULL,
  principal_name VARCHAR2(100 CHAR),
  session_bytes BLOB,
  CONSTRAINT spring_session_pk PRIMARY KEY (session_id)
);