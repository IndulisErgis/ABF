
CREATE  procedure [dbo].[ALP_qry_ContractDtls]    
 (    
	@ProjectId varchar(10) 
 )    
AS                  

SELECT   distinct C.ContractId, C.ContractNum  ,CF.ContractForm, CF.Title,C.ContractDate, 
C.ContractValue, 
CASE       
  WHEN C.SignedYN = 1 THEN 'Yes'      
  ELSE 'No'      
 END AS SignedYN,
 CASE       
  WHEN C.AlteredYN = 1 THEN 'Yes'      
  ELSE 'No'      
 END AS AlteredYN,
 C.CustId ,C.Ref                       
FROM         ALP_tblArAlpCustContract AS C INNER JOIN  
                      ALP_tblArAlpContractForm AS CF ON C.ContractFormId = CF.ContractFormId INNER JOIN  
                      ALP_tblJmSvcTkt AS T ON C.ContractId = T.ContractId AND C.CustId = T.CustId  
WHERE     (T.ProjectId = @ProjectId)