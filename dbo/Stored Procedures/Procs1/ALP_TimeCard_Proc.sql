CREATE Procedure [dbo].[ALP_TimeCard_Proc]
(		@Status char(1),
		@TimeCardId  int output,
        @TechId  int,
        @StartDate datetime,
        @EndDate datetime,
        @StartTime int ,
        @EndTime   int ,
        @TimeCodeId int ,
        @SvcJobYN bit ,
        @TicketId int,
        @SpecializedLaborType varchar(24) ,
        @BillableHrs decimal(20,10),
        @PayBasedOn tinyint ,
        @Points float ,
        @PworkRate float ,
        @LaborCostRate float ,
        @ModifiedBy varchar(50) ,
        @ModifiedDate datetime ,
        @LockedYN bit,
        @TimeCardComment nvarchar(500)  ,
        @Ts timestamp output,
        @ReturnedTs timestamp output)AS
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 

BEGIN
	IF (@Status='A')
	BEGIN
		INSERT INTO dbo.[ALP_tblJmTimeCard]
                    (
                    [TechID]
                    ,[StartDate]
                    ,[EndDate]
                    ,[StartTime]
                    ,[EndTime]
                    ,[TimeCodeID]
                    ,[SvcJobYN]
                    ,[TicketId]
                    ,[SpecializedLaborType]
                    ,[BillableHrs]
                    ,[PayBasedOn]
                    ,[Points]
                    ,[PworkRate]
                    ,[LaborCostRate]
                    ,[ModifiedBy]
                    ,[ModifiedDate]
                    ,[LockedYN]
                    ,[TimeCardComment]
                    )
                VALUES
                    (
                    @TechId
                    ,@StartDate
                    ,@EndDate
                    ,@StartTime
                    ,@EndTime
                    ,@TimeCodeId
                    ,@SvcJobYN
                    ,@TicketId
                    ,@SpecializedLaborType
                    ,@BillableHrs
                    ,@PayBasedOn
                    ,@Points
                    ,@PworkRate
                    ,@LaborCostRate
                    ,@ModifiedBy
                    ,@ModifiedDate
                    ,@LockedYN
                    ,@TimeCardComment
                    )
                
                -- Get the identity value
                SET @TimeCardId = SCOPE_IDENTITY()
                                    
                -- Select computed columns into output parameters
                SELECT @Ts = [ts]
                FROM dbo.[ALP_tblJmTimeCard]
                WHERE [TimeCardID] = @TimeCardId
	END
	ELSE IF (@Status ='M')
BEGIN
	-- Modify the updatable columns
                UPDATE
                    dbo.[ALP_tblJmTimeCard]
                SET
                    [TechID] = @TechId
                    ,[StartDate] = @StartDate
                    ,[EndDate] = @EndDate
                    ,[StartTime] = @StartTime
                    ,[EndTime] = @EndTime
                    ,[TimeCodeID] = @TimeCodeId
                    ,[SvcJobYN] = @SvcJobYN
                    ,[TicketId] = @TicketId
                    ,[SpecializedLaborType] = @SpecializedLaborType
                    ,[BillableHrs] = @BillableHrs
                    ,[PayBasedOn] = @PayBasedOn
                    ,[Points] = @Points
                    ,[PworkRate] = @PworkRate
                    ,[LaborCostRate] = @LaborCostRate
                    ,[ModifiedBy] = @ModifiedBy
                    ,[ModifiedDate] = @ModifiedDate
                    ,[LockedYN] = @LockedYN
                    ,[TimeCardComment] = @TimeCardComment
                WHERE [TimeCardID] = @TimeCardId AND [ts] = @Ts                
                
                -- Select computed columns into output parameters
                SELECT @ReturnedTs = [ts] FROM  dbo.[ALP_tblJmTimeCard]
                WHERE[TimeCardID] = @TimeCardId 
	
	END
	--ELSE IF (@Status ='D')
	--BEGIN
	--	DELETE FROM dbo.[ALP_tblJmTimeCard] WITH (ROWLOCK)   WHERE  [TimeCardID] = @TimeCardId	AND [ts] = @Ts  
	--END
	--ELSE IF (@Status ='R')
	--BEGIN
	--	SELECT   [TimeCardID],[TechID],[StartDate],[EndDate], [StartTime],[EndTime],[TimeCodeID],
 --                   [SvcJobYN],[TicketId],[SpecializedLaborType],[BillableHrs],
 --                   [PayBasedOn],[Points],[PworkRate],[LaborCostRate],
 --                   [ModifiedBy],[ModifiedDate],[LockedYN],[TimeCardComment],[ts]
 --               FROM  dbo.[ALP_tblJmTimeCard]
 --               WHERE StartDate >= @StartDate and StartDate   <= @EndDate  and TechID =@TechId 
 --               -- @ALL=1 OR ( [TimeCardID] = @TimeCardId  )
	--END
END