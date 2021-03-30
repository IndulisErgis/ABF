
Create PROCEDURE dbo.trav_PaCalculateDepartmentAllocations_proc 
@UseHomeDepartment bit, 
@PrecCurr tinyint,
@PaYear smallint
AS
BEGIN TRY
	declare @DepartmentId [pDeptID]
	declare @WithholdingCode [pCode]
	declare @HomeYn  [bit]
	declare @EarningAmount [pDecimal]
	declare @Earningcode [pCode]
	declare @EarnCheckID int
	declare @GrossEarnings [pDecimal]
	declare @ExclEarningAmount pDecimal
	declare @EarnPerc pDecimal
	declare @WithholdingPayments [pDecimal]
	declare @WithholdingEarnings [pDecimal]
	declare @CheckId [pDecimal]
	declare @ExclDeductionAmount [pDecimal]
	declare @CheckEarnYN bit
	set @CheckId = 0
	set @WithholdingCode = ''
	set @EarningAmount = 0
	set @Earningcode = ''
	set @EarnCheckID = 0
	set @WithholdingPayments = 0
	set @WithholdingEarnings = 0
	set @GrossEarnings = 0
	
	select @CheckEarnYN = case when count(*) > 0 then 1 else 0 end from dbo.tblPaCheckEarn t INNER Join [dbo].[tblPaCheck] c ON c.[Id] = t.[CheckId] INNER JOIN #CheckList l ON c.[Id] = l.[CheckId] 
			

	IF @UseHomeDepartment = 0 and @CheckEarnYN > 0
	BEGIN 
		--worked department
		--Loop thru Check Employer Tax.
		declare curCheckEmplrTax cursor for 
		SELECT t.[CheckId], t.[WithholdingCode], t.[WithholdingPayments], t.[WithholdingEarnings], t.GrossEarnings as GrossEarnings
				FROM [dbo].[tblPaCheckEmplrTax] t
				INNER Join [dbo].[tblPaCheck] c ON c.[Id] = t.[CheckId]
				INNER JOIN #CheckList l ON c.[Id] = l.[CheckId] 
				order by CheckId,  EmployeeID, WithholdingCode 	
		for read only
		open curCheckEmplrTax
		fetch next from curCheckEmplrTax into
			@CheckId, @WithholdingCode, @WithholdingPayments, @WithholdingEarnings, @GrossEarnings
		While (@@FETCH_STATUS=0)
		BEGIN
			--Loop thru Check Earn for each Check Id
			DECLARE curEarnings CURSOR FOR 
			SELECT e.[CheckId]  as  EarnCheckID, e.[DepartmentId]
				, CASE WHEN ISNULL(e.[DepartmentId], '') = ISNULL(a.[DepartmentId], '') THEN 1 ELSE 0 END  as HomeYn
				, SUM(e.[EarningAmount]) EarningAmount, e.Earningcode
			FROM [dbo].[tblPaCheck] c 
			INNER JOIN #CheckList l ON c.[Id] = l.[CheckId]
			INNER JOIN [dbo].[tblPaCheckEarn] e ON c.[Id] = e.[CheckId]
			INNER JOIN [dbo].[tblPaEmployee] a ON c.[EmployeeId] = a.[EmployeeId]
			WHERE e.[CheckId] = @CheckId
			GROUP BY e.[CheckId], e.[DepartmentId], a.[DepartmentId],  e.Earningcode order by EarnCheckID, DepartmentId
			FOR READ Only
			OPEN curEarnings
			FETCH NEXT FROM curEarnings INTO 
				@EarnCheckID, @DepartmentId, @HomeYn, @EarningAmount, @Earningcode
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				set @ExclEarningAmount = 0
				set @EarnPerc  = 0
				set @ExclDeductionAmount  = 0

				Select @ExclDeductionAmount =  sum(s.ExclDeductionAmount) from
					(Select e.CheckId, e.DeductionCode, e.DeductionAmount as ExclDeductionAmount,  x.Code, x.DeductionCodeId, x.EmployerPaid
						From [dbo].[tblPaCheckdeduct] e
						INNER JOIN #CheckList l ON e.[CheckId] = l.[CheckId]
						INNER Join dbo.tblPaDeductCode d on e.DeductionCode = d.DeductionCode
						Left Join  (Select td.PaYear, td.Code, ex.DeductionCodeId, ex.TaxAuthorityDtlId, td.EmployerPaid
							from dbo.tblPaTaxAuthorityDetail td Inner Join 
							dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
							Inner Join dbo.tblPaTaxAuthorityExclusionDeduction ex on td.Id = ex.TaxAuthorityDtlId
							Inner Join dbo.tblPaDeductCode d on ex.DeductionCodeId =  d.Id) x  on d.Id = x.DeductionCodeId 
						WHERE x.EmployerPaid = 1 and x.Code Is not Null and e.CheckId = @EarnCheckID and x.Code = @WithholdingCode
					) s
				group by s.CheckId, s.Code

				-- Find Excluded Earning Amount
				Select @ExclEarningAmount = s.ExclEarningAmount	from
					(Select e.CheckId, e.EarningCode, e.DepartmentId, e.EarningAmount ExclEarningAmount, x.Code 
						From [dbo].[tblPaCheckEarn] e
						INNER JOIN #CheckList l ON e.[CheckId] = l.[CheckId]
						Left Join  (Select td.PaYear, td.Code, ex.EarningCodeId, ex.TaxAuthorityDtlId 
							from dbo.tblPaTaxAuthorityDetail td Inner Join 
							dbo.tblPaTaxAuthorityHeader th on th.Id = td.TaxAuthorityId and td.PaYear = @PaYear
							Inner Join dbo.tblPaTaxAuthorityExclusionEarning ex on td.Id = ex.TaxAuthorityDtlId) x  on e.EarningCode = x.EarningCodeId 
						WHERE x.Code Is not Null and e.CheckId = @EarnCheckID and x.Code = @WithholdingCode and   e.DepartmentId =  @DepartmentId and e.EarningCode  = @EarningCode
					) s 
					if @ExclDeductionAmount <> 0 
					begin    
						    Select @EarnPerc  = case when (@GrossEarnings + @ExclDeductionAmount) <> 0 then ((@EarningAmount)/(@GrossEarnings + @ExclDeductionAmount)) else 0 end
					end
					else
					begin
						 Select @EarnPerc  = case when @GrossEarnings <> 0  then ((@EarningAmount - @ExclEarningAmount) / (@GrossEarnings)) else 0 end
					end
					
				Insert Into #tmpPaAllocExclPct(CheckId, DepartmentId, EarnPerc, HomeYn, Code)
					values(@EarnCheckID , @DepartmentId, @EarnPerc, @HomeYn, @WithholdingCode)

				Next_Fut:
				FETCH NEXT FROM curEarnings INTO 
						   @EarnCheckID, @DepartmentId, @HomeYn, @EarningAmount, @Earningcode
			END
			CLOSE curEarnings
			DEALLOCATE curEarnings
		  
			NEXT_curCheckHist:
			fetch next from curCheckEmplrTax into 
				@CheckId, @WithholdingCode, @WithholdingPayments, @WithholdingEarnings, @GrossEarnings
		END
		CLOSE curCheckEmplrTax
		DEALLOCATE curCheckEmplrTax

		--group rows by department as multiple earnings maybe related to same
		select min(Id) Id, CheckId, DepartmentId, Sum(EarnPerc) EarnPerc, HomeYn, Code into #tmpPaAllocPctGrouped from #tmpPaAllocExclPct group by CheckId, DepartmentId, HomeYn, Code
		--mark first as home if no home row found
		update #tmpPaAllocPctGrouped set HomeYn=1 where Id in 
			(select min(Id) from #tmpPaAllocPctGrouped where CheckId not in (select checkid from #tmpPaAllocPctGrouped where HomeYn=1) group by CheckId, Code)

		--Insert the Department Allocations for Employer Tax.(With an Excluded Earnings)
		INSERT INTO #tmpPaAllocTax ([CheckId], [Id], [DepartmentId]
			, [TaxAuthorityId], [WithholdingCode], [AllocTax], [AllocEarn], [AllocGross])
		SELECT t.[CheckId], t.[Id], p.[DepartmentId]
			, t.[TaxAuthorityId], t.[WithholdingCode]
			, Round(convert(decimal(28,10),  t.[WithholdingPayments] * p.[EarnPerc]),@PrecCurr)
			, Round(convert(decimal(28,10), t.[WithholdingEarnings] * p.[EarnPerc]),@PrecCurr)
			, Round(convert(decimal(28,10), t.[GrossEarnings] * p.[EarnPerc]),@PrecCurr)
			FROM [dbo].[tblPaCheckEmplrTax] t
			INNER JOIN #CheckList l ON t.[CheckId] = l.[CheckId]
			Inner Join  
			(Select CheckId,  DepartmentId,  sum(EarnPerc) EarnPerc, HomeYn, code 
				From #tmpPaAllocPctGrouped
				WHERE HomeYn = 0
				group by CheckId,  DepartmentId, HomeYn, code) p 
			on p.CheckId = t.CheckId and t.[WithholdingCode] = p.[Code]
			order by p.CheckId, p.DepartmentId 
		
   
		--then put any remaining amounts in the home department Employer Tax.
		INSERT INTO #tmpPaAllocTax ([CheckId], [Id], [DepartmentId]
			, [TaxAuthorityId], [WithholdingCode], [AllocTax], [AllocEarn], [AllocGross])
        SELECT t.[CheckId], t.[Id], pct.[DepartmentId]
            , t.[TaxAuthorityId], t.[WithholdingCode]
            , t.[WithholdingPayments] - ISNULL(s.[TotalAllocTax], 0)
            , t.[WithholdingEarnings] - ISNULL(s.[TotalAllocEarn], 0)
            , t.[GrossEarnings] - ISNULL(s.[TotalAllocGross], 0)
        FROM [dbo].[tblPaCheckEmplrTax] t inner join (select checkid, departmentid, Code from #tmpPaAllocPctGrouped where HomeYn=1) pct 
		on t.checkid=pct.checkid  and t.[WithholdingCode] = pct.[Code]
        left JOIN (
            SELECT [CheckId], [Id]
                , SUM([AllocTax]) AS [TotalAllocTax]
                , SUM([AllocEarn]) AS [TotalAllocEarn]
                , SUM([AllocGross]) AS [TotalAllocGross]
            FROM #tmpPaAllocTax
            GROUP BY [CheckId], [Id]
        ) s ON t.[CheckId] = s.[CheckId] AND t.[Id] = s.[Id]


		--Department Allocations for Employer Costs.(No Exclusions) 
		INSERT INTO #tmpPaAllocPct ([CheckId], [DepartmentId], [HomeYn], [EarnPerc])
		SELECT c.[Id], e.[DepartmentId]
			, CASE WHEN ISNULL(e.[DepartmentId], '') = ISNULL(a.[DepartmentId], '') THEN 1 ELSE 0 END --identify the Home Department
			, SUM(CASE WHEN c.[GrossPay] <> 0 THEN e.[EarningAmount] / c.[GrossPay] ELSE 0 END)
		FROM [dbo].[tblPaCheck] c 
		INNER JOIN #CheckList l ON c.[Id] = l.[CheckId]
		INNER JOIN [dbo].[tblPaCheckEarn] e ON c.[Id] = e.[CheckId]
		INNER JOIN [dbo].[tblPaEmployee] a ON c.[EmployeeId] = a.[EmployeeId]
		GROUP BY c.[Id], e.[DepartmentId], a.[DepartmentId]

		--mark first as home if no home row found
		update #tmpPaAllocPct set HomeYn=1 where Id in 
			(select min(Id) from #tmpPaAllocPct where CheckId not in (select checkid from #tmpPaAllocPct where HomeYn=1) group by CheckId)

		--split Cost into worked/non-home depts first
		INSERT INTO #tmpPaAllocCost ([CheckId], [Id], [DeductionCode], [DepartmentId], [AllocCost])
		SELECT c.[CheckId], c.[Id], c.[DeductionCode], p.[DepartmentId]
			, ROUND(c.[DeductionAmount] * p.[EarnPerc], @PrecCurr)
		FROM [dbo].[tblPaCheckEmplrCost] c
		INNER JOIN #tmpPaAllocPct p ON c.[CheckId] = p.[CheckId]
		WHERE p.[HomeYn] = 0

		--then put any remaining amounts in the home department
		INSERT INTO #tmpPaAllocCost ([CheckId], [Id], [DeductionCode], [DepartmentId], [AllocCost])
		SELECT c.[CheckId], c.[Id], c.[DeductionCode], p.[DepartmentId]
			, c.[DeductionAmount] - ISNULL(s.[TotalAllocCost], 0)
		FROM [dbo].[tblPaCheckEmplrCost] c INNER JOIN (select CheckId, DepartmentId from #tmpPaAllocPct where HomeYn=1) p ON c.[CheckId] = p.[CheckId]
		left join (
			SELECT [CheckId], [Id], SUM([AllocCost]) AS [TotalAllocCost]
			FROM #tmpPaAllocCost
			GROUP BY [CheckId], [Id]
		) s ON c.[CheckId] = s.[CheckId] AND c.[Id] = s.[Id]	END
	ELSE  --home department
	BEGIN
		---------------------
		--Allocation 
		---------------------
		INSERT INTO #tmpPaAllocPct ([CheckId], [DepartmentId], [HomeYn], [EarnPerc])
		SELECT c.[Id], a.[DepartmentId], 1, 1
		FROM [dbo].[tblPaCheck] c 
		INNER JOIN #CheckList l ON c.[Id] = l.[CheckId]
		INNER JOIN [dbo].[tblPaEmployee] a ON c.[EmployeeId] = a.[EmployeeId]

		---------------------
		--Taxes
		---------------------
		INSERT INTO #tmpPaAllocTax ([CheckId], [Id], [DepartmentId]
			, [TaxAuthorityId], [WithholdingCode]
			, [AllocTax], [AllocEarn], [AllocGross])
		SELECT t.[CheckId], t.[Id], t.[DepartmentId]
			, t.[TaxAuthorityId], t.[WithholdingCode]
			, t.[WithholdingPayments], t.[WithholdingEarnings], t.[GrossEarnings]
		FROM [dbo].[tblPaCheckEmplrTax] t
		INNER JOIN #CheckList l ON t.[CheckId] = l.[CheckId]

		---------------------
		--Costs
		---------------------
		INSERT INTO #tmpPaAllocCost ([CheckId], [Id], [DeductionCode], [DepartmentId], [AllocCost])
		SELECT c.[CheckId], c.[Id], c.[DeductionCode], c.[DepartmentId], c.[DeductionAmount]
		FROM [dbo].[tblPaCheckEmplrCost] c
		INNER JOIN #CheckList l ON c.[CheckId] = l.[CheckId]
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCalculateDepartmentAllocations_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCalculateDepartmentAllocations_proc';

