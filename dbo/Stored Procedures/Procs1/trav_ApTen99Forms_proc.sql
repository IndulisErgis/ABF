
CREATE PROCEDURE dbo.trav_ApTen99Forms_proc

--http://traversedev.internal.osas.com:8090/pets/view.php?id=12079
--PET:http://webfront:801/view.php?id=240956

@Year  Smallint = 2009,
@PrintBy Smallint = 1 -- 0 = 1096 Summary, 1 = 1099-MISC, 3 = 1099 Worksheet

AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #tmpApTen99FormsRptSum
(VendorID pVendorID, YTDTen99Pmt pDecimal, Total nvarchar(1))

INSERT INTO  #tmpApTen99FormsRptSum(VendorID, YTDTen99Pmt, Total)
SELECT t.VendorId,  c.Amount AS TotalTen99Pmt, 1 
FROM #VendorList t INNER JOIN dbo.tblApTen99Edit c ON t.VendorId = c.VendorID
--GROUP BY t.VendorId
WHERE c.Amount > 0

IF (@PrintBy = 0) -- 1096 Summary
BEGIN
      SELECT COUNT(*) AS TotalForms, SUM(FederalTaxWithheld) AS FederalTaxWithheld
		, SUM(Box1 + Box2 + Box3 + Box5 + Box6 + Box7 + Box8 + Box10 + Box13 + Box14) AS TotalAmountReported 
      FROM
      (
            SELECT v.VendorID
				, CASE WHEN v.Ten99FieldIndicator = '4' 
                        THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS FederalTaxWithheld
				, CASE WHEN v.Ten99FieldIndicator = '1' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box1
				, CASE WHEN v.Ten99FieldIndicator = '2' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box2
				, CASE WHEN v.Ten99FieldIndicator = '3' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box3
				, CASE WHEN v.Ten99FieldIndicator = '5' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box5
				, CASE WHEN v.Ten99FieldIndicator = '6' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box6
				, CASE WHEN v.Ten99FieldIndicator = '7' THEN t.YTDTen99Pmt ELSE 
					CASE WHEN v.Ten99FieldIndicator = 'E' AND t.YTDTen99Pmt >= 600
						THEN t.YTDTen99Pmt ELSE 0 END END AS Box7
				, CASE WHEN v.Ten99FieldIndicator = '8' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box8
				, CASE WHEN v.Ten99FieldIndicator = 'A' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box10
				, CASE WHEN v.Ten99FieldIndicator = 'B' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box13
				, CASE WHEN v.Ten99FieldIndicator = 'C' THEN t.YTDTen99Pmt ELSE CAST(0 AS dec) END AS Box14
            FROM #VendorList l 
                  INNER JOIN dbo.tblApTen99Edit v (NOLOCK) ON v.VendorID = l.VendorID 
                  INNER JOIN dbo.tblApTen99FieldIndic f (NOLOCK) ON v.Ten99FieldIndicator = f.IndicatorId 
                  INNER JOIN #tmpApTen99FormsRptSum t ON v.VendorID = t.VendorID 
            WHERE v.Ten99FormCode <> '0' 
				AND t.YTDTen99Pmt >= f.Limit
      ) tmp
END

if @PrintBy  = 1
begin



SELECT v.VendorID,v.[Name],CASE WHEN v.[Name] <> v.PayToName THEN v.PayToName ELSE NULL END PayToName,v.City,v.Region,v.PostalCode,
CASE WHEN v.SecondTINNotYN = 1 THEN 'X' ELSE '' END SecondTIN, CASE WHEN v.FATCAFilingYN = 1 THEN 'X' ELSE '' END FATCAFiling,
      CASE WHEN v.Ten99FieldIndicator = '9' AND t.YTDTen99Pmt >= f.Limit THEN 'X' ELSE '' END DirectSales,
      v.Ten99RecipientID,v.Ten99FormCode,f.IndicatorId,f.[Desc],f.Limit,
      v.Addr1 AS  Address1,v.Addr2 AS  Address2,
      CASE WHEN v.Ten99FieldIndicator = '1' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box1,
      CASE WHEN v.Ten99FieldIndicator = '2' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box2,
      CASE WHEN v.Ten99FieldIndicator = '3' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box3,
      CASE WHEN v.Ten99FieldIndicator = '4' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box4,
      CASE WHEN v.Ten99FieldIndicator = '5' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box5,
      CASE WHEN v.Ten99FieldIndicator = '6' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box6,
      CASE WHEN v.Ten99FieldIndicator = '7' THEN t.YTDTen99Pmt ELSE 
            CASE WHEN v.Ten99FieldIndicator = 'E' AND t.YTDTen99Pmt >= 600
            THEN t.YTDTen99Pmt ELSE 0 END END AS Box7,
      CASE WHEN v.Ten99FieldIndicator = '8' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box8,
      CASE WHEN v.Ten99FieldIndicator = '9' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box9,
      CASE WHEN v.Ten99FieldIndicator = 'A' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box10,
      CASE WHEN v.Ten99FieldIndicator = 'B' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box13,
      CASE WHEN v.Ten99FieldIndicator = 'C' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box14,
      CASE WHEN v.Ten99FieldIndicator = 'D' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box15a,
      CASE WHEN v.Ten99FieldIndicator = 'E' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box15b, 
    @Year as  sYear   
 
 
