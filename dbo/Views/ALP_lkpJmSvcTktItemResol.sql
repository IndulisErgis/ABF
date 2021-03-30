
CREATE VIEW dbo.ALP_lkpJmSvcTktItemResol AS SELECT ItemId, dbo.ALP_tblJmSvcTktItem.[Desc] AS Descr, UnitPrice,
Comments, WhseId, QtyAdded,TicketId,TreatAsPartYN,[Action] FROM dbo.ALP_tblJmSvcTktItem LEFT JOIN dbo.ALP_tblJmResolution ON 
dbo.ALP_tblJmSvcTktItem.ResolutionID = dbo.ALP_tblJmResolution.ResolutionId