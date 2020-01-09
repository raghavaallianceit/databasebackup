CREATE OR REPLACE TYPE cx_cvciq_v3.return_cat_report AS OBJECT (
				requestActivityDayId  NUMBER ,                     
				requestId          NUMBER  ,       
                startDate          VARCHAR2(50) ,
				room                VARCHAR2(500) ,
				company       VARCHAR2(8000),
				companyCountry       		VARCHAR2(500),
				briefingmanager	VARCHAR2(500),
				host			VARCHAR2(60),
				hostPhoneNumber		VARCHAR2(60),
				requesterName			VARCHAR2(500),
                requesterPhoneNumber    VARCHAR2(256),
				startTime          VARCHAR2(20),                
				duration          NUMBER,                
				endTime            VARCHAR2(20),
				cateringType		VARCHAR2(8000),
				attendess			NUMBER,
				notes				VARCHAR2(5000),
				costCenter			VARCHAR2(500),
				dietary	VARCHAR2(500),
                cateringactivityid NUMBER, 
       CONSTRUCTOR FUNCTION return_cat_report RETURN SELF AS RESULT
);


/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_cat_report AS
      CONSTRUCTOR FUNCTION return_cat_report RETURN SELF AS RESULT AS
      BEGIN

             self.requestActivityDayId := NULL;
        self.requestId := NULL;
        self.startDate := NULL;
        self.room :=NULL;
        self.company := NULL;
        self.companycountry := NULL;
        self.briefingmanager := NULL;
        self.host := NULL;
        self.hostPhoneNumber := NULL;
        self.requesterName := NULL;
        self.requesterPhoneNumber := NULL;
        self.startTime := NULL;
        self.duration := NULL;
        self.cateringType := NULL;
        self.attendess := NULL;
        self.notes := NULL;
        self.costCenter := NULL;
        self.dietary := NULL;
        self.cateringactivityid :=NULL;
         RETURN;
      END;
END;

/