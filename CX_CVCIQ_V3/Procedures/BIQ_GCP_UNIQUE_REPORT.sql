CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_gcp_unique_report (
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
            WHEN 'visitfocus'        THEN visit_focus
            WHEN 'company'           THEN company
            WHEN 'companycountry'    THEN country
            WHEN 'briefingmanager'   THEN briefing_manager
            WHEN 'host'              THEN host_email
        END ) value
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
        )
    WHERE
        CASE l_unique_column
            WHEN 'visitfocus'        THEN visit_focus
            WHEN 'company'           THEN company
            WHEN 'companycountry'    THEN country
            WHEN 'briefingmanager'   THEN briefing_manager
            WHEN 'host'              THEN host_email
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