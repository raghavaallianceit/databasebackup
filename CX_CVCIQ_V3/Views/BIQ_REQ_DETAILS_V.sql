CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.biq_req_details_v (start_date,request_type_id,"STATE",location_id,customer_name,customer_tier,opportunity_revenue,opportunity_id,briefing_manager,visit_focus,expected_no_of_ext_attendees) AS
SELECT a.start_date,
       a.REQUEST_TYPE_ID,
       a.STATE,
       a.LOCATION_ID,
      a.customer_name,
      a.customer_tier,
      a.opportunity_revenue,
      (SELECT LISTAGG(b.opportunity_id,',') WITHIN GROUP (ORDER BY b.request_id) cnt
         FROM bi_request_opportunity b
        WHERE a.id = b.request_id) opportunity_id,
      a.briefing_manager,
      a.visit_focus,
      a.expected_no_of_ext_attendees
 FROM bi_Request a;