CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_detailed_report_count (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_no_of_records   OUT                 NUMBER,
    in_from_date        IN                  VARCHAR2,
    in_to_date          IN                  VARCHAR2,
    in_sort_column      IN                  VARCHAR2,
    in_order_by         IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_no_of_records   NUMBER := 0;
    l_start_date      DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date        DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column     VARCHAR2(30) := lower(in_sort_column);
    l_order_by        VARCHAR2(10) := lower(in_order_by);
    l_location_id     VARCHAR2(256) := in_location;
BEGIN
    SELECT
        COUNT(*)
    INTO l_no_of_records
    FROM
        (
            SELECT
                        r.id               requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                        TO_DATE(d.event_date, 'dd-mm-yyyy') r_date,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = b.room
                        ) room,
                        b.room_type        r_type,
                        r.customer_name    company,
                        r.country          companycountry,
                        fn_code_to_lookup(r.industry, in_location, 'CUSTOMER_INDUSTRY') industry,
                        fn_code_to_lookup(r.customer_tier, in_location, 'TIER') tier,
                        fn_code_to_lookup(r.visit_type, in_location, CASE r.request_type_id
                            WHEN 1   THEN 'VISIT_TYPE'
                            WHEN 3   THEN 'NCV_VISIT_TYPE'
                        END) visittype,
                        fn_code_to_lookup(r.visit_focus, in_location, 'VISIT_FOCUS') visitfocus,
                        (
                            SELECT
                                u.user_name
                            FROM
                                bi_user u
                            WHERE
                                u.id = r.briefing_manager
                        ) briefingmanager,
                        r.host_email       host,
                        (
                            SELECT
                                u.user_name
                            FROM
                                bi_user u
                            WHERE
                                u.id = r.requestor
                        ) requestor,
                        p.opportunity_id   oppnumber,
                        CASE
                            WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                            (r.opportunity_revenue, ',', '')
                            ELSE '0'
                        END opprevenue,
                        a.first_name       first_name,
                        upper(a.first_name) upper_first_name,
                        a.last_name        last_name,
                        upper(a.last_name) upper_last_name,
                        a.designation      title,
                        DECODE(a.attendee_type, 'externalattendees', 'External', 'Internal') attendee_type,
                        r.cost_center      costcenter,
                        r.duration         duration
                    FROM
                        bi_request r
                        LEFT JOIN bi_request_attendees a ON a.request_id = r.id
                        LEFT JOIN bi_request_activity_day d ON d.request_id = r.id
                        LEFT JOIN bi_request_opportunity p ON p.request_id = r.id
                        LEFT JOIN bi_request_act_day_room b ON b.request_activity_day_id = d.id
                    WHERE
                        r.state = 'CONFIRMED'
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = in_location
                        )
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/