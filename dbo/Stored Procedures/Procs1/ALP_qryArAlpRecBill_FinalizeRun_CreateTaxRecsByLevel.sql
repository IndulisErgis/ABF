

  
CREATE  Procedure [dbo].[ALP_qryArAlpRecBill_FinalizeRun_CreateTaxRecsByLevel]            
--mah 12/28/15 - created to build Tax records for Recurring Billing auto generated transactions.      
--     After recent OSAS updates, the AR bulk insert of transactions is not handling it.     
--  This version assigns records by each tax level within the tax group  
      
 @RunId integer        
AS            
SET NOCOUNT ON            
    
--find all sites touched, all recurring invoices just created       
SELECT DISTINCT          
  [rr].[InvoiceSiteId] as SiteId, [rr].[CustId]  INTO #TouchedSites         
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]          
 WHERE [rr].[RunId] = @RunId     
   
SELECT D.TransId, MAX(D.TaxClass) AS TaxClass INTO #RecTransIDs    
FROM tblArTransDetail D INNER JOIN tblArTransHeader H ON D.TransId = H.TransId    
 INNER JOIN ALP_tblArTransHeader AH ON H.TransID = AH.AlpTransID    
 INNER JOIN #TouchedSites S ON AH.AlpSiteID = S.SiteId   
 LEFT OUTER JOIN tblArTransTax TAX ON  H.TransID = TAX.TransID  
WHERE TAX.TransID IS NULL AND H.TransType = 1 AND H.InvcNum LIKE 'R%' AND H.TaxableYN = 1 
 AND  H.CustID = S.CustId
GROUP BY D.TransId    
  
