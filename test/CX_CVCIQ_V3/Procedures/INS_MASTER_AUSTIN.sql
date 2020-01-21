CREATE OR REPLACE PROCEDURE cx_cvciq_v3."INS_MASTER_AUSTIN" 
IS 

l_austin_locid NUMBER;
l_loc_exists VARCHAR2(250);

CURSOR get_lookup_data (l_lookupid_austin NUMBER)
IS
SELECT code,
       value,
       lookup_type_id,
       updated_by 
  FROM bi_lookup_value
WHERE is_active = 1 
  AND location_id <> l_lookupid_austin;  

CURSOR get_topic_data(l_topicid_austin NUMBER)
IS
SELECT name,
       description,
       topic_type_id       
  FROM bi_topic
 WHERE location_id <> l_topicid_austin;  

CURSOR get_presenter_data(l_presenterid_austin NUMBER)
IS
 SELECT  first_name,
        last_name,
        title,
        tenant_id,
        designation,
        primary_email,
        secondary_email
  FROM bi_presenter
 WHERE location_id <> l_presenterid_austin ;


BEGIN

  BEGIN
     SELECT id
       INTO l_austin_locid
       FROM bi_location
      WHERE unique_id = '1F0D80D1-D8FC-43F3-B833-6FF170DD41F8';	      
  EXCEPTION
   WHEN OTHERS
   THEN
     l_austin_locid:= 0;
  END;


     DBMS_OUTPUT.PUT_LINE ('l_austin_locid value : ' || l_austin_locid);


      IF l_austin_locid <> 0 
      THEN

           FOR rec_lookup_data IN get_lookup_data(l_austin_locid)
           LOOP

               BEGIN 
                  INSERT INTO bi_lookup_value
                     (  id,
                       unique_id,
                       code,
                       value,
                       is_active,
                       lookup_type_id,
                       version,
                       created_by, 
                       created_ts,
                       updated_by,
                       updated_ts,
                       location_id)
                     VALUES
                       (
                        bi_lookup_value_seq.nextval,
                        regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5') ,
                        rec_lookup_data.code,
                        rec_lookup_data.value,
                        1,
                        rec_lookup_data.lookup_type_id,
                        0,
                        'cvcinfo_us@briefingiq.com',
                        CURRENT_TIMESTAMP,
                        'cvcinfo_us@briefingiq.com',
                        CURRENT_TIMESTAMP,
                        l_austin_locid           
                       );
              EXCEPTION
                WHEN OTHERS
                THEN
                 DBMS_OUTPUT.PUT_LINE ('Error inserting value into bi_lookup_value  : ' || SQLERRM);                 
              END;   

          END LOOP;


          FOR rec_topic_data IN get_topic_data(l_austin_locid)
          LOOP

            BEGIN            
               INSERT INTO bi_topic
                   (id,
                    unique_id,
                    name,
                    description,
                    topic_type_id,
                    is_active,
                    created_Ts,
                    created_by,
                    updated_Ts,
                    updated_by,
                    version,
                    location_id)
                VALUES
                   (
                    bi_topic_seq.nextval,
                    regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5') ,
                    rec_topic_data.name,
                    rec_topic_data.description,
                    rec_topic_data.topic_type_id,
                    1,
                    CURRENT_TIMESTAMP,
                     'cvcinfo_us@briefingiq.com',
                    CURRENT_TIMESTAMP,
                    'cvcinfo_us@briefingiq.com',
                    0,
                    l_austin_locid           
                   );   
              EXCEPTION
                WHEN OTHERS
                THEN
                 DBMS_OUTPUT.PUT_LINE ('Error inserting value into bi_topic  : ' || SQLERRM);                 
              END;                   

          END LOOP;

          FOR rec_presenter_data IN get_presenter_data(l_austin_locid)
          LOOP

            BEGIN
               INSERT INTO bi_presenter
                   (
                    id,
                    unique_id,
                    first_name,
                    last_name,
                    title,
                    is_active,
                    tenant_id,
                    created_ts,
                    created_by,
                    updated_ts,
                    updated_by,
                    VERSION,
                    designation,
                    primary_email,
                    secondary_email,
                    location_id

                   )
                VALUES
                   (
                    bi_presenter_seq.nextval,
                    regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5') ,
                    rec_presenter_data.first_name,
                    rec_presenter_data.last_name,
                    rec_presenter_data.title,
                    1,
                    rec_presenter_data.tenant_id,
                    CURRENT_TIMESTAMP,
                     'cvcinfo_us@briefingiq.com',
                    CURRENT_TIMESTAMP,
                    'cvcinfo_us@briefingiq.com',
                    0,
                    rec_presenter_data.designation,
                    rec_presenter_data.primary_email,
                    rec_presenter_data.secondary_email,
                    l_austin_locid           
                   );    
              EXCEPTION
                WHEN OTHERS
                THEN
                 DBMS_OUTPUT.PUT_LINE ('Error inserting value into bi_presenter  : ' || SQLERRM);                 
              END;                  

          END LOOP;

          COMMIT;

   END IF;

   --Since there is no unique index on bi_presenter, restricting the duplcate inserts incase of multiple execution of the script.

   DELETE FROM bi_presenter A
    WHERE 
    location_id = l_austin_locid
    AND 
      a.rowid > 
       ANY (
         SELECT 
            B.rowid
         FROM 
            bi_presenter B
         WHERE location_id = l_austin_locid
         AND
            A.first_name = B.first_name
         AND 
            A.last_name = B.last_name
            );		


  COMMIT;


END;
/