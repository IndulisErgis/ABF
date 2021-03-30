
CREATE PROCEDURE [dbo].[trav_HRIndividualList_proc]
@DateFROM DATETIME ,
@optActive TINYINT,
@PAYear SMALLINT,
@DeptIdFrom pDeptId,
@DeptIdThru pDeptId

AS
SET NOCOUNT ON
BEGIN TRY

	--Identify active positions
	CREATE TABLE #IndPositionID ([IndId] [pEmpID], [IndPositionID] [bigint], PRIMARY KEY (IndId))
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @DateFROM

	--Identify Status entries for reporting
	CREATE TABLE #IndStatus ([IndId] [pEmpID] NOT NULL, [StatusID] BIGINT NULL, [IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @DateFROM, @optActive

	--Apply department filtering for valid individuals for the report
	CREATE TABLE #tempIndividuals (IndId [pEmpID], IndStatus tinyint)
	INSERT INTO #tempIndividuals (IndId, IndStatus)
	SELECT DISTINCT g.IndId, ts.IndStatus
		FROM dbo.tblHrIndGenInfo g 
		LEFT JOIN dbo.tblHRIndPosition ip ON g.IndId = ip.IndId
		LEFT JOIN #IndPositionID tpos ON ip.IndId = tpos.IndId AND ip.ID = tpos.IndPositionID
		LEFT JOIN #IndStatus ts ON g.IndId = ts.IndId
		LEFT JOIN dbo.tblHrPosition p ON p.ID = ip.PositionID
		LEFT JOIN dbo.tblHrIndStatus a ON ts.IndId = a.IndId AND ts.[StatusID] = a.ID
		WHERE (@DeptIdFrom IS NULL OR @DeptIdThru IS NULL OR (p.Department BETWEEN @DeptIdFrom AND @DeptIdThru))
		AND (@optActive = 0 OR (@optActive = 1 AND ts.IndStatus = @optActive) OR (@optActive = 2 AND ts.IndStatus = 0))


	--select individual general information
	SELECT g.IndId, p.[Department] AS [DeptId], ISNULL(g.LastName, N'') + N', ' + ISNULL(g.FirstName, N'') + N' ' + ISNULL(g.MiddleInit, N'') EmployeeName
		, d.DepartmentName, g.Address1, g.Address2, g.City, g.[State], g.ZipCode, g.CountryCode, g.HomePhone, g.StartDate, g.DOB
		, g.SSN, g.Manager, r.StandardID AS [IndStatus], g.GenderTypeCodeID, g.MaritalStatusTypeCodeID, g.BusinessPhone
		, g.BusinessExtension, g.TerminationDate, g.EthnicityTypeCodeID, g.VeteranStatusTypeCodeID
		, e.[Description] EthnicityName, x.[Description] GenderName, m.[Description] MaritalStatusName, v.[Description] VeteranStatusName
		, CASE WHEN g.Manager IS NOT NULL 
			THEN ISNULL(i.LastName, N'') + N', ' + ISNULL(i.FirstName, N'') + N' ' + ISNULL(i.MiddleInit, N'') 
			ELSE N'No Manager' END [ManagerName]
		, g.WorkEMail, g.HomeEmail, g.Internet, g.EmergencyContact, g.ContactWorkPhone
		, g.ContactHomePhone, g.ContactRelation, g.CorporateOfficer, g.SeASonalEmployee
		, g.StatutoryEmployee, lc.[Description] LaborClassName, g.CellPhone, g.ContactCellPhone, pict.PictItem
		, CASE g.PayDistribution WHEN 0 THEN N'None' WHEN 1 THEN N'Amount' WHEN 2 THEN N'Percent' END [PayDistribution]
		FROM #tempIndividuals iList  
		 INNER JOIN #IndividualList ind ON ind.[IndID] = iList.IndId 
		INNER JOIN dbo.tblHrIndGenInfo g on iList.IndId = g.IndId
		LEFT JOIN #IndStatus tstat ON g.IndId = tstat.IndId
		LEFT JOIN dbo.tblHrIndStatus a ON tstat.IndId = a.IndId AND tstat.StatusID = a.ID
		LEFT JOIN dbo.tblHrTypeCode r ON a.IndStatusTypeCodeID = r.[Id]
		LEFT JOIN #IndPositionID tpos ON g.IndId = tpos.IndId
		LEFT JOIN dbo.tblHrIndPosition p1 ON tpos.IndPositionID = p1.ID
		LEFT JOIN dbo.tblHrPosition p on p1.PositionID = p.ID
		LEFT JOIN dbo.tblPaDept d on p.[Department] = d.Id
		LEFT JOIN dbo.tblHrIndGenInfo i ON g.[Manager] = i.[IndId]
		LEFT JOIN dbo.tblHRTypeCode e ON g.EthnicityTypeCodeID = e.ID
		LEFT JOIN dbo.tblHRTypeCode x ON g.GENDerTypeCodeID = x.ID
		LEFT JOIN dbo.tblHRTypeCode m ON g.MaritalStatusTypeCodeID = m.ID
		LEFT JOIN dbo.tblHRTypeCode u ON g.CitizenshipTypeCodeID = u.ID
		LEFT JOIN dbo.tblHRTypeCode v ON g.VeteranStatusTypeCodeID = v.ID
		LEFT JOIN dbo.tblPaLaborClass lc ON g.LaborClass = lc.Id
		LEFT JOIN dbo.tblHRIndPict pict ON g.IndId = pict.IndId																																																										
	 
 	-- Process 
	SELECT p.IndId, pro.[Description] AS CheckListItem
		, CASE WHEN p.PersonResponsible IS NOT NULL 
			THEN ISNULL(i2.LastName, N'') + N', ' + ISNULL(i2.FirstName, N'') + N' ' + ISNULL(i2.MiddleInit, N'') 
			ELSE NULL END [PersonResponsible]
		, p.[Status], DateCompleted, p.ProcessTypeCodeId, t.[Description], p.ProcessGroupDetailID
	FROM  dbo.tblHRIndProcess p 
	    INNER JOIN #IndividualList ind ON ind.IndId = p.IndId 	
		INNER JOIN #tempIndividuals ti ON ti.IndId = p.IndId
		INNER JOIN tblHRProcessGroupDetail pro ON p.ProcessGroupDetailID = pro.ID
		INNER JOIN dbo.tblHrIndGenInfo i2 ON p.PersonResponsible = i2.IndId 
		LEFT JOIN tblHrTypeCode t ON p.ProcessTypeCodeId = t.ID	
			
	-- Salary 
	--PayType is the Enum  0= Hourly,1 = Salaried
	SELECT s.IndId, EffectiveDate, Reason, Salary, HourlyRate, CASE WHEN s.PayType = 1 THEN 'Salaried' ELSE 'Hourly' END AS PayType, ExemptFROMOvertime
		FROM dbo.tblHRIndSalary s 
		INNER JOIN #tempIndividuals ti ON s.IndId = ti.IndId
		INNER JOIN #IndividualList ind ON ind.IndId = s.IndId
		--INNER JOIN #tempIndividuals ti ON ind.IndId = ti.IndId

	-- Position
	SELECT p.IndId, p.StartDate, p.PositionID, pos.[Description] AS PositionNoDescr, PrimaryPosition, EndDate, cr.[Description] AS ChangeReASon
		, t.[Description] AS JobDescription, cat.[Description] AS CategoryDescription, pos.Department DeptId
		FROM dbo.tblHRIndPosition p 
		INNER JOIN #tempIndividuals ti ON p.IndId = ti.IndId
		INNER JOIN dbo.tblHRPosition pos ON p.PositionID = pos.ID
		INNER JOIN dbo.tblHRJobTitle t ON pos.JobTypeCodeID = t.ID
		LEFT JOIN tblHRTypeCode cat ON t.JobCatTypeCodeID = cat.ID and cat.TableID = 19
		LEFT JOIN tblHRTypeCode cr ON p.ChangeReASonTypeCodeID = cr.ID and cr.TableID = 23
	    INNER JOIN #IndividualList ind ON ind.IndId = p.IndId 

	 -- Activity
	SELECT a.IndId, a.ActivityDate, a.[Description], Notes, ac.[Description] Activity
		FROM dbo.tblHRIndActivity a 
		INNER JOIN #tempIndividuals ti ON a.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode ac ON a.ActivityTypeCodeId = ac.ID
		INNER JOIN #IndividualList ind ON ind.IndId = a.IndId 

	-- Review
	SELECT r.IndId, ReviewDate, r.ReviewTypeID, t1.[Description] AS ReviewTypeDescr, NextReviewDate, Notes, NextReviewTypeID
		, ISNULL(sc.OverallScore, 0) AS [OverallScore], nd.[Description]
		FROM dbo.tblHRIndReview r 
		INNER JOIN #tempIndividuals ti ON r.IndId = ti.IndId
		INNER JOIN dbo.tblHRReviewType t1 ON r.ReviewTypeID = t1.ID
		LEFT JOIN dbo.tblHRReviewType nd ON r.NextReviewTypeID = nd.ID
		LEFT JOIN (SELECT ReviewId, SUM(Score) OverallScore FROM dbo.tblHRIndReviewbyCategory GROUP BY ReviewId) sc ON r.ID = sc.ReviewId
		INNER JOIN #IndividualList ind ON ind.IndId = r.IndId 

	-- Skills
	SELECT s.IndId, s.ID, s.SkillTypeCodeID, DateAcquired, Notes, [Hours], t1.[Description] SkillDescription
		FROM dbo.tblHRIndSkill s 
		INNER JOIN #tempIndividuals ti ON s.IndId = ti.IndId
		INNER JOIN dbo.tblHRTypeCode t1 ON s.SkillTypeCodeID = t1.ID
	    INNER JOIN #IndividualList ind ON ind.IndId = s.IndId 

	-- Tests
	SELECT t.IndId, t.TestTypeID, DateAcquired, Score, RecertificationDate, t1.[Description] TestDesc, t1.RecertificationMonths [RecMonths]
		FROM dbo.tblHRIndTest t 
		INNER JOIN #tempIndividuals ti ON t.IndId = ti.IndId
		INNER JOIN dbo.tblHRTestType t1 ON t.TestTypeID = t1.ID
		INNER JOIN #IndividualList ind ON ind.IndId = t.IndId 

	-- Degrees
	SELECT d.IndId, DateAcquired, Notes, t1.[Description] DegreeType
		FROM dbo.tblHRIndDegree d 
		INNER JOIN #tempIndividuals ti ON d.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode t1 ON DegreeTypeCodeID = t1.ID 
		INNER JOIN #IndividualList ind ON ind.IndId = d.IndId 

	-- Licenses
	SELECT l.IndId, LicenseNo, LicenseExpDate, LicenseComment, LicenseState, t1.[Description] LicenseType
		FROM dbo.tblHRIndLicense l 
		INNER JOIN #tempIndividuals ti ON l.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode t1 ON LicenseTypeCodeID = t1.ID
	    INNER JOIN #IndividualList ind ON ind.IndId = l.IndId 

	--Training
	SELECT t.IndId, DateAcquired, Notes, [Hours], Score, EventCost, TravelCost, Approver, t.DeptId, d.DepartmentName
		, t1.[Description] TrainingCode, t2.[Description] TrainingType
		FROM dbo.tblHrIndTraining t 
		INNER JOIN #tempIndividuals ti ON t.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode t1 ON TrainingCodeID = t1.ID
		LEFT JOIN dbo.tblHRTypeCode t2 ON TrainingTypeID = t2.ID
		LEFT JOIN dbo.tblPaDept d ON t.DeptId = d.Id
        INNER JOIN #IndividualList ind ON ind.IndId = t.IndId 

	 --Attribute
	SELECT a.IndId, a.AttributeGroupDetailID, AttributeDate, Note, Amount1, Amount2, t1.[Description] AttributeGroup, ag.[Description] AS Attribute
		FROM dbo.tblHRIndAttribute a 
		INNER JOIN dbo.tblHrAttributeGroupDetail ag ON a.AttributeGroupDetailID = ag.ID 
		INNER JOIN #tempIndividuals ti ON a.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode t1 ON a.AttributeGroupTypeCodeID = t1.ID
		INNER JOIN #IndividualList ind ON ind.IndId = a.IndId

	--FMLA
	SELECT f.IndId, NotifyDate, ERResponseDate, DesigNoticeDate, LeaveBegDate, ExpReturnDate, MedCertDueDate, MedCertRecDate, MedReCertDate, ExpDate
		, Intermittent, MedCertReq, WorkRelated, DeliveryCmnt, FMLANote, FMLAHrsPerWeek, t1.[Description] AS LeaveReASon, t2.[Description] AS DeliveryMethod
		, t3.[Description] LeaveType, t4.[Description] AS [Location], t5.[Description] AS [FMLAStatus]
		FROM dbo.tblHRIndFMLA f 
		INNER JOIN #tempIndividuals ti ON f.IndId = ti.IndId
		LEFT JOIN tblHRTypeCode t1 ON LeaveReASonTypeCodeID = t1.ID
		LEFT JOIN tblHRTypeCode t2 ON DeliveryMethodTypeCodeID = t2.ID
		LEFT JOIN tblHRTypeCode t3 ON LeaveTypeCodeID = t3.ID
		LEFT JOIN tblHRTypeCode t4 ON LocationTypeCodeID = t4.ID
		LEFT JOIN tblHRTypeCode t5 ON FMLAStatusTypeCodeID = t5.ID	
		INNER JOIN #IndividualList ind ON ind.IndId = f.IndId

	-- Property
	SELECT p.IndId, pc.[Description] AS [PropertyCode], p.StartDate, p.[Description], p.[Value], p.SerialNumber, p.ENDDate
		FROM dbo.tblHRIndProperty p 
		INNER JOIN #tempIndividuals ti ON p.IndId = ti.IndId
		INNER JOIN dbo.tblHRPropertyCode pc ON p.PropertyCodeID = pc.ID
		INNER JOIN #IndividualList ind ON ind.IndId = p.IndId

	-- Dependents
	SELECT d.IndId, d.ID, d.SSN, d.DOB, LastName, FirstName, FullTimeStudent, d.GenderTypeCodeID, Smoker, g.[Description] AS Gender, r.[Description] AS RelationType
		FROM dbo.tblHRIndDependent d 
		INNER JOIN #tempIndividuals ti ON d.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode r ON d.RelationTypeCodeID = r.ID
		LEFT JOIN dbo.tblHRTypeCode g ON d.GenderTypeCodeID = g.ID
		INNER JOIN #IndividualList ind ON ind.IndId = d.IndId

	-- Health Insurance
	SELECT h.IndId, h.ID, BenefitStartDate, PolicyNumber, BenefitENDDate, hi.CarrierTypeCodeID, GroupNumber, EmployeeContribution, EmployerContribution
		, MaximumAgeEmployee, MaximumAgeDepENDent, WaitingPeriod, MaxOutOfPocket, Deductible, MaxBenefit, MajorMedicalCoverage, COBRAPremium
		, hi.[Description] AS BenefitDescription, f.[Description] AS Frequency, hcp.[Description] AS CoPayDescr, hcp.Amount
		, DATEADD(d, WaitingPeriod, g.StartDate) AS EligibilityDate, c.[Description] AS CarrierDescription
		FROM dbo.tblHRIndHealth h 
		INNER JOIN #tempIndividuals ti ON h.IndId = ti.IndId
		INNER JOIN dbo.tblHRIndGenInfo g ON h.IndId = g.Indid
		INNER JOIN dbo.tblHRHealthInsurance hi ON h.HealthInsID = hi.ID
		LEFT JOIN dbo.tblHRHealthCoPay hcp ON hi.ID = hcp.HealthInsID
		LEFT JOIN dbo.tblHRTypeCode f ON hi.FrequencyTypeCodeID = f.ID
		LEFT JOIN dbo.tblHRTypeCode c ON hi.CarrierTypeCodeID = c.ID
		INNER JOIN #IndividualList ind ON ind.IndId = h.IndId
		
	-- Life Insurance
	SELECT DISTINCT l.IndId, l.ID, PolicyNumber, BenefitStartDate, BenefitENDDate, CoverageSelf, CoverageSpouse, CoverageChild, Smoker
		, Beneficiary1, Beneficiary2, BeneficiaryRelation1, BeneficiaryRelation2, BeneficiaryPct1, BeneficiaryPct2
		, Contingency1, Contingency2, ContingencyRelation1, ContingencyRelation2, ContingencyPct1, ContingencyPct2
		, li.[Description] AS BenefitDescription, li.CarrierTypeCodeID, GroupNumber
		, CoverageMaxAmount, WaitingPeriod, f.[Description] AS Frequency, c.[Description] AS Carrier
		, Deduct.EmployerSelf, Deduct.EmployerSpouse, Deduct.EmployerChild
		, Deduct.EmployeeSelf, Deduct.EmployeeSpouse, Deduct.EmployeeChild
		, DATEADD(d, li.WaitingPeriod, g.StartDate) EligibilityDate
		FROM dbo.tblHRIndLifeIns l 
		INNER JOIN #tempIndividuals ti ON l.IndId = ti.IndId
		INNER JOIN dbo.tblHRIndGenInfo g on l.IndId = g.IndId
		INNER JOIN dbo.tblHRLifeInsurance li on l.LifeInsID = li.ID
		LEFT JOIN dbo.tblHRTypeCode f on li.FrequencyTypeCodeID = f.ID
		LEFT JOIN dbo.tblHRTypeCode c on li.CarrierTypeCodeID = c.ID
		INNER JOIN #IndividualList ind ON ind.IndId = l.IndId 
		Left JOIN(
			SELECT l.LifeInsID,l.IndId, 
			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN l.Smoker = 1 THEN p.SelfSEmployerAmount * l.CoverageSelf 
				ELSE p.SelfNSEmployerAmount * l.CoverageSelf END,0) EmployerSelf,
			
			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN d.SmokerSpouse IS NULL THEN l.CoverageSpouse WHEN d.SmokerSpouse = 1 THEN p.SpouseSEmployerAmount * l.CoverageSpouse ELSE 
			 p.SpouseNSEmployerAmount * l.CoverageSpouse END,0) EmployerSpouse,
	
			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN d.SmokerChild IS NULL THEN l.CoverageChild WHEN d.SmokerChild = 1 THEN p.ChildSEmployerAmount * l.CoverageChild ELSE
			 p.ChildNSEmployerAmount * l.CoverageChild END,0)  EmployerChild,

			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN l.Smoker = 1 THEN p.SelfSEmployeeAmount * l.CoverageSelf 
				ELSE p.SelfNSEmployeeAmount * l.CoverageSelf END,0) EmployeeSelf,

			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN d.SmokerSpouse IS NULL THEN l.CoverageSpouse WHEN d.SmokerSpouse = 1 THEN p.SpouseSEmployeeAmount * l.CoverageSpouse ELSE
			p.SpouseNSEmployeeAmount * l.CoverageSpouse END,0) EmployeeSpouse,
	
			ISNULL(CASE WHEN p.ID IS NULL THEN 0 WHEN d.SmokerChild IS NULL THEN l.CoverageChild WHEN d.SmokerChild = 1 THEN p.ChildSEmployeeAmount * l.CoverageChild ELSE
			p.ChildNSEmployeeAmount * l.CoverageChild END,0) EmployeeChild

			FROM dbo.tblHRIndLifeIns l
			INNER JOIN dbo.tblHRIndGenInfo g ON g.IndId = l.IndId 
			INNER JOIN dbo.tblHRLifeInsurance i ON l.LifeInsID = i.ID 
			LEFT JOIN dbo.tblHRLifeInsSub p ON l.LifeInsID = p.LifeInsID 
				AND p.MaxAge IN(	
						SELECT MIN(MaxAge) FROM dbo.tblHRLifeInsSub 
						WHERE (i.PremiumMethod = 0 OR MaxAge > DATEDIFF(year, g.DOB, GETDATE())) AND  p.LifeInsID = l.LifeInsID 
						GROUP BY LifeInsID)
			LEFT JOIN (
				SELECT IndId, MAX(SChild) SmokerChild, MAX(SSpouse) SmokerSpouse, MAX(SSelf) SmokerSelf
				FROM(SELECT  dep.IndId, 
				CASE WHEN T.StandardID != 46 THEN NULL WHEN T.StandardID = 46 and dep.Smoker = 1 THEN 1 ELSE 0 END SChild, 
				CASE WHEN T.StandardID != 47 THEN NULL WHEN T.StandardID = 47 and dep.Smoker = 1 THEN 1 ELSE 0 END SSpouse,
				CASE WHEN T.StandardID != 48 THEN NULL WHEN T.StandardID = 48 and dep.Smoker = 1 THEN 1 ELSE 0 END SSelf
				FROM dbo.tblHRIndDepENDent dep
				INNER JOIN dbo.tblHRTypeCode t ON t.ID = dep.RelationTypeCodeID
				GROUP BY T.StandardID, IndId, dep.Smoker)ds GROUP BY IndId ) d ON l.IndId = d.IndId
		) Deduct on Deduct.LifeInsID =  l.LifeInsID and Deduct.IndId = l.IndId

	SELECT MIN(MaxAge) AS MaxAge
		FROM dbo.tblHRIndLifeIns l
		INNER JOIN dbo.tblHRIndGenInfo g ON g.IndId = l.IndId 
		INNER JOIN dbo.tblHRLifeInsurance i ON l.LifeInsID = i.ID 
		INNER JOIN #tempIndividuals ti ON l.IndId = ti.IndId
		LEFT JOIN dbo.tblHRLifeInsSub p ON l.LifeInsID = p.ID 
		WHERE MaxAge > DATEDIFF(year, g.DOB, GETDATE()) AND p.ID = l.LifeInsID 
		GROUP BY p.ID,MaxAge
  
	--Retirement
	SELECT r.IndId, r.ID, r.RetPlanID,r.StartDate,ENDDate,tc.[Description] AllocationMethod
		, PreTaxNumber, AfterTaxNumber, BonusNumber, LoanAmount, AccountNumber, EmployerMatchPercent
		, EmployerMaxMatch, MinimumAge, WaitingPeriod, MaxContribution, LoansAllowed, rp.[Description] AS PlanDescription
		, rfa.RetFundID, Allocation, fnd.[Description], Active, DATEADD(d,rp.WaitingPeriod,g.StartDate) EligibilityDate
		, f.[Description] AS Frequency, t.[Description] AS Trustee
		FROM tblHRIndRetirement r 
		INNER JOIN #tempIndividuals ti ON r.IndId = ti.IndId
		INNER JOIN dbo.tblHRIndGenInfo g ON r.IndId = g.Indid
		INNER JOIN dbo.tblHRRetirementPlan rp ON r.RetPlanID = rp.ID
		LEFT JOIN dbo.tblHRIndRetFundAllocation rfa ON rfa.RetirementId = r.ID
		LEFT JOIN dbo.tblHRRetirementFund fnd ON rfa.RetFundID = fnd.ID
		LEFT JOIN dbo.tblHRTypeCode f ON rp.FrequencyTypeCodeID = f.ID
		LEFT JOIN dbo.tblHRTypeCode t ON rp.TrusteeTypeCodeID = t.ID
		LEFT JOIN dbo.tblHRTypeCode tc ON r.AllocMethodTypeCodeID = tc.ID
    	INNER JOIN #IndividualList ind ON ind.IndId = r.IndId

	--Federal Tax
	SELECT w.IndId, w.ID, TaxAuthorityId, w.MaritalStatus, Exemptions, ExtraWithholding, FixedWithholding, h.[State] AS [HomeState], DefaultWH, SUIState, EICCode, [Description] AS TaxAuthority
		FROM dbo.tblHRIndWithhold w 
		INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id
		INNER JOIN #IndividualList ind ON ind.IndId = w.IndId 
		WHERE h.[Type] = 0
  
	--Federal Tax Exclusions
	SELECT w.ID, e.Code, e.EmployerPaid, d.[Description]
		FROM dbo.tblHRIndExclude e 
		INNER JOIN dbo.tblHRIndWithhold w ON e.WithholdId = w.ID
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 0
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON e.Code = d.Code and e.EmployerPaid = d.EmployerPaid and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear )
		INNER JOIN #tempIndividuals ti ON e.IndId = ti.IndId
		INNER JOIN #IndividualList ind ON ind.IndId = e.IndId 

	--Federal Tax Factors
	SELECT w.ID, w.TaxAuthorityId, o.Code,o.EmployerPaid
		, OverrideFactor1, OverrideFactor2, OverrideFactor3, OverrideFactor4, OverrideFactor5
		, OverrideFactor6, OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10
		, OverrideFactor11, OverrideFactor12, OverrideFactor13, OverrideFactor14, OverrideFactor15
		, OverrideFactor16, OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20
		FROM dbo.tblHRIndOverrideFactors o 
		INNER JOIN dbo.tblHRIndWithhold w ON o.WithholdId = w.ID
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 0
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON o.Code = d.Code and o.EmployerPaid = d.EmployerPaid and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear )
		INNER JOIN #tempIndividuals ti ON o.IndId = ti.IndId
		INNER JOIN #IndividualList ind ON ind.IndId = o.IndId 

	--State Tax
	SELECT w.IndId, w.ID, TaxAuthorityId, w.MaritalStatus, Exemptions, ExtraWithholding, FixedWithholding, h.[State] AS [HomeState], DefaultWH, SUIState, EICCode, [Description] AS TaxAuthority
	  FROM dbo.tblHRIndWithhold w 
	  INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
	  INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id
      INNER JOIN #IndividualList ind ON ind.IndId = w.IndId
	  WHERE h.[Type] = 1

	--State Tax Exclusions
	SELECT w.ID, e.Code, e.EmployerPaid
		FROM dbo.tblHRIndExclude e 
		INNER JOIN dbo.tblHRIndWithhold w ON e.WithholdId = w.ID
		INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 1
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON e.Code = d.Code and e.EmployerPaid = d.EmployerPaid and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear )
		INNER JOIN #IndividualList ind ON ind.IndId = e.IndId 

	--State Tax Factors
	SELECT w.ID, w.TaxAuthorityId, o.Code,o.EmployerPaid
		, OverrideFactor1, OverrideFactor2, OverrideFactor3, OverrideFactor4, OverrideFactor5
		, OverrideFactor6, OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10
		, OverrideFactor11, OverrideFactor12, OverrideFactor13, OverrideFactor14, OverrideFactor15
		, OverrideFactor16, OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20
		FROM dbo.tblHRIndOverrideFactors o 
		INNER JOIN dbo.tblHRIndWithhold w ON o.WithholdId = w.ID
		INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId	
		INNER JOIN #IndividualList ind ON ind.IndId = o.IndId 
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 1
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON o.Code = d.Code and o.EmployerPaid = d.EmployerPaid 
		and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear )

	--Local Tax
	SELECT w.IndId, w.ID, TaxAuthorityId, w.MaritalStatus, Exemptions, ExtraWithholding, FixedWithholding, h.[State] AS [HomeState], DefaultWH, SUIState, EICCode, [Description] AS TaxAuthority, h.TaxAuthority [TaxName]
		FROM dbo.tblHRIndWithhold w 
		INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id
        INNER JOIN #IndividualList ind ON ind.IndId = w.IndId 
		WHERE h.[Type] = 2
  
	--Local Tax Exclusions
	SELECT w.ID, e.Code, e.EmployerPaid
		FROM dbo.tblHRIndExclude e 
		INNER JOIN dbo.tblHRIndWithhold w ON e.WithholdId = w.ID
		--INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 2
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON e.Code = d.Code and e.EmployerPaid = d.EmployerPaid and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear )
	 	INNER JOIN #IndividualList ind ON ind.IndId = e.IndId
		INNER JOIN #tempIndividuals ti2 ON ind.IndId = ti2.IndId


	--Local Tax Factors
	SELECT w.ID, w.TaxAuthorityId, o.Code,o.EmployerPaid
		, OverrideFactor1, OverrideFactor2, OverrideFactor3, OverrideFactor4, OverrideFactor5
		, OverrideFactor6, OverrideFactor7, OverrideFactor8, OverrideFactor9, OverrideFactor10
		, OverrideFactor11, OverrideFactor12, OverrideFactor13, OverrideFactor14, OverrideFactor15
		, OverrideFactor16, OverrideFactor17, OverrideFactor18, OverrideFactor19, OverrideFactor20	
		FROM dbo.tblHRIndOverrideFactors o 
		INNER JOIN dbo.tblHRIndWithhold w ON o.WithholdId = w.ID
		--INNER JOIN #tempIndividuals ti ON w.IndId = ti.IndId
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON w.TaxAuthorityId = h.Id and h.[Type] = 2
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON o.Code = d.Code and o.EmployerPaid = d.EmployerPaid and w.TaxAuthorityId = d.TaxAuthorityId and (@PAYear = NULL OR d.PaYear = @PAYear ) 
		INNER JOIN #IndividualList ind ON ind.IndId = o.IndId
		INNER JOIN #tempIndividuals ti2 ON ind.IndId = ti2.IndId

	--Direct Deposit
	SELECT d.IndId
		, CASE AccountType WHEN 0 THEN N'Paycheck' WHEN 1 THEN N'Checking' WHEN 2 THEN N'Savings' END AccountType
		, AccountNumber, RoutingCode, AmountPercent
		FROM dbo.tblHrIndPayDistribution d 
		INNER JOIN #tempIndividuals ti ON d.IndId = ti.IndId
		INNER JOIN #IndividualList indT ON d.IndId = indT.IndId

	--Status
	SELECT s.IndId, s.StartDate, GroupCode, sc.[Description] AS [Status], l.[Description] AS LeavePlan
		FROM dbo.tblHRIndStatus s 
		INNER JOIN #tempIndividuals ti ON s.IndId = ti.IndId
		LEFT JOIN dbo.tblHRTypeCode sc ON s.IndStatusTypeCodeID = sc.ID
		LEFT JOIN dbo.tblHRLeavePlan l ON s.LeavePlanID = l.ID
		INNER JOIN #IndividualList indT ON s.IndId = indT.IndId

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndividualList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndividualList_proc';

