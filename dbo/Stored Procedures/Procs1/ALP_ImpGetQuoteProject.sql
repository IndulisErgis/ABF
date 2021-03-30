CREATE PROCEDURE ALP_ImpGetQuoteProject AS  
 BEGIN  
    
 SELECT b.ImportProjectId,  b.Source_id, Sum(Source_QuoteAmount) AS Source_QuoteAmount,Source_Sitename,Source_SiteAddress  into #t2  
 FROM ALP_tblIMPMain a  INNER JOIN ALP_tblIMPProject b  ON a.IMportProjectId =b.ImportProjectId 
 --Below where condition added by ravi on 4 July 2017, it will return only partial/no-partial quote 
 WHERE a.status<>2
 GROUP BY b.ImportProjectId,b.Source_id,Source_Sitename,Source_SiteAddress  
   
 SELECT  project.ImportProjectId,Source,project.Source_Id,Source_Desc,Source_Rep,ImportDate,Status,IsValidate,  
 ValidatedBy,ValidatedDate,CreatedBy,CreatedDate,BillingNotes,ProjectNotes,PartsOnly,PoNum,   
 Source_QuoteAmount,Source_SiteName,Source_SiteAddress,  
 * FROM ALP_tblIMPProject project INNER JOIN #t2 ON project.ImportProjectId=#t2.ImportProjectID  
    
 DROP TABLE #t2  
 END