


     
CREATE PROCEDURE [dbo].[ALP_IV_TimeCard_sp]             
 --Created 07/19/18 by ERR        
(            
  @Where nvarchar(1000)= NULL              
)            
AS                
SET NOCOUNT ON;              
DECLARE @str nvarchar(3000) = NULL                
BEGIN TRY          
SET @str = 'SELECT TECH.Tech, Tech.Name, TC.StartDate, TC.EndDate, TC.StartTime, TC.EndTime, ((TC.EndTime-TC.StartTime)/60.0)AS PayrollHrs, CODE.TimeCode, TC.SvcJobYn,
TC.TicketId, SVCTKT.ProjectId, TC.BillableHrs, TC.PayBasedOn, TC.Points, TC.PworkRate, TC.LaborCostRate, TC.TimeCardComment, TC.SpecializedLaborType, TC.LockedYN        
FROM ALP_tblJmTimeCard AS TC INNER JOIN ALP_tblJmTech AS TECH ON TC.TechID = TECH.TechId INNER JOIN ALP_tblJmTimeCode AS CODE ON TC.TimeCodeID = CODE.TimeCodeID
LEFT OUTER JOIN ALP_tblJmSvcTkt AS SVCTKT ON TC.TicketId = SVCTKT.TicketId'           
 
 execute (@str)         
         
 END TRY                
BEGIN CATCH              
  EXEC dbo.trav_RaiseError_proc                
END CATCH