CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_visit_overview_count (
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
            SELECT DISTINCT
                r.id                    request_id,
                TO_CHAR(b.event_date, 'MM/DD/YYYY') startdate,
                r.start_date            start_date,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = c.room
                ) room,
                r.customer_name         customer_name,
                fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                fn_code_to_lookup(r.industry, l_location_id, 'CUSTOMER_INDUSTRY') industry,
                fn_code_to_lookup(r.customer_tier, l_location_id, 'TIER') customer_tier,
                r.host_email            host_email,
                r.opportunity_revenue   opportunity_revenue,
                r.visit_objective       meeting_objective,
                r.sensitive_issues      sensitive_issues,
                r.business_case         business_case
            FROM
                bi_request r
                LEFT JOIN bi_request_activity_day b ON b.request_id = r.id
                LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = b.id
                LEFT JOIN bi_request_act_day_room rm ON b.id = rm.request_activity_day_id
                                                        AND c.room = rm.room
            WHERE
                r.state = 'CONFIRMED'
                AND request_type_id = 1
                AND b.event_date BETWEEN l_start_date AND l_end_date
                AND r.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = in_location
                )
                AND rm.room_type = 'MAIN_ROOM'
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/