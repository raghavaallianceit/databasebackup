CREATE OR REPLACE PROCEDURE cx_cvciq_v3.proc_report_revenue (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_tab             OUT                 return_revenue_arr,
    in_from_date        IN                  DATE,
    in_to_date          IN                  DATE,
    in_groupby_column   IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_chr_srcstage       VARCHAR2(200);
    l_chr_biqtab         VARCHAR2(200);
    l_chr_srctab         VARCHAR2(200);
    l_chr_bistagtab      VARCHAR2(200);
    l_chr_err_code       VARCHAR2(255);
    l_chr_err_msg        VARCHAR2(255);
    l_out_chr_errbuf     VARCHAR2(2000);
    lrec                 return_revenue_report;
    l_num_counter        NUMBER := 0;
    l_start_date         DATE := in_from_date;
    l_end_date           DATE := in_to_date + 1;
    l_groupby_column     VARCHAR2(30) := upper(in_groupby_column);
    l_location_id        VARCHAR2(256) := in_location;
    CURSOR cur_groupby_data IS
    SELECT
        noofrecords,
        groupbycolumn,
        opportunityrevenue,
        to_number(nvl(sort_order, 0))
    FROM
        (
            SELECT
                COUNT(*) noofrecords,
                CASE l_groupby_column
                    WHEN 'CUSTOMER_TIER'   THEN 'Others'
                END groupbycolumn,
                nvl(SUM(CASE
                    WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(opportunity_revenue
                    , ',', '')
                    ELSE '0'
                END), 0) opportunityrevenue,
                '999' sort_order
            FROM
                bi_request
            WHERE
                location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND CASE l_groupby_column
                    WHEN 'CUSTOMER_TIER'   THEN customer_tier
                END IS NULL
                AND CASE l_groupby_column
                    WHEN 'CUSTOMER_TIER'   THEN 1
                    ELSE 0
                END = 1
            UNION
            SELECT
                noofrecords,
                fn_code_to_lookup(groupbycolumn, in_location, CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                    WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                    WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                    WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                END) groupbycolumn,
                opportunityrevenue,
                fn_lookup_sort_order(groupbycolumn, in_location, CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                    WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                    WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                    WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                END) sort_order
            FROM
                (
                    SELECT
                        COUNT(*) noofrecords,
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END groupbycolumn,
                        nvl(SUM(CASE
                            WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                            (opportunity_revenue, ',', '')
                            ELSE '0'
                        END), 0) opportunityrevenue
                    FROM
                        bi_request
                    WHERE
                        location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND start_date BETWEEN l_start_date AND l_end_date
                        AND state = 'CONFIRMED'
                        AND request_type_id = 1
                        AND CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END IS NOT NULL
                    GROUP BY
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END
                )
            UNION
            SELECT
                0 noofrecords,
                fn_code_to_lookup(code, in_location, CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                    WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                    WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                    WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                END) groupbycolumn,
                0 opportunityrevenue,
                fn_lookup_sort_order(code, in_location, CASE l_groupby_column
                    WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                    WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                    WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                    WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                END) sort_order
            FROM
                bi_lookup_value
            WHERE
                location_id = 4300
                AND lookup_type_id = (
                    SELECT
                        id
                    FROM
                        bi_lookup_type
                    WHERE
                        code = CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN 'VISIT_FOCUS'
                            WHEN 'CUSTOMER_TIER'   THEN 'TIER'
                            WHEN 'INDUSTRY'        THEN 'CUSTOMER_INDUSTRY'
                            WHEN 'VISIT_TYPE'      THEN 'VISIT_TYPE'
                        END
                )
                AND code NOT IN (
                    SELECT
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END groupbycolumn
                    FROM
                        bi_request
                    WHERE
                        location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND start_date BETWEEN l_start_date AND l_end_date
                        AND state = 'CONFIRMED'
                        AND request_type_id = 1
                        AND CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END IS NOT NULL
                    GROUP BY
                        CASE l_groupby_column
                            WHEN 'VISIT_FOCUS'     THEN visit_focus
                            WHEN 'CUSTOMER_TIER'   THEN customer_tier
                            WHEN 'INDUSTRY'        THEN industry
                            WHEN 'VISIT_TYPE'      THEN visit_type
                        END
                )
            UNION
            SELECT
                COUNT(*) noofrecords,
                (
                    SELECT
                        concat(concat(first_name, ' '), last_name)
                    FROM
                        bi_user
                    WHERE
                        id = briefing_manager
                ) groupbycolumn,
                nvl(SUM(CASE
                    WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(opportunity_revenue
                    , ',', '')
                    ELSE '0'
                END), 0) opportunityrevenue,
                TO_CHAR(ROW_NUMBER() OVER(
                    ORDER BY
                        (
                            SELECT
                                concat(first_name, last_name)
                            FROM
                                bi_user
                            WHERE
                                id = briefing_manager
                        )
                )) sort_order
            FROM
                bi_request
            WHERE
                briefing_manager IS NOT NULL
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND CASE l_groupby_column
                    WHEN 'BRIEFING_MANAGER'   THEN 1
                    ELSE 0
                END = 1
            GROUP BY
                briefing_manager
        )
    ORDER BY
        sort_order,
        groupbycolumn;

    TYPE rec_groupby_data IS
        TABLE OF cur_groupby_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_groupby_data   rec_groupby_data;
BEGIN
    out_tab := return_revenue_arr();
    OPEN cur_groupby_data;
--    dbms_output.put_line('l_groupby_column :-' || l_groupby_column);
    LOOP
        FETCH cur_groupby_data BULK COLLECT INTO l_cur_groupby_data;
        EXIT WHEN l_cur_groupby_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_revenue_report();
        out_tab := return_revenue_arr(return_revenue_report());
        out_tab.DELETE;
        FOR i IN 1..l_cur_groupby_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_revenue_report();
                lrec.noofrecords := l_cur_groupby_data(i).noofrecords;
                lrec.param := l_cur_groupby_data(i).groupbycolumn;
                lrec.revenue := l_cur_groupby_data(i).opportunityrevenue;
--                dbms_output.put_line('opportunityrevenue :-' || l_cur_groupby_data(i).opportunityrevenue);
                IF l_num_counter > 1 THEN
                    out_tab.extend();
                    out_tab(l_num_counter) := return_revenue_report();
                ELSE
                    out_tab := return_revenue_arr(return_revenue_report());
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