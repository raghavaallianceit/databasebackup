CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_location_room ("ID",code,address,updated_date,updated_by,start_block_date,room_type,repository,"PRIVATE",order_by,created_date,created_by,"CAPACITY",assignable,"ACTIVE") AS
SELECT
ID,
CODE,
room_location||' '||room_location_1 address,
UPDATED_DATE,
UPDATED_BY,
START_BLOCK_DATE,
ROOM_TYPE,
REPOSITORY,
DECODE(private,'Y',1,NULL) PRIVATE,
ORDER_BY,
CREATED_DATE,
CREATED_BY,
CAPACITY,
DECODE(assignable,'Y',1,NULL) ASSIGNABLE,
ACTIVE
FROM cx_cvc.cvc_location_room where LOCATION_ID=80;