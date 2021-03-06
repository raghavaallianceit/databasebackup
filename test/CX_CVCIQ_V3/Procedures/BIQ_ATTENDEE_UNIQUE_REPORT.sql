CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_attendee_unique_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_tab            OUT                return_unique_arr,
    in_from_date       IN                 VARCHAR2,
    in_to_date         IN                 VARCHAR2,
    in_unique_column   IN                 VARCHAR2,
    in_location        IN                 VARCHAR2
) IS

    l_chr_srcstage     VARCHAR2(200);
    l_chr_biqtab       VARCHAR2(200);
    l_chr_srctab       VARCHAR2(200);
    l_chr_bistagtab    VARCHAR2(200);
    l_chr_err_code     VARCHAR2(255);
    l_chr_err_msg      VARCHAR2(255);
    l_out_chr_errbuf   VARCHAR2(2000);
    lrec               return_unique_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date         DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_unique_column    VARCHAR2(30) := lower(in_unique_column);
    l_location_id      VARCHAR2(256) := in_location;
    CURSOR cursor_data IS
    SELECT UNIQUE
        ( CASE l_unique_column
--            WHEN 'visitdate'        THEN visitdate
            WHEN 'room'             THEN room
            WHEN 'company'          THEN customer_name
            WHEN 'companycountry'   THEN country
            WHEN 'attendeetype'     THEN attendee_type
        END ) value
    FROM
        (
            SELECT
                r.id              request_id,
                TO_CHAR(a.event_date, 'MM/DD/YYYY') startdate,
                (
                    SELECT
                        name
                    FROM
                        bi_location
                    WHERE
                        id = d.room
                ) room,
                r.customer_name   customer_name,
                r.country         country,
                r.duration        duration,
                r.customer_name   ext_att_customer_company,
                c.first_name      ext_att_first_name,
                c.last_name       ext_att_last_name,
                c.designation     ext_att_title,
                CASE
                    WHEN c.attendee_type = 'externalattendees' THEN DECODE(c.is_decision_maker, 1, 'Y', 'N')
                    ELSE 'N/A'
                END ext_att_is_decision_maker,
                CASE
                    WHEN c.attendee_type = 'externalattendees' THEN DECODE(c.is_technical, 1, 'Y', 'N')
                    ELSE 'N/A'
                END is_technical,
                DECODE(c.attendee_type, 'externalattendees', 'External', 'Internal') attendee_type
            FROM
                bi_request r
                LEFT JOIN bi_request_activity_day a ON a.request_id = r.id
                LEFT JOIN bi_request_attendees c ON c.request_id = r.id
                LEFT JOIN bi_request_act_day_room d ON d.request_activity_day_id = a.id
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
                AND d.room_type = 'MAIN_ROOM'
        )
    WHERE
        CASE l_unique_column
--            WHEN 'visitdate'        THEN visitdate
            WHEN 'room'             THEN room
            WHEN 'company'          THEN customer_name
            WHEN 'companycountry'   THEN country
            WHEN 'attendeetype'     THEN attendee_type
        END IS NOT NULL
    ORDER BY
        value;

    TYPE rec_attendee_data IS
        TABLE OF cursor_data%rowtype INDEX BY PLS_INTEGER;
    l_cursor_data      rec_attendee_data;
BEGIN
    out_tab := return_unique_arr();
    OPEN cursor_data;
    LOOP
        FETCH cursor_data BULK COLLECT INTO l_cursor_data;
        EXIT WHEN l_cursor_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_unique_report();
        out_tab := return_unique_arr(return_unique_report());
        out_tab.DELETE;
        FOR i IN 1..l_cursor_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_unique_report();
                lrec.value := l_cursor_data(i).value;
                IF l_num_counter > 1 THEN
                    out_tab.extend();
                    out_tab(l_num_counter) := return_unique_report();
                ELSE
                    out_tab := return_unique_arr(return_unique_report());
                END IF;

                out_tab(l_num_counter) := lrec;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error occurred : ' || sqlerrm);
            END;
        END LOOP;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/