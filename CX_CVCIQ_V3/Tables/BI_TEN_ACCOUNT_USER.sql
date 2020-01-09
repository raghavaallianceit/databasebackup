CREATE TABLE cx_cvciq_v3.bi_ten_account_user (
  tenant_account_id NUMBER,
  user_id NUMBER,
  role_id NUMBER,
  CONSTRAINT bi_ten_account_user_fk1 FOREIGN KEY (user_id) REFERENCES cx_cvciq_v3.bi_user ("ID")
);