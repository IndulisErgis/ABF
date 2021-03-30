CREATE PROCEDURE Alp_GetRecurringJobForSiteCancel(@pRecBillServId varchar(max) )
  AS
  BEGIN
  DECLARE @SQLQuery varchar(max);
  SET @SQLQuery ='SELECT RecJobEntryId ,CreateDate,CustId,SiteId,a.SysId,a.ContractId,
			LastDateCreated,NextCycleStartDate ,WorkDesc,OtherComments,ExpirationDate
  FROM ALP_tblArAlpSiteRecJob  a INNER JOIN ALP_tblArAlpSiteRecBillServ b on a.RecSvcId =b.RecBillServId 
  WHERE b.RecBillServId  IN ('+ @pRecBillServId + ' ) AND (a.ExpirationDate IS NULL Or a.ExpirationDate > GETDATE())
  ORDER BY RecJobEntryId '
   EXEC(@SQLQuery) ;
  END