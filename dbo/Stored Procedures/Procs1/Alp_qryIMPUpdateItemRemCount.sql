Create Procedure Alp_qryIMPUpdateItemRemCount  AS
 BEGIN
 select importmainid, ItemCount= COUNT (*) into #t1 from Alp_tblIMPItem group by ImportMainId
 Update Alp_tblIMPMain SET Source_PartCnt = ItemCount FROM Alp_tblIMPMain a INNER JOIN #t1 b ON a.ImportMainId =b.ImportMainId
 
 select importmainid,ImportedCount= SUM(IsImported )into #t2 from Alp_tblIMPItem group by ImportMainId
 Update Alp_tblIMPMain SET Source_PartCnt = Source_PartCnt - ImportedCount FROM Alp_tblIMPMain a INNER JOIN #t2 b ON a.ImportMainId =b.ImportMainId
 
 END