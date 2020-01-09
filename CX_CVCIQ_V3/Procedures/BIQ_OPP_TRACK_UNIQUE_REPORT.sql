CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_opp_track_unique_report (
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
            WHEN 'company'           THEN customer_name
            WHEN 'companycountry'    THEN country
            WHEN 'industry'          THEN industry
            WHEN 'briefingmanager'   THEN briefing_manager
            WHEN 'hostname'          THEN host_email
        END ) value
    FROM
        (SELECT
                        request_id,
                        startdate,
                        customer_name,
                        country,
                        industry,
                        customer_tier,
                        briefing_manager,
                        host_email,
                        opportunity_number,
                        opportunity_revenue,
                        closed_opportunity_revenue,
                        (   closed_opportunity_revenue - opportunity_revenue) changeinrevenuedollar,
                        CASE
                            WHEN to_number(opportunity_revenue) > 0 THEN ( TO_CHAR((nvl(closed_opportunity_revenue, 0) -(CASE
                                WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                                (opportunity_revenue, ',', '')
                                ELSE '0'
                            END)) * 100 /(CASE
                                WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                                (opportunity_revenue, ',', '')
                                ELSE '0'
                            END)) )
                            ELSE 'N/A'
                        END changeinrevenuepercent,
                        opened_date,
                        closed_date,
                        state
                    FROM
                        (
                            SELECT
                                r.id               request_id,
                                TO_CHAR(r.start_date, 'MM/DD/YYYY') startdate,
                                r.customer_name    customer_name,
                                r.country          country,
                                fn_code_to_lookup(r.industry, l_location_id, 'CUSTOMER_INDUSTRY') industry,
                                fn_code_to_lookup(r.customer_tier, l_location_id, 'TIER') customer_tier,
                                (
                                    SELECT
                                        d.user_name
                                    FROM
                                        bi_user d
                                    WHERE
                                        d.id = r.briefing_manager
                                ) briefing_manager,
                                r.host_email       host_email,
                                o.opportunity_id   opportunity_number,
                                CASE
                                    WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN
                                    replace(r.opportunity_revenue, ',', '')
                                    ELSE '0'
                                END opportunity_revenue,
                                nvl(r.closed_opportunity_revenue, 0) closed_opportunity_revenue,
                                TO_CHAR(r.opened_date, 'MM-DD-YYYY') opened_date,
                                TO_CHAR(r.closed_date, 'MM-DD-YYYY') closed_date,
                                NULL state
                            FROM
                                bi_request r
                                LEFT JOIN bi_request_opportunity o ON o.request_id = r.id
                            WHERE
                                r.state = 'CONFIRMED'
                                AND request_type_id = 1
                                AND r.start_date BETWEEN l_start_date AND l_end_date
                                AND r.location_id = (
                                    SELECT UNIQUE
                                        ( id )
                                    FROM
                                        bi_location
                                    WHERE
                                        unique_id = in_location
                                )
                            ORDER BY
                                r.start_date,
                                customer_name
                        )
        )
    WHERE
        CASE l_unique_column
            WHEN 'company'           THEN customer_name
            WHEN 'companycountry'    THEN country
            WHEN 'industry'          THEN industry
            WHEN 'briefingmanager'   THEN briefing_manager
            WHEN 'hostname'          THEN host_email
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