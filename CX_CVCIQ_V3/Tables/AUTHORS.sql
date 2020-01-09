CREATE TABLE cx_cvciq_v3.authors (
  authorid NUMBER NOT NULL,
  authorname VARCHAR2(100 BYTE),
  messageid NUMBER,
  CONSTRAINT authors_pk PRIMARY KEY (authorid),
  CONSTRAINT authors_fk1 FOREIGN KEY (messageid) REFERENCES cx_cvciq_v3.messages ("ID")
);