CREATE TABLE cx_cvciq_v3.t_data_map_process_details (
  "ID" NUMBER NOT NULL,
  process_id NUMBER,
  src_table_id NUMBER,
  process_order NUMBER,
  dest_table_id VARCHAR2(20 BYTE),
  process_query VARCHAR2(256 BYTE),
  CONSTRAINT t_data_map_process_details_pk PRIMARY KEY ("ID")
);