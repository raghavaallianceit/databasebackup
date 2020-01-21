CREATE TABLE cx_cvciq_v3.bi_tenant_account_tags (
  tenant_account_id NUMBER,
  tags VARCHAR2(256 BYTE),
  CONSTRAINT bi_tenant_account_tags_taid_fk FOREIGN KEY (tenant_account_id) REFERENCES cx_cvciq_v3.bi_tenant_account ("ID")
);