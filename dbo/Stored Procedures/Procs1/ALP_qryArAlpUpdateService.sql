CREATE Procedure [dbo].[ALP_qryArAlpUpdateService] (       
@ID int, @sFinalBillDate datetime=null, @sBillThruDate datetime=null, @nReasonID int=null, @sComments text=null, 
@sReportDate datetime=null,        @sEndDate datetime=null, @sCustId pcustid=null, @sCustName varchar(30)=null, 
@sSiteName varchar(80)=null, @sCustfName varchar(30)=null, @sSitefName varchar(30)=null, @nPrice pdec=0 ,
--Below @UserId  parameter length changed from 10 to 50 char, modified by ravi on 02 May 2017
@UserId varchar(50) =null)      
AS        
SET NOCOUNT ON        
UPDATE ALP_tblArAlpSiteRecBillServ         
SET ALP_tblArAlpSiteRecBillServ.Status = 'Cancelled', ALP_tblArAlpSiteRecBillServ.ActivePrice = @nPrice, ALP_tblArAlpSiteRecBillServ.ActiveRMR = @nPrice,         
 ALP_tblArAlpSiteRecBillServ.BilledThruDate = @sBillThruDate, ALP_tblArAlpSiteRecBillServ.FinalBillDate = @sFinalBillDate,         
 ALP_tblArAlpSiteRecBillServ.CanReasonId = @nReasonID, ALP_tblArAlpSiteRecBillServ.CanComments = @sComments,         
 ALP_tblArAlpSiteRecBillServ.CanReportDate = @sReportDate, ALP_tblArAlpSiteRecBillServ.CanServEndDate = @sEndDate,         
 ALP_tblArAlpSiteRecBillServ.CanCustId = @sCustID, ALP_tblArAlpSiteRecBillServ.CanCustName = @sCustName,         
 ALP_tblArAlpSiteRecBillServ.CanSiteName = @sSiteName, ALP_tblArAlpSiteRecBillServ.CanCustFirstName = @sCustFName,         
 ALP_tblArAlpSiteRecBillServ.CanSiteFirstName = @sSiteFName    ,ModifiedBy =@UserId,ModifiedDate =GETDATE()    
WHERE ALP_tblArAlpSiteRecBillServ.RecBillServId  = @ID