CREATE Procedure ALP_JobChangeSite( @JobNum int,@SiteId int,@SysId int,@ProjectId varchar(10))As  
Begin  
 --812-ChgJobSiteId && --813-ChgJobSysId  
 --Below update query modified by ravi on 29 sep 2016, to fix the bugid 545, ProjectId update in ticket table
 --UPDATE ALP_tblJmSvcTkt SET Alp_tbljmsvctkt.SiteId =  @SiteId,Alp_tbljmsvctkt.SysId  =  @SysId  
 --WHERE  Alp_tbljmsvctkt.TicketId= @JobNum  
  UPDATE ALP_tblJmSvcTkt SET Alp_tbljmsvctkt.SiteId =  @SiteId,Alp_tbljmsvctkt.SysId  =  @SysId  ,Alp_tbljmsvctkt.ProjectId = @ProjectId
 WHERE  Alp_tbljmsvctkt.TicketId= @JobNum  
 
 --814-ChgSysItems  
 UPDATE ALP_tblArAlpSiteSysItem SET ALP_tblArAlpSiteSysItem.SysId = @SysId  
 WHERE ALP_tblArAlpSiteSysItem .TicketId=@JobNum   
  
 --815-ChgOpenInvoiceSite  
 UPDATE  ALP_tblArOpenInvoice SET ALP_tblArOpenInvoice.AlpSiteID =@SiteId   
 FROM  ALP_tblArOpenInvoice   INNER JOIN  tblArHistHeader ON ALP_tblArOpenInvoice.AlpInvcNum  = tblArHistHeader.InvcNum    
 AND ALP_tblArOpenInvoice .AlpCustId  =tblArHistHeader.CustId   
 INNER JOIN ALP_tblArHistHeader ON ALP_tblArHistHeader .AlpPostRun =tblArHistHeader.PostRun and alp_tblarhistheader.AlpTransId =tblarhistheader.TransId   
 WHERE ALP_tblArHistHeader .AlpJobNum =@JobNum  
  
 --816-ChgHistInvoiceSite  
 UPDATE ALP_tblArHistHeader SET ALP_tblArHistHeader.AlpSiteID =  @SiteId   
 WHERE  ALP_tblArHistHeader.AlpJobNum = @JobNum   
END