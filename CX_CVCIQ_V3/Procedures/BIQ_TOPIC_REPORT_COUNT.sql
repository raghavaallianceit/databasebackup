CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_topic_report_count (
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
                        a.*,
                        concat(concat(p.first_name, ' '), p.last_name) presenter_name
                    FROM
                        (
                            SELECT
                                r.id              request_id,
                                a.id              request_activity_day_id,
                                TO_CHAR(a.event_date, 'MM/DD/YYYY') event_date,
                                a.event_date      eventdate,
                                r.customer_name   customer_name,
                                fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                                (
                                    SELECT
                                        u.user_name
                                    FROM
                                        bi_user u
                                    WHERE
                                        u.id = r.briefing_manager
                                ) briefing_manager,
                                r.host_email      host_email,
                                r.country         country,
                                CASE
                                    WHEN t.optional_topic IS NOT NULL THEN t.optional_topic
                                    ELSE t.topic
                                END topic,
                                t.id              topic_activity_id
--                        concat(concat(p.first_name, ' '), p.last_name) presenter_name
                            FROM
                                bi_request r,
                                bi_request_activity_day a,
                                bi_request_topic_activity t
--                        bi_request_presenter p
                            WHERE
                                r.state = 'CONFIRMED'
                                AND a.event_date BETWEEN l_start_date AND l_end_date
                                AND r.location_id = (
                                    SELECT UNIQUE
                                        ( id )
                                    FROM
                                        bi_location
                                    WHERE
                                        unique_id = l_location_id
                                )
                                AND r.id = a.request_id
                                AND t.request_activity_day_id = a.id
                        ) a
                        LEFT JOIN bi_request_presenter p ON p.bi_request_topic_activity_id = a.topic_activity_id
                                                            AND p.status = 'Accepted'
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/