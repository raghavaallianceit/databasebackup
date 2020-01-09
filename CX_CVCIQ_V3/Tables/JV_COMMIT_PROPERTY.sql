CREATE TABLE cx_cvciq_v3.jv_commit_property (
  property_name VARCHAR2(200 BYTE) NOT NULL,
  property_value VARCHAR2(600 BYTE),
  commit_fk NUMBER NOT NULL,
  CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk,property_name),
  CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES cx_cvciq_v3.jv_commit (commit_pk)
);