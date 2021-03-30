CREATE PROCEDURE [dbo].[trav_HRAttributeCensusReport_proc]
@ActiveAsOf DATETIME,
@Active SMALLINT,
@AttrDateFrom DATETIME,
@AttrDateThru DATETIME,
@GroupBy TINYINT

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @TotalInd INT

	CREATE TABLE #IndividualList (IndId [pEmpID] NOT NULL)
	INSERT INTO #IndividualList SELECT DISTINCT ind.IndId FROM dbo.tblHrIndGenInfo ind

	CREATE TABLE #IndPositionID (IndId [pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOf

	CREATE TABLE #IndStatus (IndId [pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOf, @Active

	CREATE TABLE #tmpAttribute (AttributeGroup NVARCHAR(255), 
								Attribute NVARCHAR(255), 
								Individuals INT, 
								TotalAttr INT NULL,
								TotalInd INT NULL,
								IndPercent pDecimal NULL,
								GroupBy NVARCHAR(255))
	
	--PET: --http://problemtrackingsystem.osas.com/view.php?id=267747
	--PET: --http://problemtrackingsystem.osas.com/view.php?id=268014
	SELECT @TotalInd = 
	(SELECT COUNT(IndId) FROM (	SELECT DISTINCT ind.IndId FROM #IndividualList ind
	INNER JOIN #IndStatus ins ON ins.IndId = ind.IndId
	INNER JOIN tblHrIndAttribute a ON a.IndId = ind.IndId
	) dt)

	INSERT INTO #tmpAttribute (AttributeGroup,Attribute,Individuals,TotalInd,IndPercent,GroupBy)
	SELECT AttributeGroup,Attribute,Individuals,TotalInd,(CAST(Individuals AS DECIMAL)/TotalInd)*100 AS IndPercent,GroupBy 
	FROM (
	SELECT tc.ID AS TypeCodeID, tc.Description AS AttributeGroup,ad.Description AS Attribute, COUNT(ina.IndId) AS Individuals,
				@TotalInd AS TotalInd,
				CASE @GroupBy WHEN 0 THEN 'Company' 
					WHEN 1 THEN po.Department
					WHEN 2 THEN tdi.Description
					WHEN 3 THEN tlo.Description
					WHEN 4 THEN tpr.Description END AS GroupBy
	FROM dbo.tblHrTypeCode tc
	INNER JOIN dbo.tblHrIndAttribute ina ON ina.AttributeGroupTypeCodeID = tc.ID
	INNER JOIN dbo.tblHrIndGenInfo ig ON ig.IndId = ina.IndId
	LEFT JOIN dbo.tblHrIndPosition inp ON inp.IndId = ig.IndId 
	LEFT JOIN #IndPositionID ip ON ip.IndId = ig.IndId AND ip.PositionID = inp.ID
	INNER JOIN #IndStatus ins ON ins.IndId = ig.IndId
	INNER JOIN dbo.tblHrAttributeGroupDetail ad ON ad.ID = ina.AttributeGroupDetailID
	LEFT JOIN dbo.tblHrPosition po ON po.ID = inp.PositionID
	LEFT JOIN dbo.tblHrTypeCode tdi ON po.DivisionTypeCodeID = tdi.ID
	LEFT JOIN dbo.tblHrTypeCode tlo ON po.LocationTypeCodeID = tlo.ID
	LEFT JOIN dbo.tblHrTypeCode tpr ON po.ProgramTypeCodeID = tpr.ID
	 WHERE tc.TableId = 2 AND (@AttrDateFrom IS NULL OR @AttrDateFrom <= ina.AttributeDate)
			AND (@AttrDateThru IS NULL OR @AttrDateThru >= ina.AttributeDate)
	 GROUP BY CASE @GroupBy WHEN 0 THEN 'Company'
			WHEN 1 THEN po.Department
			WHEN 2 THEN tdi.Description
			WHEN 3 THEN tlo.Description
			WHEN 4 THEN tpr.Description END,tc.Description,tc.ID,ad.Description)ds
			INNER JOIN #tblTempTypeCode tc ON tc.ID = ds.TypeCodeID

	UPDATE temp SET TotalAttr = ds.Total
	FROM #tmpAttribute temp
	INNER JOIN(
	SELECT GroupBy,AttributeGroup, SUM(Individuals) AS Total FROM #tmpAttribute GROUP BY GroupBy,AttributeGroup)ds
	ON ISNULL(temp.GroupBy,'') = ISNULL(ds.GroupBy,'') AND temp.AttributeGroup = ds.AttributeGroup

	SELECT *,(CAST(Individuals AS DECIMAL)/TotalAttr)*100 AS AttrPercent FROM #tmpAttribute

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRAttributeCensusReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRAttributeCensusReport_proc';

