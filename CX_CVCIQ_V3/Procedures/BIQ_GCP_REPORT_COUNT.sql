CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_gcp_report_count (
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
                        r.id              requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                        r.customer_name   company,
                        r.country         country,
                        fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = r.briefing_manager
                        ) briefing_manager,
                        r.host_email      host_email,
                        a.first_name      first_name,
                        a.last_name       last_name,
                        a.designation     title
                    FROM
                        bi_request r
                        LEFT OUTER JOIN bi_request_activity_day d ON r.id = d.request_id
                        LEFT OUTER JOIN bi_request_attendees a ON a.request_id = r.id
                                                                  AND a.attendee_type = 'externalattendees'
                    WHERE
                        r.state = 'CONFIRMED'
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND request_type_id = 1
                        AND d.event_date BETWEEN l_start_date AND l_end_date
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/