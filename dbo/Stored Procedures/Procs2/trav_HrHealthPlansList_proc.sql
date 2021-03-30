CREATE PROCEDURE [dbo].[trav_HrHealthPlansList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

SELECT tc.[Description] AS FrecuencyDescription,tc2.[Description] AS CarrierType, hi.[ID] AS HealthInsID,[EmployeeContribution],[EmployerContribution],[MaximumAgeEmployee],[MaximumAgeDependent],
[WaitingPeriod],[MaxOutOfPocket],[Deductible],[MaxBenefit],[MajorMedicalCoverage],[COBRAPremium],hi.[GroupNumber],hi.[Description] AS [HealthDescription], hcp.[Description] AS [DescriptionCop], Amount
FROM [dbo].[tblHrHealthInsurance] hi
INNER JOIN #HealthPlansList hpl ON hpl.ID = hi.[ID]
LEFT JOIN tblHrTypeCode tc ON tc.ID = hi.FrequencyTypeCodeID
LEFT JOIN tblHrTypeCode tc2 ON tc2.ID  =  hi.CarrierTypeCodeID
LEFT JOIN tblHrHealthCoPay hcp ON hi.Id = hcp.HealthInsID

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrHealthPlansList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrHealthPlansList_proc';

