CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.v_visit_type ("COUNT","VALUE",viewtype) AS
SELECT
        COUNT(*) count,
        visit_type   AS value,
        'visit_type' viewType
    FROM
        bi_request
    WHERE
        visit_type is not null
    GROUP BY
        visit_type;