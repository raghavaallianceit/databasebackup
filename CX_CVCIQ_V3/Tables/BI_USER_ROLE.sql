CREATE TABLE cx_cvciq_v3.bi_user_role (
  user_id NUMBER,
  role_id NUMBER,
  CONSTRAINT bi_user_role_roleid_fk FOREIGN KEY (role_id) REFERENCES cx_cvciq_v3.bi_role ("ID"),
  CONSTRAINT bi_user_role_userid_fk FOREIGN KEY (user_id) REFERENCES cx_cvciq_v3.bi_user ("ID")
);