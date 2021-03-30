
CREATE VIEW [dbo].[ALP_lkpSmItem] AS SELECT ItemCode, [Desc] as Descr,TaxClass,
--AlpItemStatus added by NSK on 24 Sep 2014
AlpItemStatus 
FROM ALP_tblSmItem_view