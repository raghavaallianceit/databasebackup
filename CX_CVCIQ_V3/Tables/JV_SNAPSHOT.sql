CREATE TABLE cx_cvciq_v3.jv_snapshot (
  snapshot_pk NUMBER NOT NULL,
  "TYPE" VARCHAR2(200 BYTE),
  "VERSION" NUMBER,
  "STATE" CLOB,
  changed_properties CLOB,
  managed_type VARCHAR2(200 BYTE),
  global_id_fk NUMBER,
  commit_fk NUMBER,
  CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk),
  CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES cx_cvciq_v3.jv_commit (commit_pk),
  CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES cx_cvciq_v3.jv_global_id (global_id_pk)
);