FROM #VendorList l inner Join dbo.tblApTen99Edit v (NOLOCK) ON v.VendorID = l.VendorID 
 INNER JOIN tblApTen99FieldIndic f (NOLOCK)
      ON v.Ten99FieldIndicator = f.IndicatorId INNER JOIN #tmpApTen99FormsRptSum t
      ON v.VendorID = t.VendorID 
WHERE 
      v.Ten99FormCode <> '0' 
  AND t.YTDTen99Pmt >= f.Limit 

end


if @PrintBy  = 3
begin

SELECT v.VendorID,v.[Name] + CASE WHEN ISNULL(v.PayToName,'') = '' THEN '' ELSE '/' + v.PayToName END AS [Name],c.[Desc] ,v.Ten99RecipientID,v.Ten99FieldIndicator,t.YTDTen99Pmt,
    CASE WHEN v.Ten99FieldIndicator = '1' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS  Box1, 
      CASE WHEN v.Ten99FieldIndicator = '2' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box2,
      CASE WHEN v.Ten99FieldIndicator = '3' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box3,
    CASE WHEN v.Ten99FieldIndicator = '4' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box4,
      CASE WHEN v.Ten99FieldIndicator = '5' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box5,
      CASE WHEN v.Ten99FieldIndicator = '6' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box6,
      CASE WHEN v.Ten99FieldIndicator = '7' THEN t.YTDTen99Pmt ELSE 
            CASE WHEN v.Ten99FieldIndicator = 'E' AND t.YTDTen99Pmt >= 600
            THEN t.YTDTen99Pmt ELSE 0 END END AS Box7,
      CASE WHEN v.Ten99FieldIndicator = '8' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box8,
      CASE WHEN v.Ten99FieldIndicator = '9' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box9,
      CASE WHEN v.Ten99FieldIndicator = 'A' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box10,
      CASE WHEN v.Ten99FieldIndicator = 'B' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box13,
      CASE WHEN v.Ten99FieldIndicator = 'C' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box14,
      CASE WHEN v.Ten99FieldIndicator = 'D' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box15a,
      CASE WHEN v.Ten99FieldIndicator = 'E' THEN t.YTDTen99Pmt ELSE cast(0 as dec) END AS Box15b,  
    tot.Desc1,tot.Desc2,tot.Desc3,tot.Desc4,tot.Desc5,tot.Desc6,tot.Desc7,tot.Desc8,tot.Desc9,tot.Desc10,
    tot.Desc13,tot.Desc14,tot.Desc15a,tot.Desc15b, @Year as  sYear
FROM 
#VendorList l inner Join dbo.tblApTen99Edit v (NOLOCK) ON v.VendorID = l.VendorID 
 INNER JOIN tblApTen99FieldIndic f (NOLOCK)
      ON v.Ten99FieldIndicator = f.IndicatorId INNER JOIN tblApTen99FormCode c (NOLOCK) 
      ON v.Ten99FormCode = c.FormCode     INNER JOIN #tmpApTen99FormsRptSum t
      ON v.VendorID = t.VendorID and v.VendorID = l.VendorID 
Left Join
(
Select 1 as  Total, max(ff.Desc1) Desc1, max(ff.Desc2) Desc2, max(ff.Desc3) Desc3, max(ff.Desc4) Desc4, max(ff.Desc5) Desc5, max(ff.Desc6) Desc6, max(ff.Desc7) Desc7, max(ff.Desc8) Desc8
, max(ff.Desc9) Desc9, max(ff.Desc10) Desc10, max(ff.Desc13) Desc13, max(ff.Desc14) Desc14, max(ff.Desc15a) Desc15a, max(ff.Desc15b) Desc15b from 
 (
  Select 
      Case When IndicatorId = '1' then [Desc] else '' end Desc1, 
      Case When IndicatorId = '2' then [Desc] else '' end Desc2, 
      Case When IndicatorId = '3' then [Desc] else '' end Desc3, 
      Case When IndicatorId = '4' then [Desc] else '' end Desc4, 
      Case When IndicatorId = '5' then [Desc] else '' end Desc5, 
      Case When IndicatorId = '6' then [Desc] else '' end Desc6, 
      Case When IndicatorId = '7' then [Desc] else '' end Desc7, 
      Case When IndicatorId = '8' then [Desc] else '' end Desc8, 
      Case When IndicatorId = '9' then [Desc] else '' end Desc9, 
      Case When IndicatorId = 'A' then [Desc] else '' end Desc10,
      Case When IndicatorId = 'B' then [Desc] else '' end Desc13,
      Case When IndicatorId = 'C' then [Desc] else '' end Desc14,
      Case When IndicatorId = 'D' then [Desc] else '' end Desc15a,
      Case When IndicatorId = 'E' then [Desc] else '' end Desc15b
      from dbo.tblApTen99FieldIndic ) ff 
   )
    tot

on tot.Total =  t.Total
WHERE 
      v.Ten99FormCode <> '0' AND t.YTDTen99Pmt >= f.Limit 
ORDER BY v.VendorID

end 

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTen99Forms_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTen99Forms_proc';

