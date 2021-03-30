CREATE PROCEDURE [dbo].[trav_HrIndAttribute_proc]
@Department [pDeptId],
@AttributeGroup [bigint],
@Attribute [bigint],
@DateFrom DATETIME,
@DateThru DATETIME

AS
SET NOCOUNT ON
BEGIN TRY
	
	DECLARE @now DATETIME
	SET @now = GETDATE()
	
	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL, [IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @now, 0
	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @now

	SELECT DISTINCT IndId, IndividualName, City, CountryCode, HomePhone, CellPhone, BusinessPhone,[State], StartDateInd, ZipCode, DOB, IndStatus,
	Department, DepartmentName, Manager, [ManagerName], [DescAttributeDetail], [Attribute], [AttributeDate], [AttributeNote]
	FROM(SELECT ind.IndId, ind.City, ind.CountryCode, ind.HomePhone, ind.CellPhone, ind.BusinessPhone, ind.[State], 
	ind.StartDate [StartDateInd], ind.ZipCode, ind.DOB, ins.IndStatus,
	p.Department, d.DepartmentName, ind.Manager, gd.AttributeGroupTypeCodeID, gd.[Description] [DescAttributeDetail], tc.[Description] [Attribute], 
	ia.AttributeGroupDetailID, ia.AttributeDate [AttributeDate], ia.Note [AttributeNote],
	CASE 
		WHEN (ind.LastName IS NULL OR ind.LastName = '') THEN ind.FirstName 
		WHEN (ind.FirstName IS NULL OR ind.FirstName = '') THEN ind.LastName ELSE (ind.LastName + ',' + SPACE(1) + ind.FirstName) END [IndividualName],
	CASE 
		WHEN (im.LastName IS NULL OR im.LastName = '') THEN im.FirstName
		WHEN (im.FirstName IS NULL OR im.LastName = '') THEN im.LastName ELSE (im.LastName + ',' + SPACE(1) + im.FirstName) END [ManagerName]
	FROM dbo.tblHrIndGenInfo ind
	INNER JOIN #IndividualList il ON il.[IndId] = ind.[IndId] 
	LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId] 
	LEFT JOIN #IndPositionID ip ON ip.[IndId] = ind.[IndId] 
	LEFT JOIN tblHrIndPosition inp ON inp.[ID] = ip.[PositionID] 
	LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID] 
	LEFT JOIN tblPaDept d ON d.[Id] = p.[Department] 
	LEFT JOIN tblHrIndGenInfo im ON im.[IndId] = ind.Manager 
	INNER JOIN tblHrIndAttribute ia ON ia.IndId = ind.IndId
	INNER JOIN tblHrAttributeGroupDetail gd ON gd.ID = ia.AttributeGroupDetailID
	LEFT JOIN tblHrTypeCode tc ON tc.ID = gd.AttributeGroupTypeCodeID
	)ds
	WHERE (@Attribute= 0 OR @Attribute = AttributeGroupDetailID) AND
	(@Department IS NULL OR @Department = [Department]) AND
	(@AttributeGroup = 0 OR @AttributeGroup = AttributeGroupTypeCodeID) AND
	((@DateFrom IS NULL OR @DateFrom <= [AttributeDate]) AND  (@DateThru IS NULL OR [AttributeDate] <= @DateThru))

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndAttribute_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndAttribute_proc';

