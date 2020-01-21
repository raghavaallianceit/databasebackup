CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3.biq_setup_newloc 
AS

PROCEDURE biq_create_new_loc (
    copyFromLocationId IN NUMBER,
    toLocationId       IN NUMBER ,
    out_chr_errbuf    OUT VARCHAR2,
    out_chr_err_code  OUT VARCHAR2,
    out_chr_err_msg   OUT VARCHAR2 )
IS

  l_out_chr_errbuf LONG;
  l_chr_err_code VARCHAR2(2000);
  l_chr_err_msg  VARCHAR2(2000);

BEGIN

  BEGIN

    biq_delete_data(toLocationId);

    INSERT
     INTO BI_LOCATION_PARAMETER
      (
        id,
        unique_id,
        location_id,
        param_name,
        param_display_text,
        param_value,
        param_description ,
        param_type,
        param_validation,
        param_display_type ,
		version,
        created_by,
        updated_by,
        created_ts,
        updated_ts
      )
    SELECT BI_LOCATION_PARAMETER_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      toLocationId,
      param_name,
      param_display_text,
      param_value,
      param_description ,
      param_type,
      param_validation,
      param_display_type ,
	  0,
      created_by,
      updated_by ,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    FROM BI_LOCATION_PARAMETER
    WHERE location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := 'Error inserting into BI_LOCATION_PARAMETER -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_ASSET_DETAIL
      (
        id,
        unique_id,
        asset_master_id,
        active_from,
        active_to,
        is_active,
        version ,
        name,
        description,
        location_id,
        created_by,
        updated_by,
        created_ts,
        updated_ts
      )
    SELECT BI_ASSET_DETAIL_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      asset_master_id,
      active_from,
      active_to,
      is_active,
      99999999,
      name,
      description,
      toLocationId,
      created_by,
      updated_by,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP  
    FROM BI_ASSET_DETAIL
    WHERE location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_ASSET_DETAIL -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_ASSET_DETAIL_DOCUMENTS
      (
        id,
        unique_id,
        document_name,
        document_content_type,
        document_size,
        asset_detail_id ,
        document_type,
        document,
        is_active,
        version,
        created_by,
        updated_by,
        created_ts,
        updated_ts
      )
    SELECT BI_ASSET_DETAIL_DOCUMENTS_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      document_name,
      document_content_type,
      document_size,
      (SELECT id
      FROM BI_ASSET_DETAIL
      WHERE version = 99999999
      ) ,
      document_type,
      document,
      is_active,
      0,
      created_by,
      updated_by ,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    FROM BI_ASSET_DETAIL_DOCUMENTS
    WHERE asset_detail_id IN
      (SELECT id FROM BI_ASSET_DETAIL WHERE location_id = copyFromLocationId
      );
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_ASSET_DETAIL_DOCUMENTS -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_LOOKUP_VALUE
      (
        id,
        unique_id,
        code,
        value,
        is_active,
        active_from,
        lookup_type_id ,
        location_id,
        criteria,
		version,
        created_by,
        updated_by,
        created_ts,
        updated_ts
      )
    SELECT BI_LOOKUP_VALUE_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      code,
      value,
      is_active,
      active_from,
      lookup_type_id,
      toLocationId,
      criteria ,
	  0,
      created_by,
      updated_by ,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP  
    FROM BI_LOOKUP_VALUE
    WHERE location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_LOOKUP_VALUE -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_TOPIC
      (
        id,
        unique_id,
        code,
        name,
        description,
        topic_type_id,
        is_active ,
        location_id,
        mrm_product_name,
        mrm_product_code,
		version,
        created_by,
        updated_by,
        created_ts,
        updated_ts
      )
    SELECT BI_TOPIC_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      code,
      name,
      description,
      topic_type_id,
      is_active ,
      toLocationId ,
      mrm_product_name,
      mrm_product_code,
	  0,
      created_by,
      updated_by ,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP  
    FROM BI_TOPIC
    WHERE location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_TOPIC -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_TEMPLATE_DETAIL
      (
        id,
        unique_id,
        uri,
        is_active,
        active_from,
        active_to,
        name,
        subject,
        template_content_type,
        description,
        content,
        location_id ,
		version,
        created_by,
        updated_by ,
        created_ts,
        updated_ts
      )
    SELECT BI_TEMPLATE_DETAIL_SEQ.NEXTVAL,
      regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
      uri,
      is_active,
      active_from,
      active_to,
      name,
      subject,
      template_content_type,
      description,
      content,
      toLocationId ,
	  0,
      created_by,
      updated_by,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    FROM BI_TEMPLATE_DETAIL
    WHERE location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_TEMPLATE_DETAIL -- '|| SQLERRM || '--' || SQLCODE;
  END;

  BEGIN
    INSERT
    INTO BI_EVENT_NOTIFICATION
      (
        id,
        target_state,
        template_detail_id,
        request_type_id,
        send_mode,
        is_active,
        description,
        recipients,
		version,
        location_id ,
        created_by,
        updated_by ,
        created_ts,
        updated_ts
      )
    SELECT BI_EVENT_NOTIFICATION_SEQ.NEXTVAL,
      target_state,
      ( SELECT d.id 
          FROM bi_template_detail d
          WHERE d.location_id = toLocationId
           AND d.name 
            IN (SELECT c.name 
                    FROM bi_template_detail c
                   WHERE c.id = b.id)) tempid ,
      a.request_type_id,
      a.send_mode,
      a.is_active,
      a.description,
      a.recipients,
	  0,
      toLocationId ,
      a.created_by,
      a.updated_by,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP  
  FROM BI_EVENT_NOTIFICATION a,
       BI_TEMPLATE_DETAIL b
    WHERE a.template_detail_id = b.id
    AND a.location_id = copyFromLocationId
    AND b.location_id = copyFromLocationId;
  EXCEPTION
  WHEN OTHERS THEN
    out_chr_err_code:= SQLERRM;
    out_chr_errbuf  := out_chr_errbuf || 'Error inserting into BI_EVENT_NOTIFICATION -- '|| SQLERRM || '--' || SQLCODE;
  END;

  IF out_chr_errbuf IS NULL AND out_chr_err_code IS NULL THEN
    out_chr_err_msg := 'Success';
  ELSE     
  out_chr_err_msg := 'Failure';
  biq_delete_data(toLocationId);
  END IF;

  BEGIN
    UPDATE BI_ASSET_DETAIL
    SET version = 0
    WHERE version = 99999999;
  EXCEPTION 
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE('Error in update : ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE('Error buffer : ' || out_chr_errbuf);
  DBMS_OUTPUT.PUT_LINE('Error code : ' || out_chr_err_code);
  DBMS_OUTPUT.PUT_LINE('Error Msg : ' || out_chr_err_msg);

  COMMIT;

EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ( ' Error in main --' || SQLERRM || '--' || SQLCODE);
  out_chr_errbuf := ' Error in main --' || SQLERRM || '--' || SQLCODE;
END;


PROCEDURE biq_create_new_loc_calendar 
(  copyFromLocationId IN VARCHAR2,
   toLocationId  IN VARCHAR2 ,
   out_chr_errbuf OUT VARCHAR2,
   out_chr_err_code OUT VARCHAR2,
   out_chr_err_msg  OUT VARCHAR2
   )
IS
   l_out_chr_errbuf                LONG;   
   l_chr_err_code                  VARCHAR2(2000);
   l_chr_err_msg                   VARCHAR2(2000);

  BEGIN

  DELETE FROM bi_location_calendar WHERE location_id = toLocationId;

		BEGIN
			INSERT INTO bi_location_calendar  (id,unique_id,
				 start_date,
					 end_Date,
					 location_id,
					 additional_info,
					 is_all_day_event	,
					 version,
					 created_by,
					 updated_by,
					 created_ts,
					 updated_ts)
			SELECT BI_LOCATION_CALENDAR_SEQ.NEXTVAL,
				 regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
				 start_date,
				 end_Date,
				 toLocationId,
				 additional_info,
				 is_all_day_event	,
				 0,
				 created_by,
				 updated_by,
				 CURRENT_TIMESTAMP,
				 CURRENT_TIMESTAMP  FROM  bi_location_calendar  WHERE location_id = copyFromLocationId;
		EXCEPTION
		  WHEN OTHERS
		  THEN
 			out_chr_err_code:= SQLERRM;
			out_chr_errbuf :=  out_chr_errbuf || 'Error inserting into bi_location_calendar -- '|| SQLERRM || '--' || SQLCODE; 
    END;		

  IF out_chr_errbuf IS NULL AND out_chr_err_code IS NULL
  THEN  
	 out_chr_err_msg := 'Success';   
  ELSE
   out_chr_err_msg := 'Failure';
   DELETE FROM bi_location_calendar WHERE location_id = toLocationId;
  END IF; 

  DBMS_OUTPUT.PUT_LINE('Error buffer : '   || out_chr_errbuf);
  DBMS_OUTPUT.PUT_LINE('Error code : ' || out_chr_err_code);
  DBMS_OUTPUT.PUT_LINE('Error Msg : '  || out_chr_err_msg);

   COMMIT;

  EXCEPTION
     WHEN OTHERS
     THEN
     DBMS_OUTPUT.PUT_LINE (
      ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE);

  out_chr_errbuf :=
     ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE;

END; 

PROCEDURE biq_delete_data(
          copyFromLocationId IN NUMBER)
IS

 BEGIN

   DELETE FROM BI_LOCATION_PARAMETER
   WHERE location_id = copyFromLocationId;

   DELETE FROM BI_ASSET_DETAIL_DOCUMENTS
   WHERE asset_Detail_id 
   IN 
     (SELECT id FROM BI_ASSET_DETAIL
       WHERE location_id = copyFromLocationId );

   DELETE FROM BI_ASSET_DETAIL
   WHERE location_id = copyFromLocationId;

   DELETE FROM BI_LOOKUP_VALUE
   WHERE location_id = copyFromLocationId;

   DELETE FROM BI_TOPIC
   WHERE location_id = copyFromLocationId;   

   DELETE FROM BI_EVENT_NOTIFICATION
   WHERE location_id = copyFromLocationId ;

   DELETE FROM BI_TEMPLATE_DETAIL
   WHERE location_id = copyFromLocationId;

   COMMIT;

  EXCEPTION
   WHEN OTHERS
   THEN
     DBMS_OUTPUT.PUT_LINE (
          ' Error in delete proc --'
         || SQLERRM
         || '--'
         || SQLCODE);
  END;

END;
/