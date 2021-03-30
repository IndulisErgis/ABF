
CREATE PROCEDURE [dbo].[trav_HRLifeInsEnrollment_proc]
@AsOfDate DATE,
@DepartmentFrom pDeptID,
@DepartmentThru pDeptID,
@IndStatus TINYINT,
@SortBy TINYINT

AS
SET NOCOUNT ON
BEGIN TRY
	CREATE TABLE #IndividualList ([IndID] [pEmpId], Primary Key ([IndID]))
	INSERT INTO #IndividualList SELECT ind.IndId FROM tblHrIndGenInfo ind

	CREATE TABLE #IndPositionID ([IndId] [pEmpID], [PositionID] [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @AsOfDate

	CREATE TABLE #IndStatus ([IndId] [pEmpID] NOT NULL, [StatusID] BIGINT NULL, [IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @AsOfDate, @IndStatus

	CREATE TABLE #IndDependents([IndId] [pEmpID], [LifeInsID] [BIGINT], [StandardID] BIGINT, [Smoker] TINYINT, [NonSmoker] TINYINT, [Age] TINYINT)

	--identify the individual as a dependent
	INSERT INTO #IndDependents ([IndId], [LifeInsID], [StandardID], [Smoker], [NonSmoker], [Age])
	SELECT ind.IndId, ils.LifeInsID, 48, CAST(ils.Smoker AS TINYINT), CAST(~ils.Smoker AS TINYINT)
		, CASE WHEN ind.DOB IS NULL OR ind.DOB > @AsOfDate THEN 0 ELSE FLOOR(DATEDIFF(D, ind.DOB, @AsOfDate) / 365.25) END
		FROM dbo.tblHRIndGenInfo ind
		INNER JOIN dbo.tblHRIndLifeIns ils ON ind.IndID = ils.IndID
		INNER JOIN #IndPositionID tpos ON ind.IndId = tpos.IndId
		INNER JOIN #IndStatus ts ON ind.IndId = ts.IndId

	--identify the non-self dependents (Spouse/Child)
	INSERT INTO #IndDependents ([IndId], [LifeInsID], [StandardID], [Smoker], [NonSmoker], [Age])
	SELECT ide.IndId, ils.LifeInsID, tc.StandardID, CAST(ide.Smoker AS TINYINT), CAST(~ide.Smoker AS TINYINT)
		, CASE WHEN ide.DOB IS NULL OR ide.DOB > @AsOfDate THEN 0 ELSE FLOOR(DATEDIFF(D, ide.DOB, @AsOfDate) / 365.25) END AS [Age]
		FROM dbo.tblHrIndDependent ide
		INNER JOIN dbo.tblHRIndLifeIns ils ON ide.IndID = ils.IndID
		INNER JOIN dbo.tblHrTypeCode tc ON tc.ID = ide.RelationTypeCodeID
		INNER JOIN #IndPositionID tpos ON tpos.IndId = ide.IndId
		INNER JOIN #IndStatus ts ON tpos.IndId = ts.IndId
		WHERE tc.StandardID = 47 OR tc.StandardID = 46

	--retrieve the results
	SELECT iamt.ID, iamt.LifeInsID, iamt.IndId
		, ISNULL(ind.LastName, '') + ', ' + ISNULL(ind.FirstName, '') + ' ' + ISNULL(ind.MiddleInit, '') AS [Name]
		, po.Department, ind.Manager, iamt.PolicyNumber
		, SUM(SelfEmployerAmount + SpouseEmployerAmount + ChildEmployerAmount) AS EmployerAmount
		, SUM(SelfEmployeeAmount + SpouseEmployeeAmount + ChildEmployeeAmount) AS EmployeeAmount
		, ins.[Description], ins.GroupNumber
		, CASE @SortBy 
			WHEN 0 THEN ins.[Description]
			WHEN 1 THEN po.Department
			WHEN 2 THEN ind.Manager END AS [SortBy]
	FROM (
		SELECT inl.ID, idep.LifeInsId, idep.IndId, inl.PolicyNumber
			, CASE WHEN idep.StandardID = 48 
				THEN (SelfSEmployerAmount * idep.Smoker * inl.CoverageSelf) + (SelfNSEmployerAmount * idep.NonSmoker * inl.CoverageSelf) 
				ELSE 0 END AS SelfEmployerAmount
			, CASE WHEN idep.StandardID = 48 
				THEN (SelfSEmployeeAmount * idep.Smoker * inl.CoverageSelf) + (SelfNSEmployeeAmount * idep.NonSmoker * inl.CoverageSelf)
				ELSE 0 END AS SelfEmployeeAmount
			, CASE WHEN idep.StandardID = 47
				THEN (SpouseSEmployerAmount * idep.Smoker * inl.CoverageSpouse) + (SpouseNSEmployerAmount * idep.NonSmoker * inl.CoverageSpouse) 
				ELSE 0 END AS SpouseEmployerAmount
			, CASE WHEN idep.StandardID = 47 
				THEN (SpouseSEmployeeAmount * idep.Smoker * inl.CoverageSpouse) + (SpouseNSEmployeeAmount * idep.NonSmoker * inl.CoverageSpouse) 
				ELSE 0 END AS SpouseEmployeeAmount
			, CASE WHEN idep.StandardID = 46
				THEN (ChildSEmployerAmount * idep.Smoker * inl.CoverageChild) + (ChildNSEmployerAmount * idep.NonSmoker * inl.CoverageChild) 
				ELSE 0 END AS ChildEmployerAmount
			, CASE WHEN idep.StandardID = 46 
				THEN (ChildSEmployeeAmount * idep.Smoker * inl.CoverageChild) + (ChildNSEmployeeAmount * idep.NonSmoker * inl.CoverageChild) 
				ELSE 0 END AS ChildEmployeeAmount
		FROM #IndDependents idep
		INNER JOIN dbo.tblHRIndLifeIns inl ON idep.IndId = inl.IndID AND idep.LifeInsID = inl.LifeInsID
		INNER JOIN dbo.tblHrLifeInsurance ins ON idep.LifeInsID = ins.ID
		LEFT JOIN (SELECT ind.IndId, ind.LifeInsId, ind.[Age], MIN(lis.MaxAge) AS [MaxAge] 
			FROM #IndDependents ind
			INNER JOIN dbo.tblHRLifeInsSub lis ON ind.LifeInsID = lis.LifeInsID
			INNER JOIN dbo.tblHrLifeInsurance lih ON lis.LifeInsID = lih.ID
			WHERE ((lih.PremiumMethod = 1 AND lis.MaxAge > ind.[Age]) OR (lih.PremiumMethod = 0))
			GROUP BY ind.IndId, ind.LifeInsID, ind.[Age]) liMax ON idep.IndId = liMax.IndId AND idep.LifeInsID = liMax.LifeInsID AND idep.[Age] = liMax.[Age]
		LEFT JOIN dbo.tblHRLifeInsSub insSub ON liMax.LifeInsID = inssub.LifeInsID AND limax.MaxAge = inssub.MaxAge
	) iamt
	INNER JOIN dbo.tblHRIndGenInfo ind ON iamt.IndId = ind.IndID
	INNER JOIN dbo.tblHRLifeInsurance ins ON iamt.LifeInsID = ins.ID
	INNER JOIN #IndPositionID ipos ON ind.IndID = ipos.IndId
	INNER JOIN dbo.tblHrIndPosition ip ON ip.ID = ipos.PositionID
	LEFT JOIN dbo.tblHrPosition po ON ip.PositionID = po.ID
	WHERE (@DepartmentFrom IS NULL OR @DepartmentThru IS NULL OR (po.Department BETWEEN @DepartmentFrom AND @DepartmentThru))
	GROUP BY iamt.ID, iamt.LifeInsID, iamt.IndId, ind.LastName, ind.FirstName, ind.MiddleInit
		, po.Department, ind.Manager, iamt.PolicyNumber, ins.[Description], ins.GroupNumber
	


END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRLifeInsEnrollment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRLifeInsEnrollment_proc';

