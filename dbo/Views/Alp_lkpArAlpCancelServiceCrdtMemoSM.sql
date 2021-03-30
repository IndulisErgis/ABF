
CREATE VIEW dbo.Alp_lkpArAlpCancelServiceCrdtMemoSM    
AS    
SELECT     TOP 100 PERCENT ItemCode, [Desc], AlpAcctCode, GLAcctSales, GLAcctCogs, AlpServiceType 
--added by mah 07/13/15:
,ItemCode as ItemId, [Desc] as Descr    
FROM         dbo.alp_tblSmItem_view    
ORDER BY ItemCode