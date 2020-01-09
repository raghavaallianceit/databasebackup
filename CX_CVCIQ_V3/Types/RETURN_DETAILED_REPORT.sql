CREATE OR REPLACE TYPE cx_cvciq_v3.return_detailed_report AS OBJECT (                  
				requestId          		NUMBER  ,                    
				startDate                	VARCHAR2(50) ,
                room                        VARCHAR2(500),
				company      	 		VARCHAR2(500),
				companyCountry						VARCHAR2(500),
				industry       				VARCHAR2(500),
				tier				VARCHAR2(256),
                visitType	                VARCHAR2(256),
                visitFocus	                VARCHAR2(256),
				briefingManager			VARCHAR2(500),
				host					VARCHAR2(60),
				requestor					VARCHAR2(60),
				oppNumber		VARCHAR2(500),--primary_opportunity_id
--				secondary_opportunity_id    VARCHAR2(20),
                oppRevenue			VARCHAR2(500),
                firstName			VARCHAR2(256),
                lastName			VARCHAR2(256),
				title				VARCHAR2(256),
				attendeeType            VARCHAR2(50),
--				intFirstName          VARCHAR2(256)  ,
--				intLastName	        VARCHAR2(256)  ,
--				intTitle				VARCHAR2(256),
                costCenter	                VARCHAR2(256 BYTE),
                duration	                NUMBER,
       CONSTRUCTOR FUNCTION return_detailed_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_detailed_report AS
      CONSTRUCTOR FUNCTION return_detailed_report RETURN SELF AS RESULT AS
      BEGIN

               SELF.requestId          := NULL;
               SELF.startDate                := NULL;
               SELF.room                := NULL;
               SELF.company           := NULL;
			   SELF.companyCountry           := NULL;
               SELF.industry          := NULL;
               SELF.tier            := NULL;
               SELF.visitType       := NULL;
               SELF.visitFocus       := NULL;
               SELF.briefingManager       := NULL;
               SELF.host    := NULL;
               SELF.requestor    := NULL;
               SELF.oppNumber           := NULL;
               SELF.oppRevenue       := NULL;
               SELF.firstName  := NULL;
               SELF.lastName         := NULL;
               SELF.title           := NULL;
               SELF.attendeeType           := NULL;
               SELF.costCenter           := NULL;
               SELF.duration           := NULL;
         RETURN;
      END;
END;
/