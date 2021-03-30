
CREATE  Procedure [dbo].[trav_PaFUTaCalcWorksheetRpt_proc]

@PAYEAR Smallint = 2011
--@PrintBy Smallint  = 1,


AS
SET NOCOUNT ON
BEGIN TRY

--delete from  #tmpRecalcPrc
	--drop table #tmpRecalcPrc
	Create Table #tmpRecalcPrc(
		[Id] [int],
		[CheckId] [int],
		[StateCode] [nvarchar] (2) NULL,
		[Prc] [pdec], 
		[Dept] pDeptID,
		[HomeYn] Bit Not Null
		)
	
	--delete from #tmpFutaEmployeeCheck
	--drop table  #tmpFutaEmployeeCheck
    Create Table #tmpFutaEmployeeCheck(
		[Id] [int],
		[CheckId] [int],
		[CheckNumber] pCheckNum,
		[EmployeeID] nvarchar(11), 
		[EmployeeName] nvarchar(36),
		[CalcTax] pdec,
		[NewTax] pdec,
		[WithholdingEarnings] pdec,
		[StateCode] [nvarchar] (2) NULL,
		[StatePrc] pdec,
		[Dept] pDeptID 
		)




declare @PASTATUSCODE nvarchar(3)
declare @TableExist as pdec	
declare @TblId nvarchar(8)
declare @TOTEARN pdec
declare @FUTAAmount pdec

declare @FUTASPLT pDec
declare @TAXEARNSPLT pDec
declare @DepartmentId  pDeptID
declare @TAXEARN pDec
declare @NewTax pDec


declare @EmployeeID pEmpID  
declare @EmployeeName nvarchar(36)
declare @Id int 
declare @CheckNumber pCheckNum  
declare @CheckDate datetime 
declare @Column1 pDec
declare @Column2 pDec
declare @PostRun pPostRun

Select @PASTATUSCODE = 'FUT'
Select @TableExist = 0
Select @TOTEARN  = 0
Select @FUTAAmount = 0

Select @FUTASPLT = 0
Select @TAXEARNSPLT = 0
select @PostRun = ''

select @NewTax = 0
Set  @EmployeeName = ''

--Select * from dbo.tblPaCheckHist

--select * From dbo.tblPaCheckHistEarn
--Select * from dbo.tblPaCheckHistEmplrTax


declare curCheckHist cursor for 
 SELECT EmployeeID,  EmployeeName, PostRun,Id, CheckNumber,  CheckDate, DepartmentId    
 FROM dbo.tblPaCheckHist WHERE  PaYear = @PAYEAR   order by EmployeeID, CheckDate, PostRun,  DepartmentId 
 for read only
open curCheckHist
fetch next from curCheckHist into @EmployeeID,  @EmployeeName, @PostRun, @Id, @CheckNumber,  @CheckDate,  @DepartmentId  
While (@@FETCH_STATUS=0)
BEGIN

	Select @TAXEARN = min(WithholdingEarnings),  @FUTAAmount = sum(WithholdingAmount)  from dbo.tblPaCheckHistEmplrTax t
	inner Join  dbo.tblPaCheckHist h on h.PostRun = t.PostRun  and h.Id = t.CheckId
	WHERE t.CheckId = @Id and  t.WithholdingCode = 'FUT' and EmployeeId = @EmployeeId and PaYear = @PAYEAR and h.PostRun = @PostRun
	
	--print @TAXEARN
	
	
	
	delete from #tmpRecalcPrc
	    
	Insert Into #tmpRecalcPrc(Id,CheckID, StateCode, Prc, Dept, HomeYn)
		SELECT dbo.tblPaCheckHist.Id, dbo.tblPaCheckHistEarn.CheckID, dbo.tblPaCheckHistEarn.StateCode,
		sum(Case WHen dbo.tblPaCheckHist.GrossPay <> 0 then dbo.tblPaCheckHistEarn.EarningsAmount/dbo.tblPaCheckHist.GrossPay else 0 end) as Prc,
		tblPaCheckHistEarn.DepartmentId, case WHEN tblPaCheckHistEarn.DepartmentId <> @DepartmentId then  0 else 1 end
		FROM dbo.tblPaCheckHist INNER JOIN dbo.tblPaCheckHistEarn  ON
		dbo.tblPaCheckHist.Id = dbo.tblPaCheckHistEarn.CheckID
		and tblPaCheckHist.PostRun = dbo.tblPaCheckHistEarn.PostRun
	    WHERE 
	    dbo.tblPaCheckHist.EmployeeId = @EmployeeID and 
		dbo.tblPaCheckHist.Id = @Id and dbo.tblPaCheckHist.PostRun = @PostRun and tblPaCheckHist.PaYear = @PAYEAR  and dbo.tblPaCheckHistEarn.PostRun = @PostRun  
		group by dbo.tblPaCheckHist.Id, tblPaCheckHistEarn.DepartmentId, dbo.tblPaCheckHistEarn.CheckID, dbo.tblPaCheckHistEarn.StateCode
		Order by tblPaCheckHistEarn.DepartmentId
		
		--Select * from #tmpRecalcPrc
		

