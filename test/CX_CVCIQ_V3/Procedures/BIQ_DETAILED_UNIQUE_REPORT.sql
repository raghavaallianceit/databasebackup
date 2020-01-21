CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_detailed_unique_report (
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
            WHEN 'room'              THEN room
            WHEN 'visitfocus'        THEN visitfocus
            WHEN 'visittype'         THEN visittype
            WHEN 'company'           THEN company
            WHEN 'companycountry'    THEN companycountry
            WHEN 'industry'          THEN industry
            WHEN 'tier'              THEN tier
            WHEN 'briefingmanager'   THEN briefingmanager
            WHEN 'host'              THEN host
            WHEN 'attendeetype'      THEN attendee_type
        END ) value
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
                    WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(r.opportunity_revenue
                    , ',', '')
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
        )
    WHERE
        CASE l_unique_column
            WHEN 'room'              THEN room
            WHEN 'visitfocus'        THEN visitfocus
            WHEN 'visittype'         THEN visittype
            WHEN 'company'           THEN company
            WHEN 'companycountry'    THEN companycountry
            WHEN 'industry'          THEN industry
            WHEN 'tier'              THEN tier
            WHEN 'briefingmanager'   THEN briefingmanager
            WHEN 'host'              THEN host
            WHEN 'attendeetype'      THEN attendee_type
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