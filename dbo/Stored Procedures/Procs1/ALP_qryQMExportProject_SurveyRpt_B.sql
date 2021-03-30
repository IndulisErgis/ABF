Create Procedure [dbo].[ALP_qryQMExportProject_SurveyRpt_B]     
As 

SELECT tblSystemType.SystemType, tblSystemType.Descr AS SysDescr, qryQMExportProject_SurveyRpt_A_AllItems.ItemID, 
qryQMExportProject_SurveyRpt_A_AllItems.Descr, 
Sum(qryQMExportProject_SurveyRpt_A_AllItems.Quantity) AS SumOfQuantity, 
Convert(varchar(10),ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Lvl,NULL)) +' '+ ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Location,NULL) AS LvlLocation,
 qryQMExportProject_SurveyRpt_A_AllItems.Notes, qryQMExportProject_SurveyRpt_A_AllItems.Lvl, qryQMExportProject_SurveyRpt_A_AllItems.Location,
  qryQMExportProject_SurveyRpt_A_AllItems.Comment, qryQMExportProject_SurveyRpt_A_AllItems.ProjectId, qryQMExportProject_SurveyRpt_A_AllItems.AlpPrintProposalYn
FROM (tblQuoteMain INNER JOIN tblSystemType ON tblQuoteMain.SystemTypeID=tblSystemType.SystemTypeID) 
INNER JOIN qryQMExportProject_SurveyRpt_A_AllItems ON tblQuoteMain.QuoteID=qryQMExportProject_SurveyRpt_A_AllItems.QuoteID
GROUP BY tblSystemType.SystemType, tblSystemType.Descr, qryQMExportProject_SurveyRpt_A_AllItems.ItemID, 
qryQMExportProject_SurveyRpt_A_AllItems.Descr
, Convert(varchar(10),ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Lvl,NULL))+' '+ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Location,NULL) 
,qryQMExportProject_SurveyRpt_A_AllItems.Notes, qryQMExportProject_SurveyRpt_A_AllItems.Lvl, qryQMExportProject_SurveyRpt_A_AllItems.Location, 
qryQMExportProject_SurveyRpt_A_AllItems.Comment, qryQMExportProject_SurveyRpt_A_AllItems.ProjectId, qryQMExportProject_SurveyRpt_A_AllItems.AlpPrintProposalYn
HAVING 
(((Sum(qryQMExportProject_SurveyRpt_A_AllItems.Quantity))<>0)) And qryQMExportProject_SurveyRpt_A_AllItems.AlpPrintProposalYn<>0
ORDER BY tblSystemType.SystemType, tblSystemType.Descr, qryQMExportProject_SurveyRpt_A_AllItems.ItemID, 
qryQMExportProject_SurveyRpt_A_AllItems.Descr
, Convert(varchar(10),ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Lvl,NULL))+' ' +ISNULL(qryQMExportProject_SurveyRpt_A_AllItems.Location,NULL)