--if @TableExist =0 or (Select count(*) from  #tmpRecalcPrc Where StateCode = @StateCode) = 0  GOTO Next_curCheckHist

DECLARE  @CheckId int
DECLARE  @StateCode nvarchar(2) 
DECLARE  @Prc pDec 
DECLARE  @DepId pDeptID


DECLARE curFut CURSOR FOR Select
 CheckId, StateCode, Prc, Dept from
 #tmpRecalcPrc

	FOR READ Only
	OPEN curFut
	FETCH NEXT FROM curFut INTO 
	  @CheckId, @StateCode, @Prc, @DepID
			-- @PASTATE	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN

      
       If  (@StateCode = 'IN' or  @StateCode = 'MI' or @StateCode ='SC') 
       begin
     	  set @TblId = 'FED' + @StateCode + @PASTATUSCODE
	   end
	   else
	   begin
		    set @TblId = 'FED__' + @PASTATUSCODE
	   end 
	
	--print  @TblId
	  
	  --check if table exists for this Status, if not then set Status to 'NA'
        SELECT @TableExist=Count(*) FROM ST.dbo.tblPaSTTaxTablesDtl WHERE PaYear=@PAYEAR
		AND TableId=@TblID and Status = 'NA'
		
	    
       if @TableExist =0  GOTO Next_Fut
      --or (Select count(*) from  #tmpRecalcPrc Where StateCode = @StateCode) = 0 
        
		Select  @Column1 =Column1, @Column2 = Column2 FROM ST.dbo.tblPaSTTaxTablesDtl WHERE PaYear=@PAYEAR
		AND TableId=@TblID and Status = 'NA'
		
		--Select @TAXEARNSPLT = (Prc * @TAXEARN), @FUTASPLT = (Prc * @FUTAamount) From #tmpRecalcPrc WHERE StateCode = @PASTATE
		Select @TAXEARNSPLT = Coalesce((@Prc * @TAXEARN), 0), @FUTASPLT = Coalesce((@Prc * @FUTAamount) , 0)
	
		--if (Select sum(WithholdingEarnings)from #tmpFutaEmployeeCheck WHERE EmployeeId = @EmployeeID group by EmployeeID) > @Column2
		--begin
				Select @NewTax =  @NewTax + Round(((@TAXEARNSPLT * @Column1) * 0.01),2)
		--end
		--else
		--begin
		
		--	Select @NewTax =0
	 --   end
		
		Insert Into #tmpFutaEmployeeCheck (Id,  CheckId, CheckNumber, EmployeeID, EmployeeName, CalcTax,  NewTax, WithholdingEarnings, StateCode, StatePrc, Dept)
		 values (@Id,  @CheckId, @CheckNumber, @EmployeeID, @EmployeeName, @FUTASPLT , @NewTax, @TAXEARNSPLT, @StateCode, @Column1, @DepID)   
	
		--Print @NewTax 
		--Calculate FUTA new Pec
	
	       Next_Fut:
			FETCH NEXT FROM curFut INTO 
			--@PASTATE
				  @CheckId, @StateCode, @Prc, @DepID

END
CLOSE curFut
DEALLOCATE curFut

	
		Update #tmpFutaEmployeeCheck set #tmpFutaEmployeeCheck.NewTax = (@NewTax * p.Prc) 
		 --#tmpFutaEmployeeCheck.StatePrc = (p.StatePrc * p.Prc)
		from
		(Select prc.Prc, c.StatePrc, c.CheckId, c.Id
		from #tmpFutaEmployeeCheck  c INNER JOIN #tmpRecalcPrc prc on  c.Id =  prc.Id
	    and c.CheckId = prc.CheckId)p
	    inner join #tmpFutaEmployeeCheck on #tmpFutaEmployeeCheck.CheckId = p.CheckId
	    and p.Id = #tmpFutaEmployeeCheck.Id
	    
	
set @NewTax  = 0



NEXT_curCheckHist:
	fetch next from curCheckHist into  @EmployeeID, @EmployeeName, @PostRun, @Id, @CheckNumber,  @CheckDate, @DepartmentId  
END
CLOSE curCheckHist
DEALLOCATE curCheckHist




Select Id, CheckId, CheckNumber, 
EmployeeID,  EmployeeName, CalcTax AS FUTAExpenses,  NewTax  AS EstFUTAExpenses, WithholdingEarnings  AS FUTAWages,  WithholdingEarnings  AS EstFUTAWages, 
StateCode, StatePrc AS Pct, Dept as DepartmentId, g.GLAcct as GlAccount
from  #tmpFutaEmployeeCheck left join 
(Select dd.DepartmentId, dd.GLAcct, dd.code  from dbo.tblPaDept d INNER JOIN dbo.tblPaDeptDtl dd on  d.Id = dd.DepartmentId 
WHERE Type = 0
and code = 'FUT') g on g.DepartmentId = #tmpFutaEmployeeCheck.Dept
WHERE #tmpFutaEmployeeCheck.Dept  IS Not Null

Select Id, CheckId, CheckNumber, 
EmployeeID,  EmployeeName, CalcTax AS FUTAExpenses,  NewTax  AS EstFUTAExpenses, WithholdingEarnings  AS FUTAWages,  
WithholdingEarnings  AS EstFUTAWages, StateCode, StatePrc AS Pct, Dept as DepartmentId, g.GLAcct as GlAccount
from  #tmpFutaEmployeeCheck left join 
(Select dd.DepartmentId, dd.GLAcct, dd.code  from dbo.tblPaDept d INNER JOIN dbo.tblPaDeptDtl dd on  d.Id = dd.DepartmentId 
WHERE Type = 0
and code = 'FUT') g on g.DepartmentId = #tmpFutaEmployeeCheck.Dept
WHERE #tmpFutaEmployeeCheck.Dept  IS Not Null 

--SELECT EmployeeId, EmployeeName, DepartmentId, 'MN' AS StateCode, .3 AS Pct
--	, 0.00 AS FUTAWages, 0.00 AS FUTAExpenses, 0.00 AS EstFUTAWages, 0.00 AS EstFUTAExpenses 
--FROM dbo.tblPaCheckHist-- WHERE EmployeeId = 'BOU001'

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.14311.1561', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaFUTaCalcWorksheetRpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 14311', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaFUTaCalcWorksheetRpt_proc';

