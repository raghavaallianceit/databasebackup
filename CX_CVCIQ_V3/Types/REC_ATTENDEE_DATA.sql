CREATE OR REPLACE TYPE cx_cvciq_v3.rec_attendee_data IS TABLE OF NUMBER;
      drop type  rec_attendee_data force;


      CREATE OR REPLACE TYPE out_attendee_rep_tab IS TABLE OF return_attendee_report;
/