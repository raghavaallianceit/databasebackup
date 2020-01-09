CREATE TABLE cx_cvciq_v3.bi_user_contact (
  contact_type VARCHAR2(256 BYTE),
  "VALUE" VARCHAR2(256 BYTE),
  user_id NUMBER,
  CONSTRAINT bi_user_contact_userid_fk FOREIGN KEY (user_id) REFERENCES cx_cvciq_v3.bi_user ("ID")
);