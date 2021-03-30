
CREATE VIEW dbo.ALP_lkpArAlpEquipLoc AS
SELECT EquipLoc, InactiveYN FROM dbo.ALP_tblArAlpEquipLoc WHERE InactiveYN=0