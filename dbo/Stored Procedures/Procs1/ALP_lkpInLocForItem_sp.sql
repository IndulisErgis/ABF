CREATE Procedure [dbo].[ALP_lkpInLocForItem_sp]
@ItemID pItemId
AS
SET NOCOUNT ON
 SELECT tblInLoc.LocId, tblInLoc.Descr
 FROM tblInLoc (NOLOCK) INNER JOIN tblInItemLoc (NOLOCK)
 ON tblInLoc.LocId = tblInItemLoc.LocId
 WHERE tblInItemLoc.ItemId=@ItemID
 ORDER BY tblInLoc.LocID