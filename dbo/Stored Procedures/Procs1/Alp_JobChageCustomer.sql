CREATE Procedure Alp_JobChageCustomer  (
@CustId Varchar(10), 
 @JobNum int ,
 @SiteId int,
 @ContractId int) as
Begin

	--817-ChgOpenInvoiceCust
	UPDATE tblArOpenInvoice SET tblArOpenInvoice .CustId = @CustId 
	FROM  tblArOpenInvoice   INNER JOIN  tblArHistHeader ON tblArOpenInvoice.InvcNum =tblArHistHeader.InvcNum 
	AND tblArOpenInvoice.CustId =tblArHistHeader.CustId 
	INNER JOIN ALP_tblArHistHeader ON ALP_tblArHistHeader .AlpPostRun =tblArHistHeader.PostRun and alp_tblarhistheader.AlpTransId =tblarhistheader.TransId 
	WHERE ALP_tblArHistHeader .AlpJobNum =@JobNum
 

	UPDATE ALP_tblArOpenInvoice  SET ALP_tblArOpenInvoice.AlpCustId = @CustId
	FROM  ALP_tblArOpenInvoice   INNER JOIN  tblArHistHeader ON ALP_tblArOpenInvoice.AlpInvcNum  = tblArHistHeader.InvcNum  
	AND ALP_tblArOpenInvoice .AlpCustId  =tblArHistHeader.CustId 
	INNER JOIN ALP_tblArHistHeader ON ALP_tblArHistHeader .AlpPostRun =tblArHistHeader.PostRun and alp_tblarhistheader.AlpTransId =tblarhistheader.TransId 
	WHERE ALP_tblArHistHeader .AlpJobNum =@JobNum


	--818-ChgHistPmtCust
	UPDATE tblArHistPmt SET tblArHistPmt.CustId =@CustId 
	FROM tblArHistPmt INNER JOIN tblArHistHeader ON tblArHistPmt.InvcNum  = tblarhistheader.InvcNum 
	INNER  JOIN ALP_tblArHistHeader  ON  tblArHistHeader.PostRun =ALP_tblArHistHeader .AlpPostRun 
	AND ALP_tblArHistHeader .AlpTransId =tblArHistHeader.TransId 
	WHERE tblArHistHeader.CustId=@CustId  and ALP_tblArHistHeader.AlpSiteID=@SiteId
	
	
	--819-ChgHistInvoiceCust
	UPDATE  tblArHistHeader SET  tblArHistHeader.CustId = @CustId 
	FROM tblArHistHeader INNER   JOIN  ALP_tblArHistHeader ON tblArHistHeader .PostRun =alp_tblarhistheader.AlpPostRun 
	AND tblarhistheader.TransId =ALP_tblArHistHeader .AlpTransId 
	WHERE   ALP_tblArHistHeader.AlpJobNum=@JobNum 
	
	
	--820-ChgJobCust
	UPDATE  Alp_tblJmSvcTkt SET Alp_tblJmSvcTkt.CustId = @CustId 
	WHERE  Alp_tblJmSvcTkt.TicketId=@JobNum 
	
	--821-ChgJobContractId
	UPDATE Alp_tblJmSvcTkt SET Alp_tblJmSvcTkt.ContractId =@ContractId 
	WHERE Alp_tblJmSvcTkt.TicketId=@JobNum ;


End