CREATE TABLE cx_cvciq_v3.cvc_bi_col_mapping (
  "ID" NUMBER NOT NULL,
  bi_conv_id VARCHAR2(20 BYTE),
  src_table_id VARCHAR2(20 BYTE),
  source_column VARCHAR2(255 BYTE),
  source_datatype VARCHAR2(255 BYTE),
  bi_column VARCHAR2(255 BYTE),
  bi_datatype VARCHAR2(255 BYTE),
  val_type VARCHAR2(20 BYTE),
  default_val VARCHAR2(4000 BYTE),
  fn_validations VARCHAR2(255 BYTE),
  utility_fn VARCHAR2(50 BYTE),
  additional_val VARCHAR2(50 BYTE),
  conv_reqd VARCHAR2(10 BYTE),
  unique_col VARCHAR2(5 BYTE)
);