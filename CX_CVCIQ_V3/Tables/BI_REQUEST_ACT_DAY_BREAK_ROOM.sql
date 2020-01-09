CREATE TABLE cx_cvciq_v3.bi_request_act_day_break_room (
  request_activity_day_id NUMBER NOT NULL,
  break_rooms NUMBER,
  CONSTRAINT bi_radbr_brk_room_id_fk FOREIGN KEY (break_rooms) REFERENCES cx_cvciq_v3.bi_location ("ID")
);