
Create proc trav_DrQryPdDefBuildDateList 
@PdDefId nvarchar(10),   
@StartDate datetime  
as
Declare @IncUnit tinyint --0=daily, 1=Weekly, 2=Monthly  
Declare @Increment smallint  
Declare @NextDate datetime  
Declare @tmpDate datetime
declare @rowcount integer 
declare @rowNo integer

Set @NextDate= @StartDate
Select @rowCount= COUNT(1) from tblDrPeriodDefDtl Where PdDefId = @PdDefId
		Set @rowNo=1
		
		While (@rowNo<=@rowCount)
		Begin
		Select @tmpDate= Case IncUnit
				When 1 Then DateAdd(ww, Increment, @NextDate) --weekly
				When 2 Then DateAdd(mm, Increment, @NextDate) --monthly
				Else DateAdd(dd, Increment, @NextDate) --daily
				End from 
				 (select ROW_NUMBER() over(order by Period) As RowNumber, Increment,IncUnit  from tblDrPeriodDefDtl Where PdDefId = @PdDefId ) t
				 where RowNumber = @rowNo
	    
			Insert Into #DateList(IncDate, DaysInPd) values(@NextDate, Datediff(dd, @NextDate, @tmpDate))

			Select @NextDate = @tmpDate
			Set  @rowNo=@rowNo+1
		End
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrQryPdDefBuildDateList';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrQryPdDefBuildDateList';

