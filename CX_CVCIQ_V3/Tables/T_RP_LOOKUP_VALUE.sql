CREATE TABLE cx_cvciq_v3.t_rp_lookup_value (
  "ID" NUMBER NOT NULL,
  unique_id VARCHAR2(256 BYTE) NOT NULL,
  code VARCHAR2(256 BYTE),
  "VALUE" VARCHAR2(256 BYTE),
  lookup_type_id NUMBER NOT NULL,
  active_from TIMESTAMP,
  active_to TIMESTAMP,
  created_by VARCHAR2(256 BYTE) NOT NULL,
  updated_by VARCHAR2(256 BYTE) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  "VERSION" NUMBER,
  sort_order NUMBER,
  is_default NUMBER(1) DEFAULT 0,
  CONSTRAINT "t_rp_lookup_value_pkey" PRIMARY KEY ("ID"),
  CONSTRAINT "fk_lookup_type_id" FOREIGN KEY (lookup_type_id) REFERENCES cx_cvciq_v3.t_rp_lookup_type ("ID")
);