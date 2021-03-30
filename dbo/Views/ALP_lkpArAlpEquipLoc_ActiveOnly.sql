
CREATE VIEW dbo.ALP_lkpArAlpEquipLoc_ActiveOnly AS SELECT TOP 100 PERCENT EquipLoc FROM dbo.ALP_tblArAlpEquipLoc WHERE (InactiveYN = 0) ORDER BY EquipLoc