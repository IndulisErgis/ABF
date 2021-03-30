CREATE PROCEDURE [dbo].[trav_HRLifeInsPlanList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT li.[ID] AS LifeInsID, li.[Description], ftc.[Description] AS Frequency, ctc.[Description] AS Carrier,
	li.GroupNumber, li.PremiumMethod, li.WaitingPeriod, li.CoverageMaxAmount FROM tblHrLifeInsurance li
	INNER JOIN #tmpLifeInsPlan tl ON tl.[ID] = li.[ID]
	LEFT JOIN tblHrTypeCode ftc ON ftc.ID = li.FrequencyTypeCodeID
	LEFT JOIN tblHrTypeCode ctc ON ctc.ID = li.CarrierTypeCodeID

	SELECT lis.LifeInsID, CASE WHEN li.PremiumMethod = 1 THEN lis.MaxAge ELSE NULL END MaxAge, lis.SelfSEmployerAmount, lis.SelfSEmployeeAmount, lis.SelfNSEmployerAmount, lis.SelfNSEmployeeAmount, 
	lis.SpouseSEmployerAmount, lis.SpouseSEmployeeAmount, lis.SpouseNSEmployerAmount, lis.SpouseNSEmployeeAmount, 
	lis.ChildSEmployerAmount, lis.ChildSEmployeeAmount, lis.ChildNSEmployerAmount, lis.ChildNSEmployeeAmount
	FROM tblHrLifeInsSub lis
	INNER JOIN tblHrLifeInsurance li ON li.ID = lis.LifeInsID
	INNER JOIN #tmpLifeInsPlan tl ON tl.[ID] = lis.[LifeInsID]

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRLifeInsPlanList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRLifeInsPlanList_proc';

