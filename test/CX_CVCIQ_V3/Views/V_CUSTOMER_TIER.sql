CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.v_customer_tier ("COUNT","VALUE",viewtype) AS
SELECT
        COUNT(*) count,
        CONCAT('Tier ',customer_tier) value,
         'customer_tier' viewType
    FROM
        bi_request
    WHERE
        customer_tier is not null
    GROUP BY
        customer_tier;