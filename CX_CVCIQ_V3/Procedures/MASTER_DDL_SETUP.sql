CREATE OR REPLACE PROCEDURE cx_cvciq_v3."MASTER_DDL_SETUP" 
IS

BEGIN



	EXECUTE IMMEDIATE 'ALTER TABLE BI_ASSET_DETAIL ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_EVENT_NOTIFICATION ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_LOOKUP_VALUE ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_NOTE ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_PRESENTER ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_ROLE_TRANS_RULES ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_TEMPLATE_DETAIL ADD LOCATION_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_TOPIC ADD LOCATION_ID NUMBER'; 


	EXECUTE IMMEDIATE 'ALTER TABLE BI_ASSET_DETAIL DROP CONSTRAINT BI_ASSET_DETAIL_UNIQUE';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_EVENT_NOTIFICATION DROP CONSTRAINT BI_EVENT_NOTIFICATION_UK1';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_LOOKUP_VALUE DROP CONSTRAINT BI_LOOKUP_VALUE_UNIQUE';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_TEMPLATE_DETAIL DROP CONSTRAINT BI_TEMPLATE_DETAIL_UNIQUE';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_TOPIC DROP CONSTRAINT BI_TOPIC_UNIQUE';


	EXECUTE IMMEDIATE 'DROP INDEX BI_ASSET_DETAIL_UNIQUE';
	EXECUTE IMMEDIATE 'DROP INDEX BI_EVENT_NOTIFICATION_UK1';
	EXECUTE IMMEDIATE 'DROP INDEX BI_LOOKUP_VALUE_UNIQUE';
	EXECUTE IMMEDIATE 'DROP INDEX BI_TEMPLATE_DETAIL_UNIQUE';
	EXECUTE IMMEDIATE 'DROP INDEX BI_TOPIC_UNIQUE';


	EXECUTE IMMEDIATE 'ALTER TABLE "BI_ASSET_DETAIL" ADD CONSTRAINT "BI_ASSET_DETAIL_LOCATION_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';  
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_EVENT_NOTIFICATION" ADD CONSTRAINT "BI_EVENT_NOTIFICATION_LOC_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_LOOKUP_VALUE" ADD CONSTRAINT "BI_LOOKUP_VALUE_LOCATION_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_NOTE" ADD CONSTRAINT "BI_NOTE_LOCATION_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_PRESENTER" ADD CONSTRAINT "BI_PRESENTER_LOC_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_ROLE_TRANS_RULES" ADD CONSTRAINT "BI_ROLE_TRANS_RULES_LOC_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_TEMPLATE_DETAIL" ADD CONSTRAINT "BI_TEMPLATE_DETAIL_LOCATION_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';
	EXECUTE IMMEDIATE 'ALTER TABLE "BI_TOPIC" ADD CONSTRAINT "BI_TOPIC_LOCATION_FK" FOREIGN KEY ("LOCATION_ID") REFERENCES "BI_LOCATION" ("ID") ENABLE';


	EXECUTE IMMEDIATE 'ALTER TABLE BI_REQUEST_TOPIC_ACTIVITY RENAME COLUMN NOTES TO NOTES_OLD';
	EXECUTE IMMEDIATE 'ALTER TABLE BI_REQUEST_TOPIC_ACTIVITY ADD NOTES CLOB';




	  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX "BI_ASSET_DETAIL_UNIQUE" ON "BI_ASSET_DETAIL" ("NAME", "ASSET_MASTER_ID", "LOCATION_ID")';	  
	  EXECUTE IMMEDIATE 'ALTER TABLE "BI_ASSET_DETAIL" ADD CONSTRAINT "BI_ASSET_DETAIL_UNIQUE" UNIQUE ("NAME", "ASSET_MASTER_ID", "LOCATION_ID")';
	  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX "BI_EVENT_NOTIFICATION_UK1" ON "BI_EVENT_NOTIFICATION" ("REQUEST_TYPE_ID", "TARGET_STATE", "LOCATION_ID")' ;	  
	  EXECUTE IMMEDIATE 'ALTER TABLE "BI_EVENT_NOTIFICATION" ADD CONSTRAINT "BI_EVENT_NOTIFICATION_UK1" UNIQUE ("REQUEST_TYPE_ID", "TARGET_STATE", "LOCATION_ID")';
	  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX "BI_LOOKUP_VALUE_UNIQUE" ON "BI_LOOKUP_VALUE" ("VALUE", "PARENT_ID", "LOOKUP_TYPE_ID", "LOCATION_ID")'  ;	  
	  EXECUTE IMMEDIATE 'ALTER TABLE "BI_LOOKUP_VALUE" ADD CONSTRAINT "BI_LOOKUP_VALUE_UNIQUE" UNIQUE ("VALUE", "PARENT_ID", "LOOKUP_TYPE_ID", "LOCATION_ID") ';	  
	  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX "BI_TEMPLATE_DETAIL_UNIQUE" ON "BI_TEMPLATE_DETAIL" ("TEMPLATE_MASTER_ID", "NAME") ' ;
	  EXECUTE IMMEDIATE 'ALTER TABLE "BI_TEMPLATE_DETAIL" ADD CONSTRAINT "BI_TEMPLATE_DETAIL_UNIQUE" UNIQUE ("TEMPLATE_MASTER_ID", "NAME") ';
	  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX "BI_TOPIC_UNIQUE" ON "BI_TOPIC" ("TOPIC_TYPE_ID", "NAME", "PARENT_ID", "LOCATION_ID") ';	  
	  EXECUTE IMMEDIATE 'ALTER TABLE "BI_TOPIC" ADD CONSTRAINT "BI_TOPIC_UNIQUE" UNIQUE ("TOPIC_TYPE_ID", "NAME", "PARENT_ID", "LOCATION_ID") ';


          EXECUTE IMMEDIATE 'ALTER TABLE "BI_LOCATION_USER" ADD CONSTRAINT "BI_LOCATION_USER_PK" PRIMARY KEY ("ID")';

          EXECUTE IMMEDIATE 'ALTER TABLE BI_LOCATION_USER ADD CONSTRAINT BI_LOCATION_USER_FK1 FOREIGN KEY (USER_ID)
REFERENCES BI_USER (ID) ENABLE';

END ;
/