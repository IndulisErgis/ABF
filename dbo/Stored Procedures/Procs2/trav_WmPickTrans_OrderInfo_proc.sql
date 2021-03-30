
CREATE Procedure [dbo].[trav_WmPickTrans_OrderInfo_proc]
@PickGenKey int
As
BEGIN TRY
Set Nocount on

Declare @TransId pTransId
Declare @EntryNum bigint
Declare @SourceId tinyint

--capture the Key information from based on the @PickGenKey
Select @SourceId = SourceId, @TransId = TransId, @EntryNum = EntryNum
	From dbo.tblWmPick_Gen
	Where PickGenKey = @PickGenKey

If @SourceId = 0
Begin
	--retrieve resultset from SO Transaction

	Select @SourceId SourceId, h.CustId
		, Case When h.ShipToName is null Then c.CustName Else h.ShipToName End ShipToName
		, Case When h.ShipToName is null Then c.Addr1 Else h.ShipToAddr1 End ShipToAddr1
		, Case When h.ShipToName is null Then c.Addr2 Else h.ShipToAddr2 End ShipToAddr2
		, Case When h.ShipToName is null Then c.City Else h.ShipToCity End ShipToCity
		, Case When h.ShipToName is null Then c.Region Else h.ShipToRegion End ShipToRegion
		, Case When h.ShipToName is null Then c.Country Else h.ShipToCountry End ShipToCountry
		, Case When h.ShipToName is null Then uc.[Name] Else uh.[Name] End ShipToCountryName
		, Case When h.ShipToName is null Then c.PostalCode Else h.ShipToPostalCode End ShipToPostalCode
		, Case When h.ShipToName is null Then c.Phone Else h.ShipToPhone End ShipToPhone
		, h.ShipVia
		From dbo.tblSoTransHeader h Left Join dbo.tblArCust c
		on h.CustId = c.CustId
		Left Join #tmpCountryList uh
		on h.ShipToCountry = uh.Country
		Left Join #tmpCountryList uc
		on c.Country = uc.Country
		Where h.TransId = @TransId
End

Else If @SourceId = 1
 Begin
    --retrieve resultset from MP Transaction
	Select @SourceId SourceId, l.CustId, l.EstStartDate, l.EstCompletionDate, l.Notes   
	From    dbo.tblMpMatlSum s    
	INNER JOIN  tblMpRequirements r ON r.TransId =s.TransId 
	INNER JOIN  tblMpOrderReleases l ON  l.Id=r.ReleaseId 
	Where s.TransId = @EntryNum  
 End
Else If @SourceId = 2
Begin
	--retrieve resultset from SD Transaction/Work order
	SELECT @SourceId SourceId, w.CustID,w.SiteID,w.Attention,w.Address1
		,w.Address2,w.City,w.Region,w.Country,c.[Name] CountryName,w.PostalCode
		,w.Phone1
	FROM dbo.tblSvWorkOrderTrans t
	INNER JOIN dbo.tblSvWorkOrder w ON t.WorkOrderID = w.Id
	LEFT JOIN #tmpCountryList c ON w.Country = c.Country
	Where t.ID = @EntryNum	
End
Else If @SourceId = 4
Begin
	--retrieve resultset from WM Transfer	
	Select @SourceId SourceId, LocIdTo, Cmnt
		From dbo.tblWmTransfer t
		Where t.TranKey = @EntryNum
End
Else If @SourceId = 8
Begin
	--retrieve resultset from WM Material Req
	Select @SourceId SourceId, ReqNum, ReqstdBy, DatePlaced, DateNeeded
		, ShipToId, ShipVia, Notes
		From dbo.tblWmMatReq m
		Where m.TranKey = @EntryNum	
End
Else If @SourceId = 32
Begin
	--retrieve resultset from PC Material Req
	Select @SourceId SourceId, p.CustId, p.ProjectName, d.PhaseId, d.TaskId
		From dbo.tblPcTrans m INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		Where m.Id = @EntryNum	
End
Else If @SourceId = 64
Begin
	--retrieve resultset from PO return
	Select @SourceId SourceId, h.VendorId
		, Case When h.ShipToName is null Then c.Name Else h.ShipToName End ShipToName
		, Case When h.ShipToName is null Then c.Addr1 Else h.ShipToAddr1 End ShipToAddr1
		, Case When h.ShipToName is null Then c.Addr2 Else h.ShipToAddr2 End ShipToAddr2
		, Case When h.ShipToName is null Then c.City Else h.ShipToCity End ShipToCity
		, Case When h.ShipToName is null Then c.Region Else h.ShipToRegion End ShipToRegion
		, Case When h.ShipToName is null Then c.Country Else h.ShipToCountry End ShipToCountry
		, Case When h.ShipToName is null Then uc.[Name] Else uh.[Name] End ShipToCountryName
		, Case When h.ShipToName is null Then c.PostalCode Else h.ShipToPostalCode End ShipToPostalCode
		, c.Phone ShipToPhone
		, h.ShipVia
		From dbo.tblPoTransHeader h Left Join dbo.tblApVendor c
		on h.VendorId = c.VendorId
		Left Join #tmpCountryList uh
		on h.ShipToCountry = uh.Country
		Left Join #tmpCountryList uc
		on c.Country = uc.Country
		Where h.TransId = @TransId
End
Else
Begin
	--return error via resultset
	Select @SourceId SourceId, 'Invalid Source ID' ErrMsg 
End

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmPickTrans_OrderInfo_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmPickTrans_OrderInfo_proc';

