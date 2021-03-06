CREATE TABLE cx_cvciq_v3.t_table_column_map (
  "ID" NUMBER NOT NULL,
  src_table NUMBER,
  src_column VARCHAR2(256 BYTE),
  src_datatype VARCHAR2(256 BYTE),
  dest_table NUMBER,
  dest_column VARCHAR2(256 BYTE),
  dest_datatype VARCHAR2(256 BYTE),
  unique_combination NUMBER,
  src_fk_table VARCHAR2(256 BYTE),
  src_fk_column VARCHAR2(256 BYTE),
  default_value VARCHAR2(256 BYTE),
  seq_name VARCHAR2(256 BYTE),
  dest_fk_table VARCHAR2(256 BYTE),
  dest_fk_column VARCHAR2(256 BYTE),
  process_id NUMBER,
  fk_query VARCHAR2(1024 BYTE),
  exec_function VARCHAR2(256 BYTE),
  CONSTRAINT t_table_column_map_pk PRIMARY KEY ("ID")
);