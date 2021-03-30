CREATE PROCEDURE Alp_VerifySiteIdInUse_SP (@SiteId int,
@Table varchar(50)=''output) AS
BEGIN
DECLARE @Count int;
	 
	IF EXISTS(SELECT SiteId  FROM ALP_tblJmSvcTkt WHERE SiteId =@SiteId AND Status <>'Cancelled' )
	BEGIN
		SET @Table='Ticket(s)'
		RETURN (1);
	END
	 
	
	IF EXISTS (SELECT  SiteId  FROM ALP_tblJmSvcTktProject WHERE SiteId =@SiteId)
	BEGIN
		SET @Table='Project(s)'
		RETURN (1);
	END
		
	IF EXISTS( SELECT AlpSiteID  FROM ALP_tblArOpenInvoice  WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Open Invoice(s)'
		RETURN (1);
	END
	
	IF EXISTS(SELECT AlpSiteID  FROM ALP_tblArCashRcptDetail WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Cash Receipt-UnPosted Transaction(s)'
		RETURN(1);
	END
	
	IF EXISTS(SELECT AlpSiteID  FROM ALP_tblArTransHeader  WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Accounts Receivable-UnPosted Transaction(s)'
		RETURN(1);
	END
	
	IF EXISTS (SELECT AlpSiteID  FROM ALP_tblArTransDetail   WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Accounts Receivable-UnPosted Transaction(s)'
		RETURN(1);
	END
	
	IF EXISTS( SELECT AlpSiteID  FROM ALP_tblArHistHeader    WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Accounts Receivable History'
		RETURN(1);
	END
	
	IF EXISTS( SELECT AlpSiteID  FROM ALP_tblArHistDetail     WHERE AlpSiteID =@SiteId)
	BEGIN
		SET @Table='Accounts Receivable History'
		RETURN(1);
	END
	 
	IF EXists(	SELECT AlpSiteID  FROM ALP_tblArHistPmt   WHERE AlpSiteID =@SiteId)
   BEGIN
		SET @Table='Accounts Receivable Payment History'
		RETURN(1);
	END
   
   SET @Table ='';
   RETURN (0);
END