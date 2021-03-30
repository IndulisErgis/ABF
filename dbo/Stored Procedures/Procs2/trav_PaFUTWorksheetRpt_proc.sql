
CREATE  Procedure [dbo].[trav_PaFUTWorksheetRpt_proc]

@PAYEAR Smallint = 2011

AS
SET NOCOUNT ON
BEGIN TRY
--MOD: Change using the DepartmentId from the tblPaCheckHist to tblPaCheckHistEmplrTax table.
--PET:http://webfront:801/view.php?id=237356
--delete from  #tmpRecalcPrc
	--drop table #tmpRecalcPrc
	Create Table #tmpRecalcPrc(
		[Id] [int],
		[CheckId] [int],
		[StateCode] [nvarchar] (2) NULL,
		[Prc] [pDecimal], 
		[Dept] pDeptID
		)
	--drop table #tmpFutaEmplrTax
	Create Table #tmpFutaEmplrTax(
        [ID] int Identity (1,1),
        [PostRun] pPostRun,
        [CheckID] [int],
		[CheckNumber] pCheckNum,
		[CheckDate] datetime,
		[EmployeeID] nvarchar(11), 
		[EmployeeName] nvarchar(36),
		[DepartmentId] pDeptID,
		[Voided] bit default(0), 
		[WithholdingCode] nvarchar(3),
		[WithholdingEarnings] pDecimal,
		[CalcTax] pDecimal,
		[GlAccount] nvarchar(40)
		PRIMARY KEY CLUSTERED ([ID])
		)
--drop table #tmpFutaStatesDtl	
	Create Table #tmpFutaStatesDtl(
        [ID] int Identity (1,1),
        [CheckID] int,
		[StateCode] nvarchar(2), 
		[EstFUTAExpenses] pDecimal,
		[EstFUTAWages] pDecimal,
		[Pct] pDecimal,
		[DepartmentId] pDeptID	
		PRIMARY KEY CLUSTERED ([ID])
		)

declare @PASTATUSCODE nvarchar(3)
declare @TableExist as pDecimal	
declare @TableExistFUT as pDecimal	
declare @TblId nvarchar(8)
declare @TOTEARN pDecimal
declare @FUTAAmount pDecimal

declare @FUTASPLT pDecimal
declare @TAXEARNSPLT pDecimal
declare @DepartmentId  pDeptID
declare @TAXEARN pDecimal
declare @NewTax pDecimal
declare @Voided bit
DECLARE @StateCode nvarchar(2) 
DECLARE @Prc pDecimal 
DECLARE @DepId pDeptID

declare @EmployeeID pEmpID  
declare @EmployeeName nvarchar(36)
declare @Id int 
declare @CheckID int
declare @CheckNumber pCheckNum 
declare @CheckDate datetime  
declare @EffectiveDate datetime 
declare @OldPrc pDecimal
declare @Column1 pDecimal
declare @Column2 pDecimal
declare @PostRun pPostRun

Select @PASTATUSCODE = 'FUT'
Select @EffectiveDate = convert(datetime,'07/01/' + Convert(nvarchar(4), @PAYEAR))
select @OldPrc  = 0.2
Select @TableExist = 0
Select @TOTEARN  = 0
Select @FUTAAmount = 0

Select @FUTASPLT = 0
Select @TAXEARNSPLT = 0
select @PostRun = ''

select @NewTax = 0
Set  @EmployeeName = ''


Insert into #tmpFutaEmplrTax
(PostRun, CheckId, CheckNumber, CheckDate,
EmployeeID, EmployeeName, DepartmentId, Voided,
WithholdingCode, WithholdingEarnings, CalcTax, GlAccount)
Select h.PostRun, h.ID, h.CheckNumber, h.CheckDate,
h.EmployeeId, h.EmployeeName, t.DepartmentId, h.Voided,  
t.WithholdingCode, t.WithholdingEarnings, t.WithholdingAmount, g.GLAcct as GlAccount
from dbo.tblPaCheckHist h INNER JOIN dbo.tblPaCheckHistEmplrTax t on 
h.PostRun = t.PostRun and h.Id = t.CheckID
left join 
(Select dd.DepartmentId, dd.GLAcct, dd.code  from dbo.tblPaDept d INNER JOIN dbo.tblPaDeptDtl dd on  d.Id = dd.DepartmentId 
WHERE Type = 0
and code = 'FUT') g on g.DepartmentId = t.DepartmentId
WHERE h.PaYear = @PAYEAR and t.WithholdingCode = 'FUT'  and h.PostRun = h.PostRun 
and t.WithholdingAmount <> 0 and t.WithholdingEarnings <> 0 and h.Voided =0
Order by h.EmployeeID, h.CheckDate, h.PostRun, h.DepartmentId 



declare curCheckHist cursor for 
 SELECT ID, EmployeeID,  PostRun, CheckID,  DepartmentId,WithholdingEarnings, Voided, CheckDate  
 FROM #tmpFutaEmplrTax  order by ID
 for read only
open curCheckHist
fetch next from curCheckHist into
	@ID, @EmployeeID, @PostRun, @CheckID, @DepartmentId, @TAXEARN, @Voided, @CheckDate
