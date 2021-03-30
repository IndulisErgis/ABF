
CREATE VIEW dbo.ALP_lkpJmTech AS SELECT Tech, Name, TechID FROM dbo.ALP_tblJmTech WHERE (dbo.ALP_tblJmTech.InactiveYN = 0)