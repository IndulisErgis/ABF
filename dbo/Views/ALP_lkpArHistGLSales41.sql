CREATE VIEW ALP_lkpArHistGLSales41 WITH SCHEMABINDING AS
SELECT Postrun, TransId, EntryNum, WhseId, PartId, PartType, AcctCode, GLAcctSales,GLAcctCogs, GLAcctInv, PriceExt 
from dbo.tblArHistDetail where GLAcctSales like '41%'