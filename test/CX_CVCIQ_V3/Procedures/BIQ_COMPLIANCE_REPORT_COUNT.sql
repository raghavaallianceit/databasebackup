CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_compliance_report_count (
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
                r.id                    requestid,
                TO_CHAR(d.event_date, 'MM/DD/YYYY') event_date,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = c.room
                ) room,
                r.customer_name         company,
                r.country               companycountry,
                r.duration              duration,
                (
                    SELECT
                        u.user_name
                    FROM
                        bi_user u
                    WHERE
                        u.id = r.briefing_manager
                ) briefingmanager,
                r.host_email            host,
                DECODE(r.is_compliant, 1, 'Yes', 'No') compliance,
                nvl(r.no_of_gifts, 0) giftcount,
                r.gift_type             gifttype,
                c.catering_type         cateringtype,
                c.notes                 notes,
                a.company               custcompanyname,
                a.first_name            extfirstname,
                a.first_name            upper_extfirstname,
                a.last_name             extlastname,
                a.last_name             upper_extlastname,
                a.designation           exttitle,
                c.activity_start_time   activity_start_time,
                c.id                    cateringactivityid
            FROM
                bi_request r
                LEFT JOIN bi_request_attendees a ON a.request_id = r.id
                                                    AND a.attendee_type = 'externalattendees'
                JOIN bi_request_activity_day d ON d.request_id = r.id
                LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = d.id
            WHERE
                r.state = 'CONFIRMED'
                AND d.event_date BETWEEN l_start_date AND l_end_date
                AND r.location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
        );

    out_no_of_records := l_no_of_records;
--         dbms_output.put_line('l_no_of_records :-'||l_no_of_records);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/