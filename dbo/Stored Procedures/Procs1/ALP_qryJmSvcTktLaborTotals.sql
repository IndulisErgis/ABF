      
      
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktLaborTotals]       
@ID int      
As      
SET NOCOUNT ON      
Create Table #SvcTktLabor      
(      
TimeCardId int,      
TechId int,      
Tech varchar(3),      
StartDate datetime,       
[Time] datetime,      
TimeCode varchar(10),      
Hours pdec,      
BillHrs pdec,      
Pts pdec,      
LaborCost pdec,      
LaborPrice pdec,    
--below column added by NSK on Feb 24 2015    
EndDate datetime  
--below column added by NSK on Jun 20 2018
,LockedYN bit 
)      
--Get current aged customer balances      
Insert into #SvcTktLabor    
 Exec dbo.ALP_qryJmSvcTktLabor @ID      
SELECT Sum([Hours]) AS TotActualHours, Sum([BillHrs]) AS TotBillHours,       
 Sum([Pts]) AS TotPts, Sum([LaborCost]) AS TotLaborCost, Sum([LaborPrice]) AS TotLaborPrice   
  
FROM #SvcTktLabor