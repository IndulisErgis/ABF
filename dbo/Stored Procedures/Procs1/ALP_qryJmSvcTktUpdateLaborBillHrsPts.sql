CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateLaborBillHrsPts]        
@TimeCardID int,      
@BillableHrs decimal(20,10),        
@Points float,    
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017  
@ModifiedBy varchar(50)       
AS        
Update ALP_tblJmTimeCard set BillableHrs=@BillableHrs,Points=@Points      
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()        
 where TimeCardID=@TimeCardID