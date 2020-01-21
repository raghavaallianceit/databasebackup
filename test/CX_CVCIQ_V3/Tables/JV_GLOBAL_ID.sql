CREATE TABLE cx_cvciq_v3.jv_global_id (
  global_id_pk NUMBER NOT NULL,
  local_id VARCHAR2(200 BYTE),
  fragment VARCHAR2(200 BYTE),
  type_name VARCHAR2(200 BYTE),
  owner_id_fk NUMBER,
  CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk),
  CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES cx_cvciq_v3.jv_global_id (global_id_pk)
);