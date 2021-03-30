--FROM OLD SCRIPTS FOLDER!!!  8/2016
CREATE PROCEDURE [dbo].[ALP_IV_JobActions_sp]       
 --Created 03/23/16 by mah; modified 8/2016 and 9/21/2016
 -- added  Resol Descr,ActionTech, ActionDate 
(      
  @Where nvarchar(1000)= NULL        
)      
AS          
SET NOCOUNT ON;        
DECLARE @str nvarchar(2000) = NULL          
BEGIN TRY        
SELECT  TI.TicketId,   
 R.Action as ActionType,  
 R.ResolutionCode as Action,  
 TI.ResDesc as ActionDesc,   
 CC.CauseCode,  
 TI.CauseDesc as CauseDesc, Comments,   
 TI.ItemID, TI.[Desc] as ItemDesc,   
 CAST(TI.QtyAdded AS Decimal(10,2)) as Qty,       
 CAST(TI.QtyRemoved as Decimal(10,2)) as QtyRemoved,       
 CAST(TI.QtyServiced as Decimal(10,2)) as QtyServiced,       
 TI.UOM,      
 UnitPrice, UnitCost,   
 ExtPrice = CAST((UnitPrice * QtyAdded) AS Decimal(14,2)) ,  
 ExtCost = CAST((UnitCost * QtyAdded) AS Decimal(14,2)) , 
 TI.EquipLoc,  
 TI.WhseId, TI.TicketItemId,  
 T.Status,  
 T.SiteId,  
 WC.WorkCode,  
 T.WorkDesc,  
 tech.Tech as LeadTech,  
 T.SalesRepId as SalesRep,  
 ST.SysType, SS.SysDesc as SystemDesc,  
 T.ProjectId,  
 T.CustId,  
 T.LseYn as LeaseYn, T.CsConnectYn,   
 T.OtherComments as JobComments,CAST (TI.PartPulledDate AS DATE) as PartPulledDate,      
 CAST(T.StagedDate as DATE) as StagedDate,   
 CAST(T.CompleteDate AS DATE) as CompleteDate,  
 CAST(T.CloseDate AS DATE) as CloseDate,  
 CAST(T.TurnoverDate AS DATE) as TurnoverDate,  
 CAST(T.OrderDate AS DATE) as OrderDate,  
 CAST(TI.WarrExpDate AS DATE) as WarrantyExp,  
 R.ResolutionCode as Resolution, T.ResolComments,  
 T.ReturnYn , T.BranchId, T.DivId, T.DeptId,
 --mah 06/15/16:
 CASE WHEN R.Action = 'Other' THEN TI.Zone ELSE '' END AS ActionTech, 
 CASE WHEN R.Action = 'Other' THEN CAST (TI.PartPulledDate AS DATE) ELSE NULL END  as ActionDate , 
 RC.Descr as ResolDescr,
 RC.ResolCode as TktResolution 
INTO #temp         
FROM dbo.ALP_tblJmSvcTkt T    
 INNER JOIN  dbo.ALP_tblJmSvcTktItem  TI ON T.TicketID = TI.TicketID   
 INNER JOIN dbo.ALP_tblJmWorkCode WC ON WC.WorkCodeId = T.WorkCodeId  
 INNER JOIN dbo.ALP_tblArAlpSiteSys SS ON SS.SysId = T.SysId  
 INNER JOIN dbo.ALP_tblArAlpSysType ST ON ST.SysTypeId = SS.SysTypeId  
 LEFT OUTER JOIN dbo.ALP_tblJmResolution R ON TI.ResolutionID = R.ResolutionId  
 LEFT OUTER JOIN dbo.ALP_tblJmCauseCode CC on TI.CauseId = CC.CauseId  
 LEFT OUTER JOIN dbo.ALP_tblJmResol RC  ON RC.ResolID = T.ResolId   
 LEFT OUTER JOIN dbo.ALP_tblJmTech tech ON tech.TechId = T.LeadTechId     
   
 SET @str =        
'SELECT * FROM #temp '  + CASE WHEN @Where IS NULL THEN ' '        
  WHEN @Where = '' THEN ' '        
  WHEN @Where = ' ' THEN ' '        
  ELSE ' WHERE ' + @Where        
  END  + ' '       
      
 execute (@str)       
 DROP TABLE #temp      
 END TRY          
BEGIN CATCH        
 DROP TABLE #temp        
 EXEC dbo.trav_RaiseError_proc          
END CATCH