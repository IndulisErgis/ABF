
CREATE Procedure [dbo].[trav_WmItemExplorerInquiry_proc]
@PickDefId nvarchar(50) = NULL,
@ItemId pItemId = NULL,
@LocId pLocId = NULL,
@LotNum pLotNum = NULL,
@Filter nvarchar = NULL

As

BEGIN TRY

Create table #ItemList(
	ItemId pItemId, 
	LocId pLocId
)

--limit the list to a specific Item/Location when the item/location is specified
If (@ItemId is not null) and (@LocId is not null)
Begin 
	Insert into #ItemList (ItemId, LocId)
	Values (@ItemId, @LocId)
End
Else
Begin
	--build a list of item/locations that meet the pick criteria
	--capture matching Item Id values
	Insert into #ItemList(ItemId, LocId) 
	Select i.ItemId, l.LocId
		From dbo.tblInItem i
		Inner Join dbo.tblInItemLoc l on i.ItemId = l.ItemId
		
	--capture matching item aliases
	Insert into #ItemList(ItemId, LocId) 
	Select i.ItemId, l.LocId
		From dbo.tblInItemAlias i
		Inner Join dbo.tblInItemLoc l on i.ItemId = l.ItemId
		Left Join #ItemList t on l.ItemId = t.ItemId and l.LocId = t.LocId
		Where t.LocId is null --exclude existing records
		Group By i.ItemId, l.LocId
	
	--capture matching item upc codes
	Insert into #ItemList(ItemId, LocId) 
	Select i.ItemId, l.LocId
		From dbo.tblInItemUom i
		Inner Join dbo.tblInItemLoc l on i.ItemId = l.ItemId
		Left Join #ItemList t on l.ItemId = t.ItemId and l.LocId = t.LocId
		Where t.LocId is null --exclude existing records
		Group By i.ItemId, l.LocId
End

--return the resultset (return the next level of detail based on provided parameters)
Select Distinct d.ItemId, i.Descr ItemDescr, i.ItemType, i.LottedYn
	, d.LocId, l.Descr LocDescr
	, Case When @LocId IS NOT NULL Then d.LotNum Else Null End LotNum
	, Case When (@LotNum IS NOT NULL) or (@LocId IS NOT NULL and i.LottedYn = 0) Then d.SerNum Else Null End SerNum
	From #ItemList t
	Inner Join 
		(Select d.ItemId, d.LocId, d.TransId, d.TransDate, d.SrceId
              , d.LotNum, Null SerNum, wl.ExtLocA, wl.ExtLocB
              From dbo.tblInItem i
              Inner Join #InHistDetailList d on i.ItemId = d.ItemId
              Left Join #WmHistDetailList wl on d.HistSeqNum = wl.HistSeqNum
              Where i.LottedYn <> 0 and i.ItemType <> 2 --Regular/Lotted non-serialized
                    And (d.ItemId = @ItemId or @ItemId is null)
                    And (d.LocId = @LocId or @LocId is null)
                    And (d.LotNum = @LotNum or @LotNum is null)
		Union all
		Select d.ItemId, d.LocId, d.TransId, d.TransDate, d.SrceId
			, NullIf(s.LotNum, ''), s.SerNum, ws.ExtLocA, ws.ExtLocB
			From dbo.tblInItem i
			Inner Join #InHistDetailList d on i.ItemId = d.ItemId
			Inner Join dbo.tblInHistSer s on d.HistSeqNum = s.HistSeqNum
			Left Join #WmHistDetailList ws on s.HistSeqNum = ws.HistSeqNum and s.SeqNum = ws.HistSeqNumSer
			Where i.ItemType = 2 --serialized (lotted & non-lotted)
				And (d.ItemId = @ItemId or @ItemId is null)
				And (d.LocId = @LocId or @LocId is null)
				And (s.LotNum = @LotNum or @LotNum is null)
		Union all
		Select w.ItemId, w.LocId, isnull(TransId, Cast(ReferenceId as nvarchar)) TransId, TransDate
			, isnull(TransId, Cast(ReferenceId as nvarchar)) SrceID
			, NullIf(w.LotNum, ''), NullIf(w.SerNum, ''), w.ExtLocA, w.ExtLocB
			From #WmHistDetailList w
			Where w.HistSeqNum is null --all WM hist not related to IN hist (e.g. Qty Moves)
				And (w.ItemId = @ItemId or @ItemId is null)
				And (w.LocId = @LocId or @LocId is null)
				And (w.LotNum = @LotNum or @LotNum is null)
		) d
		on t.ItemId = d.ItemId and t.LocId = d.LocId
	Inner Join dbo.tblInItem i on d.ItemId = i.ItemId
	Inner Join dbo.tblInLoc l on d.LocId = l.LocId
	Left Join dbo.tblWmExtLoc a on d.ExtLocA = a.Id
	Left Join dbo.tblWmExtLoc b on d.ExtLocB = b.Id
	--must be ordered for proper display
	Order By d.ItemId, d.LocId 
		, Case When @LocId IS NOT NULL Then d.LotNum Else Null End 
		, Case When (@LotNum IS NOT NULL) or (@LocId IS NOT NULL and i.LottedYn = 0) Then d.SerNum Else Null End 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemExplorerInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemExplorerInquiry_proc';

