   
CREATE procedure [dbo].[ALP_qryJmGetAllCusts_sp]     
AS       
--Created on 07 Oct 2015 by NSK to use JmTickets      
SELECT    TOP 100 PERCENT  C.CustId, C.CustName,     
 AC.AlpFirstName, C.Addr1,    
 AC.AlpInactive,       
 AC.AlpJmCustLevel,C.TermsCode,    
 C.DistCode, C.CurrencyId,     
 AC.AlpPoRequiredYn       
 ,C.Status    
 ,C.PONumberRequiredYn --Added by NSK on 08 Jan 2021 for bug id 1105   
FROM  dbo.ALP_tblArCust AC (NOLOCK)  
 INNER JOIN dbo.tblArCust C (NOLOCK) On AC.AlpCustId=C.CustId