--mah 12/30/15:  
 --Summarize transaction amounts by tax class, 12/30/15 version for recurring billing  
   select D.TransID, TaxGrpID, D.TaxClass,SUM(QtyShipSell * UnitPriceSell) AS TaxableAmt, SUM(QtyShipSell * UnitPriceSellFgn) AS TaxableAmtFgn  
    INTO #TransClasses from tblArTransDetail D INNER JOIN tblArTRansHeader H ON D.TransID = H.TRansID  
    INNER JOIN #RecTransIDs R ON H.TransID = R.TransID  
    --where D.transid = @TransId   
    GROUP BY D.TransID, TaxGrpID, D.TaxClass   
  
 --Create temp records by tax class and tax location, 12/30/15 version for recurring billing  
  CREATE table #TaxGroupDetails ( TransID pTransID, TaxGrpID pTaxLoc, TaxClass tinyInt, LevelOne pTaxLoc NULL, LevelTwo pTaxLoc NULL, LevelThree pTaxLoc NULL,   
      LevelFour pTaxLoc NULL, LevelFive pTaxLoc NULL, TaxableAmount decimal(18,10),TaxableAmountFgn decimal(18,10),  
      LevelOneTax pDec NULL,LevelTwoTax pDec NULL,LevelThreeTax pDec NULL,LevelFourTax pDec NULL,LevelFiveTax pDec NULL,TotalCalculatedTax decimal (18,10),  
      LevelOneTaxFgn pDec NULL, LevelTwoTaxFgn pDec NULL, LevelThreeTaxFgn pDec NULL, LevelFourTaxFgn pDec NULL, LevelFiveTaxFgn pDec NULL, TotalCalculatedTaxFgn decimal (18,10))  
  INSERT INTO #TaxGroupDetails ( TransID,TaxGrpID,TaxClass,LevelOne,LevelTwo,LevelThree,LevelFour,LevelFive,  
    TaxableAmount,TaxableAmountFgn, LevelOneTax,LevelTwoTax,LevelThreeTax,LevelFourTax,LevelFiveTax,   
    TotalCalculatedTax,LevelOneTaxFgn, LevelTwoTaxFgn, LevelThreeTaxFgn, LevelFourTaxFgn, LevelFiveTaxFgn, TotalCalculatedTaxFgn)  
    SELECT tc.TransID, tc.TaxGrpID, tc.TaxClass, LevelOne, LevelTwo, LevelThree, LevelFour, LevelFive, tc.TaxableAmt,tc.TaxableAmtFgn,  
     NULL,NULL,NULL,NULL,NULL,0, NULL,NULL,NULL,NULL,NULL,0   
    FROM tblSmTaxGroup INNER JOIN #TransClasses tc ON tblSmTaxGroup.TaxGrpID = tc.TaxGrpID   
  
 --Calculate taxes at each level.  Must do in order, to calculate Tax-on-tax correctly - 12/30/15 - NO CHANGES NEEDED IN THIS SECTION FOR RECURRING BILLING???  
 --level One          
  UPDATE #TaxGroupDetails SET LevelOneTax = ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2), TotalCalculatedTax = TotalCalculatedTax + ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2),  
     LevelOneTaxFgn = ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2), TotalCalculatedTaxFgn = TotalCalculatedTaxFgn + ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
    FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelOne = TLC.TaxLocId  
                 AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass  
    WHERE #TaxGroupDetails.LevelOne IS NOT NULL  
  INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
         NonTaxable, NonTaxableFgn, LiabilityAcct )        
   SELECT c.TransId, tgd.LevelOne, c.TaxClass,1, tgd.LevelOneTax, tgd.LevelOneTaxFgn,   
     CASE WHEN tgd.LevelOneTax IS NULL then 0 WHEN tgd.LevelOneTax = 0 then 0 ELSE tgd.TaxableAmount END AS Taxable,     
     CASE WHEN tgd.LevelOneTaxFgn IS NULL then 0 WHEN tgd.LevelOneTaxFgn = 0 then 0 ELSE tgd.TaxableAmountFgn END AS TaxableFgn,      
     CASE WHEN tgd.LevelOneTax IS NULL then tgd.TaxableAmount WHEN tgd.LevelOneTax = 0 then tgd.TaxableAmount  ELSE 0 END AS NonTaxable,     
     CASE WHEN tgd.LevelOneTaxFgn IS NULL then tgd.TaxableAmountFgn WHEN tgd.LevelOneTaxFgn = 0 then tgd.TaxableAmountFgn ELSE 0 END AS NonTaxableFgn,          
     tblSmTaxLoc.GLAcct    
   FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TransId = tgd.TransId  AND c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID  
    INNER JOIN tblSmTaxLoc ON tgd.LevelOne = tblSmTaxLoc.TaxLocID  
   WHERE  tgd.LevelOne IS NOT NULL and tgd.LevelOneTax <> 0     
  
  --level two    
  UPDATE #TaxGroupDetails SET   
     LevelTwoTax = CASE WHEN SmTaxDet.Tax1 = 0 THEN ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)   
     ELSE ROUND(((TaxableAmount + LevelOneTax)* (TLC.SalesTaxPct/100.00)),2)   
     END,  
     TotalCalculatedTax = CASE WHEN SmTaxDet.Tax1 = 0 THEN TotalCalculatedTax + ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTax + ROUND(((TaxableAmount + LevelOneTax) * (TLC.SalesTaxPct/100.00)),2)  
     END,  
     LevelTwoTaxFgn = CASE WHEN SmTaxDet.Tax1 = 0  THEN ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE ROUND(((TaxableAmountFgn  + LevelOneTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TotalCalculatedTaxFgn = CASE WHEN SmTaxDet.Tax1 = 0  THEN TotalCalculatedTaxFgn + ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTaxFgn + ROUND(((TaxableAmountFgn  + LevelOneTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TaxableAmount = CASE WHEN SmTaxDet.Tax1 = 0 THEN TaxableAmount ELSE ROUND((TaxableAmount + LevelOneTax),2)  END,  
     TaxableAmountFgn = CASE WHEN SmTaxDet.Tax1 = 0 THEN TaxableAmountFgn ELSE ROUND((TaxableAmountFgn + LevelOneTax),2)  END  
    FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelTwo = TLC.TaxLocId  
                 AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass  
     INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 2 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelTwo  
    WHERE #TaxGroupDetails.LevelTwo IS NOT NULL  
  INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
         NonTaxable, NonTaxableFgn, LiabilityAcct )     
    SELECT c.TransId, tgd.LevelTwo, c.TaxClass,2, tgd.LevelTwoTax,  tgd.LevelTwoTaxFgn,   
      Taxable = CASE WHEN tgd.LevelTwoTax IS NULL then 0 WHEN tgd.LevelTwoTax = 0 then 0 ELSE tgd.TaxableAmount END,     
      TaxableFgn = CASE WHEN tgd.LevelTwoTaxFgn IS NULL then 0 WHEN tgd.LevelTwoTaxFgn = 0 then 0 ELSE tgd.TaxableAmountFgn END,      
      NonTaxable = CASE WHEN tgd.LevelTwoTax IS NULL then tgd.TaxableAmount WHEN tgd.LevelTwoTax = 0 then tgd.TaxableAmount  ELSE 0 END,     
      NonTaxableFgn =CASE WHEN tgd.LevelTwoTaxFgn IS NULL then tgd.TaxableAmountFgn WHEN tgd.LevelTwoTaxFgn = 0 then tgd.TaxableAmountFgn ELSE 0 END,          
      LiabilityAcct = tblSmTaxLoc.GLAcct    
    FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TransId = tgd.TransId  AND c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID  
     INNER JOIN tblSmTaxLoc ON tgd.LevelTwo = tblSmTaxLoc.TaxLocID  
    WHERE  tgd.LevelTwo IS NOT NULL and tgd.LevelTwoTax <> 0  
  
  --level three    
  UPDATE #TaxGroupDetails SET   
     LevelThreeTax = CASE WHEN SmTaxDet.Tax2 = 0 THEN ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)   
     ELSE ROUND(((TaxableAmount + LevelTwoTax)* (TLC.SalesTaxPct/100.00)),2)   
     END,  
     TotalCalculatedTax = CASE WHEN SmTaxDet.Tax2 = 0 THEN TotalCalculatedTax + ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTax + ROUND(((TaxableAmount + LevelTwoTax) * (TLC.SalesTaxPct/100.00)),2)  
     END,  
     LevelThreeTaxFgn = CASE WHEN SmTaxDet.Tax2 = 0  THEN ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE ROUND(((TaxableAmountFgn  + LevelTwoTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TotalCalculatedTaxFgn = CASE WHEN SmTaxDet.Tax2 = 0  THEN TotalCalculatedTaxFgn + ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTaxFgn + ROUND(((TaxableAmountFgn  + LevelTwoTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TaxableAmount = CASE WHEN SmTaxDet.Tax2 = 0 THEN TaxableAmount ELSE ROUND((TaxableAmount + LevelTwoTax),2)  END,  
     TaxableAmountFgn = CASE WHEN SmTaxDet.Tax2 = 0 THEN TaxableAmountFgn ELSE ROUND((TaxableAmountFgn + LevelTwoTax),2)  END  
    FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelThree = TLC.TaxLocId  
                 AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass  
     INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 3 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelThree  
    WHERE #TaxGroupDetails.LevelThree IS NOT NULL   
   INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
         NonTaxable, NonTaxableFgn, LiabilityAcct )      
     SELECT c.TransId, tgd.LevelThree, c.TaxClass,3, tgd.LevelThreeTax, tgd.LevelThreeTaxFgn,   
       Taxable = CASE WHEN tgd.LevelThreeTax IS NULL then 0 WHEN tgd.LevelThreeTax = 0 then 0 ELSE tgd.TaxableAmount END,     
       TaxableFgn = CASE WHEN tgd.LevelThreeTaxFgn IS NULL then 0 WHEN tgd.LevelThreeTaxFgn = 0 then 0 ELSE tgd.TaxableAmountFgn END,      
       NonTaxable = CASE WHEN tgd.LevelThreeTax IS NULL then tgd.TaxableAmount WHEN tgd.LevelThreeTax = 0 then tgd.TaxableAmount  ELSE 0 END,     
       NonTaxableFgn =CASE WHEN tgd.LevelThreeTaxFgn IS NULL then tgd.TaxableAmountFgn WHEN tgd.LevelThreeTaxFgn = 0 then tgd.TaxableAmountFgn ELSE 0 END,          
       LiabilityAcct = tblSmTaxLoc.GLAcct    
     FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TransId = tgd.TransId  AND c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID  
      INNER JOIN tblSmTaxLoc ON tgd.LevelThree = tblSmTaxLoc.TaxLocID  
     WHERE  tgd.LevelThree IS NOT NULL  and tgd.LevelThreeTax <> 0  
  
  --level Four  
  UPDATE #TaxGroupDetails SET   
     LevelFourTax = CASE WHEN SmTaxDet.Tax3 = 0 THEN ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)   
     ELSE ROUND(((TaxableAmount + LevelThreeTax)* (TLC.SalesTaxPct/100.00)),2)   
     END,  
     TotalCalculatedTax = CASE WHEN SmTaxDet.Tax3 = 0 THEN TotalCalculatedTax + ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTax + ROUND(((TaxableAmount + LevelThreeTax) * (TLC.SalesTaxPct/100.00)),2)  
     END,  
     LevelFourTaxFgn = CASE WHEN SmTaxDet.Tax3 = 0  THEN ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE ROUND(((TaxableAmountFgn  + LevelThreeTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TotalCalculatedTaxFgn = CASE WHEN SmTaxDet.Tax3 = 0  THEN TotalCalculatedTaxFgn + ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTaxFgn + ROUND(((TaxableAmountFgn  + LevelThreeTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TaxableAmount = CASE WHEN SmTaxDet.Tax3 = 0 THEN TaxableAmount ELSE ROUND((TaxableAmount + LevelThreeTax),2)  END,  
     TaxableAmountFgn = CASE WHEN SmTaxDet.Tax3 = 0 THEN TaxableAmountFgn ELSE ROUND((TaxableAmountFgn + LevelThreeTax),2)  END  
    FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelFour = TLC.TaxLocId  
                 AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass  
     INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 4 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelFour  
    WHERE #TaxGroupDetails.LevelFour IS NOT NULL  
   INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
         NonTaxable, NonTaxableFgn, LiabilityAcct )     
     SELECT c.TransId, tgd.LevelFour, c.TaxClass,4, tgd.LevelFourTax, tgd.LevelFourTaxFgn,   
       Taxable = CASE WHEN tgd.LevelFourTax IS NULL then 0 WHEN tgd.LevelFourTax = 0 then 0 ELSE tgd.TaxableAmount END,     
       TaxableFgn = CASE WHEN tgd.LevelFourTaxFgn IS NULL then 0 WHEN tgd.LevelFourTaxFgn = 0 then 0 ELSE tgd.TaxableAmountFgn END,      
       NonTaxable = CASE WHEN tgd.LevelFourTax IS NULL then tgd.TaxableAmount WHEN tgd.LevelFourTax = 0 then tgd.TaxableAmount  ELSE 0 END,     
       NonTaxableFgn =CASE WHEN tgd.LevelFourTaxFgn IS NULL then tgd.TaxableAmountFgn WHEN tgd.LevelFourTaxFgn = 0 then tgd.TaxableAmountFgn ELSE 0 END,          
       LiabilityAcct = tblSmTaxLoc.GLAcct    
     FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TransId = tgd.TransId  AND c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID  
      INNER JOIN tblSmTaxLoc ON tgd.LevelFour = tblSmTaxLoc.TaxLocID  
     WHERE  tgd.LevelFour IS NOT NULL  and tgd.LevelFourTax <> 0  
  
    
  --level five  
  UPDATE #TaxGroupDetails SET   
     LevelFiveTax = CASE WHEN SmTaxDet.Tax4 = 0 THEN ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)   
     ELSE ROUND(((TaxableAmount + LevelFourTax)* (TLC.SalesTaxPct/100.00)),2)   
     END,  
     TotalCalculatedTax = CASE WHEN SmTaxDet.Tax4 = 0 THEN TotalCalculatedTax + ROUND((TaxableAmount * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTax + ROUND(((TaxableAmount + LevelFourTax) * (TLC.SalesTaxPct/100.00)),2)  
     END,  
     LevelFiveTaxFgn = CASE WHEN SmTaxDet.Tax4 = 0  THEN ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE ROUND(((TaxableAmountFgn  + LevelFourTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TotalCalculatedTaxFgn = CASE WHEN SmTaxDet.Tax4 = 0  THEN TotalCalculatedTaxFgn + ROUND((TaxableAmountFgn * (TLC.SalesTaxPct/100.00)),2)  
     ELSE TotalCalculatedTaxFgn + ROUND(((TaxableAmountFgn  + LevelFourTaxFgn)* (TLC.SalesTaxPct/100.00)),2)  
     END,  
     TaxableAmount = CASE WHEN SmTaxDet.Tax4 = 0 THEN TaxableAmount ELSE ROUND((TaxableAmount + LevelFourTax),2)  END,  
     TaxableAmountFgn = CASE WHEN SmTaxDet.Tax4 = 0 THEN TaxableAmountFgn ELSE ROUND((TaxableAmountFgn + LevelFourTax),2)  END  
    FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelFive = TLC.TaxLocId  
                 AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass  
     INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 5 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelFive  
    WHERE #TaxGroupDetails.LevelFive IS NOT NULL      
  INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
         NonTaxable, NonTaxableFgn, LiabilityAcct )     
     SELECT c.TransId, tgd.LevelFive, c.TaxClass,5, tgd.LevelFiveTax, tgd.LevelFiveTaxFgn,   
       Taxable = CASE WHEN tgd.LevelFiveTax IS NULL then 0 WHEN tgd.LevelFiveTax = 0 then 0 ELSE tgd.TaxableAmount END,     
       TaxableFgn = CASE WHEN tgd.LevelFiveTaxFgn IS NULL then 0 WHEN tgd.LevelFiveTaxFgn = 0 then 0 ELSE tgd.TaxableAmountFgn END,      
       NonTaxable = CASE WHEN tgd.LevelFiveTax IS NULL then tgd.TaxableAmount WHEN tgd.LevelFiveTax = 0 then tgd.TaxableAmount  ELSE 0 END,     
       NonTaxableFgn =CASE WHEN tgd.LevelFiveTaxFgn IS NULL then tgd.TaxableAmountFgn WHEN tgd.LevelFiveTaxFgn = 0 then tgd.TaxableAmountFgn ELSE 0 END,          
       LiabilityAcct = tblSmTaxLoc.GLAcct    
     FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TransId = tgd.TransId  AND c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID  
      INNER JOIN tblSmTaxLoc ON tgd.LevelFive = tblSmTaxLoc.TaxLocID  
     WHERE  tgd.LevelFive IS NOT NULL and tgd.LevelFiveTax <> 0      
  
 --cleanup   
     drop table #TouchedSites  
     drop table #RecTransIDs  
     drop table #TaxGroupDetails  
     drop table #TransClasses