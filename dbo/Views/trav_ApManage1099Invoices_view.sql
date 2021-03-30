
--PET:http://webfront:801/view.php?id=240600

CREATE VIEW [dbo].[trav_ApManage1099Invoices_view] AS	
	    SELECT [v].[VendorID],	    
	           [v].[Name],
	           [v].[PriorityCode],
	           [v].[VendorHoldYN],
	           [v].[VendorClass],
               [v].[DivisionCode],	           
	           [c].[Counter],
	           [c].[PostRun],
	           [c].[InvoiceNum],	       
	           [c].[PmtType],
	           [c].[GrossAmtDue],
	           [c].[InvoiceDate],
	           [c].[CheckDate],
	           [c].[CheckNum],	       
	           [c].[GLCashAcct],
	           [c].[GlDiscAcct],	       
	           [c].[GrossAmtDueFgn],	           
	           [c].[CurrencyID],
	           [c].[Ten99InvoiceYN],
	           [c].[DistCode],	           
	           [c].[BankId],	
	           [c].[CheckRun],
	           [c].[DiscTaken],
	           [c].[DiscTakenFgn],	       
	           [c].[GlPeriod],
	           [c].[FiscalYear],
	           [c].[PayToName],
	           [c].[PayToAttn],
	           [c].[PayToAddr1],
	           [c].[PayToAddr2],
	           [c].[PayToCity],
	           [c].[PayToRegion],
	           [c].[PayToCountry],
	           [c].[PayToPostalCode],
	           [c].[PmtCurrencyID],
	           [c].[PmtExchRate],
	           [c].[NetPaidCalc],
	           [c].[DeliveryType],
	           [c].[BankAcctNum],
	           [c].[RoutingCode],
	           ([c].[GrossAmtDue] - [c].DiscAmt) AS [PaymentAmount],
	           ([c].[GrossAmtDue] - [c].[DiscTaken] - [c].[NetPaidCalc]) AS [GainLoss],
	           ([c].[GrossAmtDueFgn] - [c].DiscAmtFgn) AS [PaymentAmountFgn],
	           CAST(CASE WHEN ([t].[Ten99Amt] <> 0)
	                       OR ( ([t].[Ten99Amt] IS NULL) 
	                        AND ([c].[Ten99InvoiceYN] = 1) )
	                     THEN 1
	                     ELSE 0 END AS BIT) AS [Current1099Invoice],
	           CASE WHEN ([t].[Ten99Amt] IS NOT NULL)
	                THEN [t].[Ten99Amt]
	                WHEN ([c].[Ten99InvoiceYN] = 1)
	                THEN ([c].[GrossAmtDue] - [c].[DiscAmt])
		            ELSE 0 END AS [Ten99Amt]	
	      FROM [dbo].[tblApVendor] [v] 
	INNER JOIN [dbo].[tblApCheckHist] [c] 
	        ON ([c].[VendorID] = [v].[VendorID])
	 LEFT JOIN [dbo].[tblApPaymentHistDetailTen99] [t]
	        ON ([t].[ID] = [c].[Counter]) 
         WHERE ([v].[Ten99FormCode] <> '0')
           AND ([c].[VoidYn] = 0)
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApManage1099Invoices_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApManage1099Invoices_view';

