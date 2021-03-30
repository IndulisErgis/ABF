
CREATE  Procedure [dbo].[ALP_qryAlpEI_TransTax_Insert_sp]      
	@TransId pTransId 
--altered 4/11/16 - for customers using only one tax level
AS 
DECLARE @TotTaxable pDec
DECLARE @TotNonTaxable pDec 
DECLARE @TotTaxableFgn pDec
DECLARE @TotNonTaxableFgn pDec 
DECLARE @TaxableYn bit
SET @TotTaxable = 0
SET @TotNonTaxable = 0 
SET @TotTaxableFgn = 0
SET @TotNonTaxableFgn = 0 
SET @TaxableYn = 0
     
-- Created By MAH 12/02/2015 , to calculate detailed Sales tax amounts, by class and by level, and considering tax on tax option 
SET NOCOUNT ON   
	--
		 SET @TaxableYn = (SELECT TaxableYN FROM dbo.tblArTransHeader WHERE TransId = @TransId )
		 		   
	--Summarize transaction amounts by tax class
		 select D.TransID, TaxGrpID, D.TaxClass,SUM(QtyShipSell * UnitPriceSell) AS Amt, 
				SUM(QtyShipSell * UnitPriceSellFgn) AS AmtFgn
				INTO #TransClasses from tblArTransDetail D INNER JOIN tblArTRansHeader H ON D.TransID = H.TRansID
				where D.transid = @TransId GROUP BY D.TransID, TaxGrpID, D.TaxClass 
	--Create temp records by tax class and tax location
		CREATE table #TaxGroupDetails ( TaxGrpID pTaxLoc, TaxClass tinyInt, LevelOne pTaxLoc NULL, LevelTwo pTaxLoc NULL, LevelThree pTaxLoc NULL, 
						LevelFour pTaxLoc NULL, LevelFive pTaxLoc NULL, Amount decimal(18,10),AmountFgn decimal(18,10),
						LevelOneTax pDec NULL,LevelTwoTax pDec NULL,LevelThreeTax pDec NULL,LevelFourTax pDec NULL,LevelFiveTax pDec NULL,TotalCalculatedTax decimal (18,10),
						LevelOneTaxFgn pDec NULL, LevelTwoTaxFgn pDec NULL, LevelThreeTaxFgn pDec NULL, LevelFourTaxFgn pDec NULL, LevelFiveTaxFgn pDec NULL, TotalCalculatedTaxFgn decimal (18,10))
		INSERT INTO #TaxGroupDetails ( TaxGrpID,TaxClass,LevelOne,LevelTwo,LevelThree,LevelFour,LevelFive,
				Amount,AmountFgn, LevelOneTax,LevelTwoTax,LevelThreeTax,LevelFourTax,LevelFiveTax, 
				TotalCalculatedTax,LevelOneTaxFgn, LevelTwoTaxFgn, LevelThreeTaxFgn, LevelFourTaxFgn, LevelFiveTaxFgn, TotalCalculatedTaxFgn)
				SELECT tc.TaxGrpID, tc.TaxClass, LevelOne, LevelTwo, LevelThree, LevelFour, LevelFive, tc.Amt,tc.AmtFgn,
				 NULL,NULL,NULL,NULL,NULL,0, NULL,NULL,NULL,NULL,NULL,0 
				FROM tblSmTaxGroup INNER JOIN #TransClasses tc ON tblSmTaxGroup.TaxGrpID = tc.TaxGrpID 
				
	--Calculate taxes at each level.  Must do in order, to calculate Tax-on-tax correctly
	--level One								
		UPDATE #TaxGroupDetails SET 
				LevelOneTax = 
					CASE WHEN @TaxableYN = 0 THEN 0
					ELSE ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) END, 
				TotalCalculatedTax = CASE WHEN @TaxableYn = 0 THEN 0 
					ELSE TotalCalculatedTax + ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) END,
				LevelOneTaxFgn = CASE WHEN @TaxableYn = 0 THEN 0 
					ELSE ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2) END, 
				TotalCalculatedTaxFgn = CASE WHEN @TaxableYn = 0 THEN 0 
					ELSE TotalCalculatedTaxFgn + ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2) END
				FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelOne = TLC.TaxLocId
																	AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass
				WHERE #TaxGroupDetails.LevelOne IS NOT NULL
		INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, 
									NonTaxable, NonTaxableFgn, LiabilityAcct )      
			SELECT c.TransId, tgd.LevelOne, c.TaxClass,1, tgd.LevelOneTax, tgd.LevelOneTaxFgn,	
			  CASE WHEN tgd.LevelOneTax IS NULL then 0 WHEN tgd.LevelOneTax = 0 then 0 ELSE tgd.Amount END AS Taxable,	  
			  CASE WHEN tgd.LevelOneTaxFgn IS NULL then 0 WHEN tgd.LevelOneTaxFgn = 0 then 0 ELSE tgd.AmountFgn END AS TaxableFgn,		  
			  CASE WHEN tgd.LevelOneTax IS NULL then tgd.Amount WHEN tgd.LevelOneTax = 0 then tgd.Amount  ELSE 0 END AS NonTaxable,   
			  CASE WHEN tgd.LevelOneTaxFgn IS NULL then tgd.AmountFgn WHEN tgd.LevelOneTaxFgn = 0 then tgd.AmountFgn ELSE 0 END AS NonTaxableFgn,	       
			  tblSmTaxLoc.GLAcct  
			FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID
				INNER JOIN tblSmTaxLoc ON tgd.LevelOne = tblSmTaxLoc.TaxLocID
			WHERE  tgd.LevelOne IS NOT NULL				
				
		--level two		
		UPDATE #TaxGroupDetails SET 
					LevelTwoTax = CASE WHEN @TaxableYN = 0 THEN 0 
						ELSE CASE WHEN SmTaxDet.Tax1 = 0 
							THEN ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) 
							ELSE ROUND(((Amount + LevelOneTax)* (TLC.SalesTaxPct/100.00)),2) 
						END END,
					TotalCalculatedTax = CASE WHEN @TaxableYN = 0 THEN 0 
						ELSE CASE WHEN SmTaxDet.Tax1 = 0 THEN 
							TotalCalculatedTax + ROUND((Amount * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTax + ROUND(((Amount + LevelOneTax) * (TLC.SalesTaxPct/100.00)),2)
						END END,
					LevelTwoTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0 
						ELSE CASE WHEN SmTaxDet.Tax1 = 0  
							THEN ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE ROUND(((AmountFgn  + LevelOneTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					TotalCalculatedTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax1 = 0  
							THEN TotalCalculatedTaxFgn + ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTaxFgn + ROUND(((AmountFgn  + LevelOneTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					--?? change Amount and AmountFgn??
					Amount = CASE WHEN @TaxableYN = 0 THEN Amount
							ELSE CASE WHEN SmTaxDet.Tax1 = 0 THEN Amount 
							ELSE ROUND((Amount + LevelOneTax),2)  END END,
					AmountFgn = CASE WHEN @TaxableYN = 0 THEN AmountFgn 
							ELSE CASE WHEN SmTaxDet.Tax1 = 0 THEN AmountFgn 
							ELSE ROUND((AmountFgn + LevelOneTax),2)  END END
				FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelTwo = TLC.TaxLocId
																	AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass
					INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 2 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelTwo
				WHERE #TaxGroupDetails.LevelTwo IS NOT NULL
		INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, 
									NonTaxable, NonTaxableFgn, LiabilityAcct )   
				SELECT c.TransId, tgd.LevelTwo, c.TaxClass,2, tgd.LevelTwoTax,  tgd.LevelTwoTaxFgn,	
				  Taxable = CASE WHEN tgd.LevelTwoTax IS NULL then 0 WHEN tgd.LevelTwoTax = 0 then 0 ELSE tgd.Amount END,	  
				  TaxableFgn = CASE WHEN tgd.LevelTwoTaxFgn IS NULL then 0 WHEN tgd.LevelTwoTaxFgn = 0 then 0 ELSE tgd.AmountFgn END,		  
				  NonTaxable = CASE WHEN tgd.LevelTwoTax IS NULL then tgd.Amount WHEN tgd.LevelTwoTax = 0 then tgd.Amount  ELSE 0 END,   
				  NonTaxableFgn =CASE WHEN tgd.LevelTwoTaxFgn IS NULL then tgd.AmountFgn WHEN tgd.LevelTwoTaxFgn = 0 then tgd.AmountFgn ELSE 0 END,	       
				  LiabilityAcct = tblSmTaxLoc.GLAcct  
				FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID
					INNER JOIN tblSmTaxLoc ON tgd.LevelTwo = tblSmTaxLoc.TaxLocID
				WHERE  tgd.LevelTwo IS NOT NULL		
		
		--level three		
		UPDATE #TaxGroupDetails SET 
					LevelThreeTax = CASE WHEN @TaxableYn = 0 THEN 0 
						ELSE CASE WHEN SmTaxDet.Tax2 = 0 
							THEN ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) 
							ELSE ROUND(((Amount + LevelTwoTax)* (TLC.SalesTaxPct/100.00)),2) 
						END END,
					TotalCalculatedTax = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax2 = 0 
							THEN TotalCalculatedTax + ROUND((Amount * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTax + ROUND(((Amount + LevelTwoTax) * (TLC.SalesTaxPct/100.00)),2)
						END END,
					LevelThreeTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax2 = 0  
							THEN ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE ROUND(((AmountFgn  + LevelTwoTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					TotalCalculatedTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax2 = 0  
							THEN TotalCalculatedTaxFgn + ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTaxFgn + ROUND(((AmountFgn  + LevelTwoTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					Amount = CASE WHEN @TaxableYN = 0 THEN Amount
						ELSE CASE WHEN SmTaxDet.Tax2 = 0 THEN Amount 
						ELSE ROUND((Amount + LevelTwoTax),2)  END END,
					AmountFgn = CASE WHEN @TaxableYN = 0 THEN AmountFgn 
						ELSE CASE WHEN SmTaxDet.Tax2 = 0 THEN AmountFgn 
						ELSE ROUND((AmountFgn + LevelTwoTax),2)  END END
				FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelThree = TLC.TaxLocId
																	AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass
					INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 3 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelThree
				WHERE #TaxGroupDetails.LevelThree IS NOT NULL	
			INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, 
									NonTaxable, NonTaxableFgn, LiabilityAcct )   	
					SELECT c.TransId, tgd.LevelThree, c.TaxClass,3, tgd.LevelThreeTax, tgd.LevelThreeTaxFgn,	
					  Taxable = CASE WHEN tgd.LevelThreeTax IS NULL then 0 WHEN tgd.LevelThreeTax = 0 then 0 ELSE tgd.Amount END,	  
					  TaxableFgn = CASE WHEN tgd.LevelThreeTaxFgn IS NULL then 0 WHEN tgd.LevelThreeTaxFgn = 0 then 0 ELSE tgd.AmountFgn END,		  
					  NonTaxable = CASE WHEN tgd.LevelThreeTax IS NULL then tgd.Amount WHEN tgd.LevelThreeTax = 0 then tgd.Amount  ELSE 0 END,   
					  NonTaxableFgn =CASE WHEN tgd.LevelThreeTaxFgn IS NULL then tgd.AmountFgn WHEN tgd.LevelThreeTaxFgn = 0 then tgd.AmountFgn ELSE 0 END,	       
					  LiabilityAcct = tblSmTaxLoc.GLAcct  
					FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID
						INNER JOIN tblSmTaxLoc ON tgd.LevelThree = tblSmTaxLoc.TaxLocID
					WHERE  tgd.LevelThree IS NOT NULL
		
		--level Four
		UPDATE #TaxGroupDetails SET 
					LevelFourTax = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax3 = 0 THEN ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) 
							ELSE ROUND(((Amount + LevelThreeTax)* (TLC.SalesTaxPct/100.00)),2) 
						END END,
					TotalCalculatedTax = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax3 = 0 THEN TotalCalculatedTax + ROUND((Amount * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTax + ROUND(((Amount + LevelThreeTax) * (TLC.SalesTaxPct/100.00)),2)
						END END,
					LevelFourTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax3 = 0  THEN ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE ROUND(((AmountFgn  + LevelThreeTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					TotalCalculatedTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax3 = 0  
							THEN TotalCalculatedTaxFgn + ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTaxFgn + ROUND(((AmountFgn  + LevelThreeTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					Amount = CASE WHEN @TaxableYN = 0 THEN Amount 
						ELSE CASE WHEN SmTaxDet.Tax3 = 0 THEN Amount 
						ELSE ROUND((Amount + LevelThreeTax),2)  END END,
					AmountFgn = CASE WHEN @TaxableYN = 0 THEN AmountFgn 
						ELSE CASE WHEN SmTaxDet.Tax3 = 0 THEN AmountFgn ELSE ROUND((AmountFgn + LevelThreeTax),2)  END END
				FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelFour = TLC.TaxLocId
																	AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass
					INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 4 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelFour
				WHERE #TaxGroupDetails.LevelFour IS NOT NULL
			INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, 
									NonTaxable, NonTaxableFgn, LiabilityAcct )   
					SELECT c.TransId, tgd.LevelFour, c.TaxClass,4, tgd.LevelFourTax, tgd.LevelFourTaxFgn,	
					  Taxable = CASE WHEN tgd.LevelFourTax IS NULL then 0 WHEN tgd.LevelFourTax = 0 then 0 ELSE tgd.Amount END,	  
					  TaxableFgn = CASE WHEN tgd.LevelFourTaxFgn IS NULL then 0 WHEN tgd.LevelFourTaxFgn = 0 then 0 ELSE tgd.AmountFgn END,		  
					  NonTaxable = CASE WHEN tgd.LevelFourTax IS NULL then tgd.Amount WHEN tgd.LevelFourTax = 0 then tgd.Amount  ELSE 0 END,   
					  NonTaxableFgn =CASE WHEN tgd.LevelFourTaxFgn IS NULL then tgd.AmountFgn WHEN tgd.LevelFourTaxFgn = 0 then tgd.AmountFgn ELSE 0 END,	       
					  LiabilityAcct = tblSmTaxLoc.GLAcct  
					FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID
						INNER JOIN tblSmTaxLoc ON tgd.LevelFour = tblSmTaxLoc.TaxLocID
					WHERE  tgd.LevelFour IS NOT NULL
		
		
		--level five
		UPDATE #TaxGroupDetails SET 
					LevelFiveTax = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax4 = 0 
							THEN ROUND((Amount * (TLC.SalesTaxPct/100.00)),2) 
							ELSE ROUND(((Amount + LevelFourTax)* (TLC.SalesTaxPct/100.00)),2) 
						END END,
					TotalCalculatedTax = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax4 = 0 
							THEN TotalCalculatedTax + ROUND((Amount * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTax + ROUND(((Amount + LevelFourTax) * (TLC.SalesTaxPct/100.00)),2)
						END END,
					LevelFiveTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax4 = 0  
							THEN ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE ROUND(((AmountFgn  + LevelFourTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					TotalCalculatedTaxFgn = CASE WHEN @TaxableYN = 0 THEN 0
						ELSE CASE WHEN SmTaxDet.Tax4 = 0  
							THEN TotalCalculatedTaxFgn + ROUND((AmountFgn * (TLC.SalesTaxPct/100.00)),2)
							ELSE TotalCalculatedTaxFgn + ROUND(((AmountFgn  + LevelFourTaxFgn)* (TLC.SalesTaxPct/100.00)),2)
						END END,
					Amount = CASE WHEN @TaxableYN = 0 THEN Amount
						ELSE CASE WHEN SmTaxDet.Tax4 = 0 THEN Amount 
						ELSE ROUND((Amount + LevelFourTax),2)  END END,
					AmountFgn = CASE WHEN @TaxableYN = 0 THEN AmountFgn
						ELSE CASE WHEN SmTaxDet.Tax4 = 0 THEN AmountFgn 
						ELSE ROUND((AmountFgn + LevelFourTax),2)  END END
				FROM #TaxGroupDetails INNER JOIN tblSmTaxLocDetail TLC ON #TaxGroupDetails.LevelFive = TLC.TaxLocId
																	AND TLC.TaxClassCode = #TaxGroupDetails.TaxClass
					INNER JOIN tblSmTaxGroupDetail SmTaxDet ON SmTaxDet.LevelNo = 5 AND SmTaxDet.TaxGrpID = #TaxGroupDetails.TaxGrpID  AND SmTaxDet.TaxLocID = #TaxGroupDetails.LevelFive
				WHERE #TaxGroupDetails.LevelFive IS NOT NULL				
		INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, 
									NonTaxable, NonTaxableFgn, LiabilityAcct )   
					SELECT c.TransId, tgd.LevelFive, c.TaxClass,5, tgd.LevelFiveTax, tgd.LevelFiveTaxFgn,	
					  Taxable = CASE WHEN tgd.LevelFiveTax IS NULL then 0 WHEN tgd.LevelFiveTax = 0 then 0 ELSE tgd.Amount END,	  
					  TaxableFgn = CASE WHEN tgd.LevelFiveTaxFgn IS NULL then 0 WHEN tgd.LevelFiveTaxFgn = 0 then 0 ELSE tgd.AmountFgn END,		  
					  NonTaxable = CASE WHEN tgd.LevelFiveTax IS NULL then tgd.Amount WHEN tgd.LevelFiveTax = 0 then tgd.Amount  ELSE 0 END,   
					  NonTaxableFgn =CASE WHEN tgd.LevelFiveTaxFgn IS NULL then tgd.AmountFgn WHEN tgd.LevelFiveTaxFgn = 0 then tgd.AmountFgn ELSE 0 END,	       
					  LiabilityAcct = tblSmTaxLoc.GLAcct  
					FROM  #TransClasses c INNER JOIN #TaxGroupDetails tgd ON c.TaxClass = tgd.TaxClass AND c.TaxGrpID = tgd.TaxGrpID
						INNER JOIN tblSmTaxLoc ON tgd.LevelFive = tblSmTaxLoc.TaxLocID
					WHERE  tgd.LevelFive IS NOT NULL					
	
			--SET @TotTaxable = (SELECT MAX(Taxable) FROM tblArTransTax where TransID = @TransID GROUP BY tblArTransTax.TransID)  
			--SET @TotNonTaxable = (SELECT MAX(NonTaxable) FROM tblArTransTax where TransID = @TransID GROUP BY tblArTransTax.TransID )  
			--SET @TotTaxableFgn = (SELECT MAX(TaxableFgn) FROM tblArTransTax where TransID = @TransID GROUP BY tblArTransTax.TransID)  
			--SET @TotNonTaxableFgn = (SELECT MAX(NonTaxableFgn) FROM tblArTransTax where TransID = @TransID GROUP BY tblArTransTax.TransID )  
			
			--summarize all levels, by class. Be sure taxable amount is not overstated. Take minimum?
			SELECT TaxClass, MIN(Taxable) as Taxable, MIN(NonTaxable) as NonTaxable, MIN(TaxableFgn) as TaxableFgn,
				MIN(NonTaxableFgn) as NonTaxableFgn INTO #TaxResults FROM tblArTransTax WHERE tblArTransTax.TransID = @TransId
				GROUP BY tblArTransTax.TaxClass
			SET @TotTaxable = (SELECT SUM(Taxable) FROM #TaxResults) 
			SET @TotNonTaxable = (SELECT SUM(NonTaxable) FROM #TaxResults )  
			SET @TotTaxableFgn = (SELECT SUM(TaxableFgn) FROM #TaxResults )  
			SET @TotNonTaxableFgn = (SELECT SUM(NonTaxableFgn) FROM #TaxResults )  
			execute ALP_qryAlpEI_TransHeaderTaxableAmt_Update_sp @TransId, @TotTaxable,@TotTaxableFgn,@TotNonTaxable,@TotNonTaxableFgn
	--cleanup 
		   drop table #TaxGroupDetails
		   drop table #TransClasses	
		   drop table #TaxResults