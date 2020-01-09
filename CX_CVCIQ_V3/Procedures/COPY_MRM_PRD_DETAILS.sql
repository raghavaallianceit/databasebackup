CREATE OR REPLACE PROCEDURE cx_cvciq_v3.copy_mrm_prd_details 
IS

CURSOR cur_ins_mrm_prd_data 
    IS
              SELECT  Oscproductstatus,  
                      Productid ,
                      Productname,
                      Glid,
                      Productlevel,
                      Productclass,
                      Productpillar,
                      Productline,
                      Productgroup,
                      Mrmproductstatus, 
                      Marketableflag,
                      Startdate,
                      Enddate,
                      Replacementproduct,
                      Responsechannel,
                      Adminnotes,
                      Gtmpropername,
                      Gtmappfamily,
                      Gtmucmtier1,
                      Gtmucmtier2,
                      Gtmoldname,
                      Wordmapparentid,
                      Wordmapwordsetid,
                      Wordmapphrasetxt, 
                      Productowned,
                      Accountflags,
                      Paidsearchwords,
                      Arprkeywords,
                      Topicscoring,
                      Salescalcategory1,
                      Salescalcategory2,
                      Creationdate,
                      Updateddate,
                      Cxd_Created_Date, 
                      Cxd_Updated_Date 
				FROM CX_CVCIQ.mrm_prod_details_osc 
        WHERE Productid Not IN 
          ( SELECT Productid
              FROM bi_mrm_prod_details_osc
           );
		   
  CURSOR cur_upd_mrm_prd_data
  IS  
           
              SELECT  Oscproductstatus,  
                      Productid ,
                      Productname,
                      Glid,
                      Productlevel,
                      Productclass,
                      Productpillar,
                      Productline,
                      Productgroup,
                      Mrmproductstatus, 
                      Marketableflag,
                      Startdate,
                      Enddate,
                      Replacementproduct,
                      Responsechannel,
                      Adminnotes,
                      Gtmpropername,
                      Gtmappfamily,
                      Gtmucmtier1,
                      Gtmucmtier2,
                      Gtmoldname,
                      Wordmapparentid,
                      Wordmapwordsetid,
                      Wordmapphrasetxt, 
                      Productowned,
                      Accountflags,
                      Paidsearchwords,
                      Arprkeywords,
                      Topicscoring,
                      Salescalcategory1,
                      Salescalcategory2,
                      Creationdate,
                      Updateddate,
                      Cxd_Created_Date, 
                      Cxd_Updated_Date 
				FROM CX_CVCIQ.mrm_prod_details_osc 
        WHERE Productid IN 
          ( SELECT Productid
              FROM bi_mrm_prod_details_osc
           );           
        
    TYPE cur_ins_mrm_prd_tt IS TABLE OF cur_ins_mrm_prd_data%ROWTYPE
    INDEX BY PLS_INTEGER;

    l_cur_mrm_prd_ins cur_ins_mrm_prd_tt;
    
    TYPE cur_upd_mrm_prd_tt IS TABLE OF cur_upd_mrm_prd_data%ROWTYPE
    INDEX BY PLS_INTEGER;

    l_cur_mrm_prd_upd cur_upd_mrm_prd_tt;
	
