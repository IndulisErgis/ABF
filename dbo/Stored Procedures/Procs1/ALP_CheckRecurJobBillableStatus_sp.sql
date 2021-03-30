
CREATE procedure [dbo].[ALP_CheckRecurJobBillableStatus_sp] 
--Created for bug id 400 by NSK on 01 Aug 2016                    
(                      
 @SiteId int,                     
 @ServId int,  
 @AsOfDate Date,  
 @Active int  Output               
)                      
AS                      
SET NOCOUNT ON                      
 Select @Active= dbo.ALP_ufxArAlpSite_IsServiceActive (@SiteId,@ServId,@AsOfDate)