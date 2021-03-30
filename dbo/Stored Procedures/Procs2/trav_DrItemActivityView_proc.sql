
Create procedure dbo.trav_DrItemActivityView_proc 
(
@RunId pPostRun,
@ItemId pItemId,
@LocId pLocId,
@UOM pUOM,
@Source smallint,
@DateFrom datetime,
@DateThru datetime,
@PrecQty tinyint = 4
)
As
Begin Try
SET NOCOUNT ON


--1=PurchOrds / 2=PurchReqs /4=Production Orders/8=Production Orders Components/ 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 
--128=MstrSchedProduction / 256 WorkOrder / 512 WorkOrderComp / 1024=WM Transfer / 2048=JC Estimates

-- DR Item Activity View (DR Inquiry Drill down inquiry)

Declare @ConvFactor pDecimal
--capture the Uom conversion factor
Select @ConvFactor = ConvFactor from tblInItemUom where ItemId=@ItemId and Uom=@UOM
Select @ConvFactor = Case When isnull(@ConvFactor, 0) = 0 Then 1 Else @ConvFactor End

Select RunId, SeqNum, d.ItemId,  LocId
	, i.Descr, @UOM UOM, TransDate [Date], TransType, Source, LinkId, LinkIdSub OrderNo
	, Case When Source = 4 or Source = 8 Then left(LinkIdSubLine, 3) Else LinkIdSubLine End  LineReleaseNo
	, Cast(Round(Qty / @ConvFactor, @PrecQty) as float) Quantity
	, CASE Source 
		WHEN 32  Then ''
		WHEN 256 Then '' 
		When 4   Then c.CustName
		When 16  Then c.CustName 
		When 1   Then v.[Name]
		When 2   Then v.[Name] 		
		ELSE Coalesce(d.AssemblyId, c.CustName, v.[Name]) 
	END Reference
	From dbo.tblDRRunData d
	left join dbo.tblInItem i ON d.ItemId = i.ItemId
	left join dbo.tblArCust c ON d.CustId = c.CustId
	left join dbo.tblApVendor v ON d.VendorId = v.VendorId
	Where RunId = @RunId and d.ItemId = @ItemId and ((LocId = @LocId) or @LocId = 'ALL')
		and TransDate Between @DateFrom and @DateThru
		and Source & @Source = Source
		
		
	Order by TransDate

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrItemActivityView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrItemActivityView_proc';

