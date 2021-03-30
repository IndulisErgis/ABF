CREATE VIEW dbo.ALP_qryCSBSComparisonResults
AS
SELECT     C.Transmitter, E.ErrorCode
FROM         dbo.ALP_tblCSBSComparisonResults AS C INNER JOIN
                      dbo.ALP_tblCSBSComparisonResultsErrors AS E ON C.Transmitter = E.Transmitter