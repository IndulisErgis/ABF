CREATE function [dbo].[ALP_ufxJmProject_GetContractAmt]  
(  
 @ProjectID varchar(10)  
)  
--MAH 07/02/07 - accommodate null contract values  
returns pDec  
AS  
BEGIN  
DECLARE @ReturnSum pdec  
DECLARE @sum pdec  
--SET @sum = 0  
--RETURN  
SET @sum =   
 (SELECT SUM(case when ContractValue is null then 0   
    --Commented by NSK on 30 Sep 2013   
    --when ContractValue = '' then 0   
    else ContractValue end ) as ContractTotal  
  FROM ALP_tblArAlpCustContract C  
  WHERE C.ContractId IN (SELECT DISTINCT ST.ContractId  
     FROM ALP_tblJmSvcTkt ST   
     WHERE (ST.ProjectId = @ProjectID)
     --mah 11/20/15 mah - adjusted to include both spellings of canceled!
      AND (ST.Status <> 'canceled') AND (ST.Status <> 'cancelled')   
      --AND (ST.Status <> 'cancelled')  
     )  
)  
IF @sum is null   
 BEGIN   
  SET @ReturnSum = 0  
 END  
ELSE  
 BEGIN  
  SET @ReturnSum = @sum  
 END  
  
RETURN @ReturnSum  
END