CREATE OR REPLACE TYPE cx_cvciq_v3.return_gcp_report AS OBJECT (                  
				requestId          		NUMBER  ,                    
				startDate                	VARCHAR2(50) ,
				company      	 		VARCHAR2(500),
				companyCountry						VARCHAR2(500),
				visitFocus       			VARCHAR2(500),
				briefingManager			VARCHAR2(500),
				host					VARCHAR2(60),
				extFirstName                  VARCHAR2(200)  ,
				extLastName	                VARCHAR2(200)  ,
				extTitle					    VARCHAR2(200),
       CONSTRUCTOR FUNCTION return_gcp_report RETURN SELF AS RESULT
);

/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_gcp_report AS
      CONSTRUCTOR FUNCTION return_gcp_report RETURN SELF AS RESULT AS
      BEGIN

               SELF.requestId          := NULL;
               SELF.startDate                := NULL;
               SELF.company           := NULL;
			   SELF.companyCountry           := NULL;
               SELF.visitFocus          := NULL;
               SELF.briefingManager       := NULL;
               SELF.host    := NULL;
               SELF.extFirstName       := NULL;
               SELF.extLastName           := NULL;
               SELF.extTitle           := NULL;
         RETURN;
      END;
END;
/