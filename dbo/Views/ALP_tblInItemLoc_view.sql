
Create view [dbo].[ALP_tblInItemLoc_view] as
select ALP_tblInItemLoc.AlpInstalledPrice,ALP_tblInItemLoc.AlpItemId,
ALP_tblInItemLoc.AlpLocId
 from tblInItemLoc left join ALP_tblInItemLoc
 on tblInItemLoc.ItemId=ALP_tblInItemLoc.AlpItemId and
  tblInItemLoc.LocId=ALP_tblInItemLoc.AlpLocId