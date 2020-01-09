CREATE TABLE cx_cvciq_v3.t_dest_table (
  "ID" NUMBER NOT NULL,
  table_name VARCHAR2(256 BYTE),
  pk_seq_name VARCHAR2(256 BYTE),
  pk_column VARCHAR2(20 BYTE),
  CONSTRAINT t_dest_table_pk PRIMARY KEY ("ID")
);