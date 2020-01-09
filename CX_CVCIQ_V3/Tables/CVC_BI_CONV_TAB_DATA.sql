CREATE TABLE cx_cvciq_v3.cvc_bi_conv_tab_data (
  "ID" NUMBER NOT NULL,
  bi_conv_id VARCHAR2(20 BYTE) NOT NULL,
  src_table_id VARCHAR2(20 BYTE) NOT NULL,
  bi_parent_id VARCHAR2(30 BYTE),
  exec_seq NUMBER,
  process_flag VARCHAR2(20 BYTE),
  last_processed_at TIMESTAMP,
  fn_tab_validations VARCHAR2(25 BYTE),
  conv_reqd VARCHAR2(5 BYTE),
  trunc_table VARCHAR2(20 BYTE)
);