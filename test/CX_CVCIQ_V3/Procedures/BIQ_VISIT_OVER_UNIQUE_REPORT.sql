CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_visit_over_unique_report (
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
            WHEN 'company'      THEN customer_name
            WHEN 'room'         THEN room
            WHEN 'host'         THEN host_email
            WHEN 'visitfocus'   THEN visit_focus
            WHEN 'industry'     THEN industry
            WHEN 'tier'         THEN customer_tier
        END ) value
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
        )
    WHERE
        CASE l_unique_column
            WHEN 'company'      THEN customer_name
            WHEN 'room'         THEN room
            WHEN 'host'         THEN host_email
            WHEN 'visitfocus'   THEN visit_focus
            WHEN 'industry'     THEN industry
            WHEN 'tier'         THEN customer_tier
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