CREATE VIEW dbo.Alp_lkpArAlpServiceType_SM    
AS    
SELECT     ServiceTypeId, [Service Type] as ServiceType,     
CASE    
 WHEN RecurringSvc = 1 THEN 'Recur Svc'     
 ELSE 'Other'    
END AS Recur    
FROM         dbo.Alp_tblArAlpServiceType