While (@@FETCH_STATUS=0)
BEGIN

 delete from #tmpRecalcPrc
 
 --Select * from #tmpRecalcPrc
	
        Insert Into #tmpRecalcPrc(ID, CheckID, StateCode, Prc, Dept)  
		SELECT dbo.tblPaCheckHist.ID, min(dbo.tblPaCheckHistEarn.CheckID), dbo.tblPaCheckHistEarn.StateCode,
		sum(Case WHen dbo.tblPaCheckHist.GrossPay <> 0 then dbo.tblPaCheckHistEarn.EarningsAmount/dbo.tblPaCheckHist.GrossPay else 0 end) as Prc,
		@DepartmentId
		FROM dbo.tblPaCheckHist INNER JOIN dbo.tblPaCheckHistEarn  ON
		dbo.tblPaCheckHist.ID = dbo.tblPaCheckHistEarn.CheckID
		and tblPaCheckHist.PostRun = dbo.tblPaCheckHistEarn.PostRun
	    WHERE dbo.tblPaCheckHist.EmployeeId = @EmployeeId  and
		dbo.tblPaCheckHist.ID = @CheckID  and dbo.tblPaCheckHist.PaYear = @PAYEAR
		group by dbo.tblPaCheckHist.ID, dbo.tblPaCheckHistEarn.StateCode
		Order by min(dbo.tblPaCheckHistEarn.CheckID), dbo.tblPaCheckHistEarn.StateCode
		
DECLARE curFut CURSOR FOR Select
 CheckID, StateCode, Prc, Dept from
 #tmpRecalcPrc

	FOR READ Only
	OPEN curFut
	FETCH NEXT FROM curFut INTO 
	  @CheckID, @StateCode, @Prc, @DepID
		
	WHILE (@@FETCH_STATUS = 0)
	BEGIN

         select @TableExistFUT = 0
  
	   set @TblId = 'FED' + @StateCode + @PASTATUSCODE
	   SELECT @TableExist=Count(*) FROM ST.dbo.tblPaSTTaxTablesDtl WHERE PaYear=@PAYEAR
		AND TableId=@TblID and Status = 'NA'
		
	 if @TableExist = 0 
     begin
         set @TblId = 'FED__' + @PASTATUSCODE
		 SELECT @TableExistFUT =Count(*) FROM ST.dbo.tblPaSTTaxTablesDtl WHERE PaYear=@PAYEAR
		AND TableId=@TblID and Status = 'NA'
	
     end
	
	--print  @TblId
	  --check if table exists for this Status, if not then set Status to 'NA'
      

       if @TableExist =0  and @TableExistFUT = 0 GOTO Next_Fut

		Select  @Column1 =Column1, @Column2 = Column2 FROM ST.dbo.tblPaSTTaxTablesDtl WHERE PaYear=@PAYEAR
		AND TableId=@TblID and Status = 'NA'
		
			Select @TAXEARNSPLT = Coalesce((@Prc * @TAXEARN), 0)
		if  @PAYEAR = 2011 and @CheckDate < @EffectiveDate
		 begin
		        
		      Select  @Column1 = @Column1 + @OldPrc
	     end
	
			Select @NewTax = Round(((@TAXEARNSPLT * @Column1) * 0.01),2)

	Insert Into #tmpFutaStatesDtl(CheckID, EstFUTAExpenses, EstFUTAWages, StateCode, Pct, DepartmentId)
	 values (@ID, @NewTax, 
	 @TAXEARNSPLT, @StateCode, @Column1, @DepID)   

	       Next_Fut:
			FETCH NEXT FROM curFut INTO 
			
				  @CheckID, @StateCode, @Prc, @DepID
END
CLOSE curFut
DEALLOCATE curFut

set @NewTax  = 0




NEXT_curCheckHist:
	fetch next from curCheckHist into  
	
	@ID, @EmployeeID, @PostRun, @CheckID,  @DepartmentId, @TAXEARN, @Voided, @CheckDate 
END
CLOSE curCheckHist
DEALLOCATE curCheckHist

	Select  ID, EmployeeID, EmployeeName, DepartmentId, 
	WithholdingCode, cast(WithholdingEarnings as float) as FUTAWages, cast(CalcTax as float)  as FUTAExpenses, GlAccount,  
	cast(s.EstFUTAExpenses as float) as EstFUTAExpenses,
	cast((s.EstFUTAExpenses - CalcTax) as float) as Variance, s.StateCode, s.Pct 
	from #tmpFutaEmplrTax
	INNER JOIN 
	(Select d.CheckID,sum(d.EstFUTAExpenses) as  EstFUTAExpenses, min(d.StateCode)StateCode, min(d.Pct) AS Pct 
	from #tmpFutaStatesDtl d
	group by  CheckID) s
	on #tmpFutaEmplrTax.ID = s.CheckID

    select * from #tmpFutaStatesDtl
    
    Select  ID, EmployeeID, EmployeeName, DepartmentId, 
	WithholdingCode, cast(WithholdingEarnings as float) as FUTAWages, cast(CalcTax as float)  as FUTAExpenses, GlAccount,  
	cast(s.EstFUTAExpenses as float) as EstFUTAExpenses,
	cast((s.EstFUTAExpenses - CalcTax) as float) as Variance, s.StateCode, s.Pct 
	from #tmpFutaEmplrTax
	INNER JOIN 
	(Select d.CheckID,sum(d.EstFUTAExpenses) as  EstFUTAExpenses, min(d.StateCode)StateCode, min(d.Pct) AS Pct 
	from #tmpFutaStatesDtl d
	group by  CheckID) s
	on #tmpFutaEmplrTax.ID = s.CheckID

    
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaFUTWorksheetRpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaFUTWorksheetRpt_proc';

