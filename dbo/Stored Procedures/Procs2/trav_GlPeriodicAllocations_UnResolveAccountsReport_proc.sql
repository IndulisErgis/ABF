
CREATE PROCEDURE dbo.trav_GlPeriodicAllocations_UnResolveAccountsReport_proc
AS
SET NOCOUNT ON
BEGIN TRY
	----Expects the list of group ids to process to be provided via temp table #GroupIDList
	--Create Table #GroupIDList (
	--	[GroupID] [bigint] not null ,
	--	Primary Key ([GroupID])
	--)


	--Create Table #UnResolvedSourceAccount
	--(
	--	[AccountId] [nvarchar](12) ,
	--	[AltAccountId] [nvarchar](12) ,	
	--	[AllocAmount] [pDecimal] , 
	--	[AllocLimit] [pDecimal],	
	--	[CodeID] [bigint]
	--)

	--Create Table #UnResolvedReceipientAccount
	--(
	--	[AccountId] [nvarchar](12) ,
	--	[AltAccountId] [nvarchar](12) ,	
	--	[AllocAmount] [pDecimal] , 
	--	[AllocLimit] [pDecimal],	
	--	[CodeID] [bigint],	
	--	[AltSegmentId] [nvarchar](12) ,
	--	AllocType [tinyint]
	--)

	--Create Table #UnResolvedSourceSegments
	--(
	--	[SegmentId] [nvarchar](12) ,
	--	[AltSegmentId] [nvarchar](12) ,
	--	[AlolcationDescription] [nvarchar](40),
	--	[AllocAmount] [pDecimal] , 
	--	[AllocLimit] [pDecimal],	
	--	[CodeID] [bigint],
	--	[DistType] [tinyint]
	--)
	--Create Table #UnResolvedReceipientSegments
	--(
	--	[SegmentId] [nvarchar](12) ,
	--	[AltSegmentId] [nvarchar](12) ,
	--	[AlolcationDescription] [nvarchar](40),
	--	[AllocAmount] [pDecimal] , 
	--	[AllocLimit] [pDecimal],	
	--	[CodeID] [bigint]
	--	,AllocBasis [tinyint],
	--	AllocType [tinyint]

	--)
	-- Source account
	Insert into #UnResolvedSourceAccount ([AccountId] ,
		[AltAccountId] ,		
		[AllocAmount]  , 
		[AllocLimit] ,		
		[CodeID] ,Sequence 
		)
	Select DISTINCT		
		pd.[AccountID], ISNULL(pd.[AltAccountID], pd.[AccountID]),ISNULL(pd.[AllocAmount], 0),ISNULL(pd.[AllocLimit], 0),pc.ID	,Sequence	
		From dbo.tblGlAllocPdCode pc  
		Inner Join #GroupIDList tg on pc.[ID] = tg.[GroupID]		
		LEFT Join dbo.tblGlAllocPdCodeDetail pd on pc.[ID] = pd.[AllocCodeID]		
		WHERE (pd.[DetailType] = 0)  order by Sequence--Full Account ID source

	-- receipient Account
	Insert into #UnResolvedReceipientAccount ([AccountId] ,
		[AltAccountId] ,		
		[AllocAmount]  , 
		[AllocLimit] ,		
		[CodeID] ,		
		AltSegmentId,
		AllocType,Sequence )
	Select DISTINCT
			pd.[AccountID], ISNULL(pd.[AltAccountID], pd.[AccountID]),ISNULL(pd.[AllocAmount], 0), ISNULL(pd.[AllocLimit], 0), pc.ID ,null, pd.AllocType,Sequence
		From dbo.tblGlAllocPdCode pc  
		Inner Join #GroupIDList tg on pc.[ID] = tg.[GroupID]		
		LEFT Join dbo.tblGlAllocPdCodeDetail pd on pc.[ID] = pd.[AllocCodeID]		
		WHERE ( pd.[DetailType] = 1) order by Sequence --Full Account ID receipient

	UPDATE #UnResolvedReceipientAccount SET AltSegmentId = ps.AltSegmentID
		From #UnResolvedReceipientAccount pc
		Inner Join dbo.tblGlAllocPdCodeSegment ps on pc.[CodeID] = ps.[AllocCodeID]	

	-- Source Segment
	--Step 1/2/3(b): Capture segment based detail (Source)
	INSERT INTO #UnResolvedSourceSegments ( 
				[SegmentId]  ,
				[AltSegmentId]  ,
				[AlolcationDescription],
				[AllocAmount]  , 
				[AllocLimit] ,			
				[CodeID],
				DistType,
				DetailType,Sequence)
	Select DISTINCT 
				 ps.[SegmentID], 
				 ps.[AltSegmentID],
				 ISNULL(s.Description,'Account'),
				 ISNULL(ps.[AllocAmount],0), 
				 ISNULL(ps.[AllocLimit],0),				
				 pc.ID,
				 pc.DistType,
				 ps.DetailType,Sequence
	FROM dbo.tblGlAllocPdCode pc
	Inner Join #GroupIDList tg on pc.[ID] = tg.[GroupID]		
	LEFT Join dbo.tblGlAllocPdCodeSegment ps on pc.[ID] = ps.[AllocCodeID]	
	LEFT JOIN dbo.tblGlAcctMaskSegment s ON s.Number = pc.SourceType
	WHERE (pc.[SourceType] >= 0 ) order by Sequence
	--AND ps.[DetailType] = 0) --Segment based source

	-- Receipient segment
	--Step 1/2/3(b): Capture segment based detail (Recipient)
	INSERT INTO #UnResolvedReceipientSegments ( 
				[SegmentId]  ,
				[AltSegmentId]  ,
				[AlolcationDescription],
				[AllocAmount]  , 
				[AllocLimit] ,				
				[CodeID],
				AllocBasis,
				AllocType,
				DetailType,Sequence)
	Select DISTINCT 
			ps.[SegmentID]
			, ps.[AltSegmentID]
			, ISNULL(s.Description,'Account')
			, ISNULL(ps.[AllocAmount],0)
			, ISNULL(ps.[AllocLimit],0)			
			, pc.Id	
			, pc.AllocBasis, ps.AllocType,
			 ps.DetailType,Sequence
		From dbo.tblGlAllocPdCode pc 
		Inner Join #GroupIDList tg on pc.[ID] = tg.[GroupID]		
		LEFT Join dbo.tblGlAllocPdCodeSegment ps on pc.[ID] = ps.[AllocCodeID]			
		LEFT JOIN dbo.tblGlAcctMaskSegment s ON s.Number = pc.RecipientType
		WHERE (pc.[RecipientType] >= 0 ) order by Sequence
		--AND ps.[DetailType] = 1) 


	END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocations_UnResolveAccountsReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocations_UnResolveAccountsReport_proc';