BEGIN	

    OPEN cur_ins_mrm_prd_data;

    LOOP
  
      FETCH cur_ins_mrm_prd_data
      BULK COLLECT INTO l_cur_mrm_prd_ins LIMIT 1000;
  
      EXIT WHEN l_cur_mrm_prd_ins.COUNT = 0;
                      
            
        FOR i IN 1 .. l_cur_mrm_prd_ins.COUNT
        LOOP
        
          
            BEGIN
              INSERT INTO BI_MRM_PROD_DETAILS_OSC
                   (  id,
                      last_refresh_ts,
                      Oscproductstatus,  
                      Productid ,
                      Productname,
                      Glid,
                      Productlevel,
                      Productclass,
                      Productpillar,
                      Productline,
                      Productgroup,
                      Mrmproductstatus, 
                      Marketableflag,
                      Startdate,
                      Enddate,
                      Replacementproduct,
                      Responsechannel,
                      Adminnotes,
                      Gtmpropername,
                      Gtmappfamily,
                      Gtmucmtier1,
                      Gtmucmtier2,
                      Gtmoldname,
                      Wordmapparentid,
                      Wordmapwordsetid,
                      Wordmapphrasetxt, 
                      Productowned,
                      Accountflags,
                      Paidsearchwords,
                      Arprkeywords,
                      Topicscoring,
                      Salescalcategory1,
                      Salescalcategory2,
                      Creationdate,
                      Updateddate,
                      Cxd_Created_Date, 
                      Cxd_Updated_Date
                )
                  VALUES
                (   mrm_prod_details_seq.nextval,
                     CURRENT_TIMESTAMP,
                     l_cur_mrm_prd_ins(i).Oscproductstatus
                    ,l_cur_mrm_prd_ins(i).Productid                                                  
                    ,l_cur_mrm_prd_ins(i).Productname
                    ,l_cur_mrm_prd_ins(i).Glid
                    ,l_cur_mrm_prd_ins(i).Productlevel
                    ,l_cur_mrm_prd_ins(i).Productclass
                    ,l_cur_mrm_prd_ins(i).Productpillar
                    ,l_cur_mrm_prd_ins(i).Productline
                    ,l_cur_mrm_prd_ins(i).Productgroup
                    ,l_cur_mrm_prd_ins(i).Mrmproductstatus
                    ,l_cur_mrm_prd_ins(i).Marketableflag
                    ,l_cur_mrm_prd_ins(i).Startdate
                    ,l_cur_mrm_prd_ins(i).Enddate
                    ,l_cur_mrm_prd_ins(i).Replacementproduct
                    ,l_cur_mrm_prd_ins(i).Responsechannel
                    ,l_cur_mrm_prd_ins(i).Adminnotes
                    ,l_cur_mrm_prd_ins(i).Gtmpropername
                    ,l_cur_mrm_prd_ins(i).Gtmappfamily
                    ,l_cur_mrm_prd_ins(i).Gtmucmtier1
                    ,l_cur_mrm_prd_ins(i).Gtmucmtier2
                    ,l_cur_mrm_prd_ins(i).Gtmoldname
                    ,l_cur_mrm_prd_ins(i).Wordmapparentid
                    ,l_cur_mrm_prd_ins(i).Wordmapwordsetid
                    ,l_cur_mrm_prd_ins(i).Wordmapphrasetxt
                    ,l_cur_mrm_prd_ins(i).Productowned
                    ,l_cur_mrm_prd_ins(i).Accountflags
                    ,l_cur_mrm_prd_ins(i).Paidsearchwords
                    ,l_cur_mrm_prd_ins(i).Arprkeywords
                    ,l_cur_mrm_prd_ins(i).Topicscoring
                    ,l_cur_mrm_prd_ins(i).Salescalcategory1
                    ,l_cur_mrm_prd_ins(i).Salescalcategory2
                    ,l_cur_mrm_prd_ins(i).Creationdate
                    ,l_cur_mrm_prd_ins(i).Updateddate
                    ,l_cur_mrm_prd_ins(i).Cxd_Created_Date
                    ,l_cur_mrm_prd_ins(i).Cxd_Updated_Date
                );
         
             EXCEPTION
              WHEN OTHERS
              THEN
                DBMS_OUTPUT.PUT_LINE('Inserting into BI_MRM_PROD_DETAILS_OSC for all MRM values ' || SQLERRM );
             END;
      
        COMMIT; 
        END LOOP;

  END LOOP;  
  
  OPEN cur_upd_mrm_prd_data;

    LOOP
  
      FETCH cur_upd_mrm_prd_data
      BULK COLLECT INTO l_cur_mrm_prd_upd LIMIT 1000;
  
      EXIT WHEN l_cur_mrm_prd_upd.COUNT = 0;
                      
            
        FOR i IN 1 .. l_cur_mrm_prd_upd.COUNT
        LOOP
        
          
            BEGIN
              UPDATE BI_MRM_PROD_DETAILS_OSC
                 SET  last_refresh_ts = CURRENT_TIMESTAMP,
                      Oscproductstatus = l_cur_mrm_prd_upd(i).Oscproductstatus,
                      Productname  = l_cur_mrm_prd_upd(i).Productname,
                      Glid = l_cur_mrm_prd_upd(i).Glid,
                      Productlevel = l_cur_mrm_prd_upd(i).Productlevel,
                      Productclass = l_cur_mrm_prd_upd(i).Productclass,
                      Productpillar = l_cur_mrm_prd_upd(i).Productpillar,
                      Productline = l_cur_mrm_prd_upd(i).Productline,
                      Productgroup = l_cur_mrm_prd_upd(i).Productgroup,
                      Mrmproductstatus = l_cur_mrm_prd_upd(i).Mrmproductstatus,
                      Marketableflag = l_cur_mrm_prd_upd(i).Marketableflag,
                      Startdate = l_cur_mrm_prd_upd(i).Startdate,
                      Enddate = l_cur_mrm_prd_upd(i).Enddate,
                      Replacementproduct = l_cur_mrm_prd_upd(i).Replacementproduct,
                      Responsechannel = l_cur_mrm_prd_upd(i).Responsechannel,
                      Adminnotes = l_cur_mrm_prd_upd(i).Adminnotes,
                      Gtmpropername = l_cur_mrm_prd_upd(i).Gtmpropername,
                      Gtmappfamily = l_cur_mrm_prd_upd(i).Gtmappfamily,
                      Gtmucmtier1 = l_cur_mrm_prd_upd(i).Gtmucmtier1,
                      Gtmucmtier2 = l_cur_mrm_prd_upd(i).Gtmucmtier2,
                      Gtmoldname = l_cur_mrm_prd_upd(i).Gtmoldname,
                      Wordmapparentid = l_cur_mrm_prd_upd(i).Wordmapparentid,
                      Wordmapwordsetid = l_cur_mrm_prd_upd(i).Wordmapwordsetid,
                      Wordmapphrasetxt = l_cur_mrm_prd_upd(i).Wordmapphrasetxt,
                      Productowned = l_cur_mrm_prd_upd(i).Productowned,
                      Accountflags = l_cur_mrm_prd_upd(i).Accountflags,
                      Paidsearchwords = l_cur_mrm_prd_upd(i).Paidsearchwords,
                      Arprkeywords = l_cur_mrm_prd_upd(i).Arprkeywords,
                      Topicscoring = l_cur_mrm_prd_upd(i).Topicscoring,
                      Salescalcategory1 = l_cur_mrm_prd_upd(i).Salescalcategory1,
                      Salescalcategory2 = l_cur_mrm_prd_upd(i).Salescalcategory2,
                      Creationdate = l_cur_mrm_prd_upd(i).Creationdate,
                      Updateddate = l_cur_mrm_prd_upd(i).Updateddate,
                      Cxd_Created_Date = l_cur_mrm_prd_upd(i).Cxd_Created_Date,
                      Cxd_Updated_Date = l_cur_mrm_prd_upd(i).Cxd_Updated_Date
				WHERE Productid = l_cur_mrm_prd_upd(i).Productid ;
         
             EXCEPTION
              WHEN OTHERS
              THEN
               DBMS_OUTPUT.PUT_LINE('Updating BI_MRM_PROD_DETAILS_OSC with the latest changes of MRM  ' || SQLERRM );
             END;
      
        END LOOP;

  END LOOP;

  BEGIN
  
    UPDATE BI_TOPIC
	   SET mrm_product_id = NULL,
	       last_refresh_date = sysdate
	 WHERE mrm_product_id IN (SELECT Productid FROM BI_MRM_PROD_DETAILS_OSC WHERE Oscproductstatus = 'INACTIVE' )
	   AND mrm_product_id IS NOT NULL;
    
  EXCEPTION
   WHEN OTHERS
   THEN
     DBMS_OUTPUT.PUT_LINE('Updating bi_topic with null product id for the inactive MRM products ' || SQLERRM );
  END;
  

 
 BEGIN
      DELETE 
				FROM bi_mrm_prod_details_osc
        WHERE Productid Not IN 
          ( SELECT Productid
              FROM CX_CVCIQ.mrm_prod_details_osc 
           );
  EXCEPTION
   WHEN OTHERS
   THEN
     DBMS_OUTPUT.PUT_LINE('Here deleting products that are deleted from MRM table ' || SQLERRM );
 END;
 
 
   BEGIN
  
    UPDATE BI_TOPIC
	   SET mrm_product_id = NULL,
	       last_refresh_date = sysdate
	 WHERE mrm_product_id NOT IN (SELECT Productid FROM BI_MRM_PROD_DETAILS_OSC)
	   AND mrm_product_id IS NOT NULL;
    
  EXCEPTION
   WHEN OTHERS
   THEN
     DBMS_OUTPUT.PUT_LINE('Updating bi_topic with null product id for the deleted MRM products ' || SQLERRM );
  END;  
  
  COMMIT; 

 
END;
/