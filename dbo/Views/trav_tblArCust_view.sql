CREATE VIEW [dbo].[trav_tblArCust_view]
AS
SELECT t.[AcctType]
, t.[Addr1]
, t.[Addr2]
, t.[AllowCharge]
, t.[Attn]
, t.[AutoCreditHold]
, t.[BalAge1]
, t.[BalAge2]
, t.[BalAge3]
, t.[BalAge4]
, t.[BillToId]
, t.[CalcFinch]
, t.[CcCompYn]
, t.[City]
, t.[ClassId]
, t.[Contact]
, t.[Country]
, t.[CreditHold]
, t.[CreditLimit]
, t.[CreditStatus]
, t.[CurAmtDue]
, t.[CurAmtDueFgn]
, t.[CurrencyId]
, t.[CustId]
, t.[CustLevel]
, t.[CustName]
, t.[DistCode]
, t.[Email]
, t.[Fax]
, t.[FirstSaleDate]
, t.[GroupCode]
, t.[HighBal]
, t.[Internet]
, t.[IntlPrefix]
, t.[LastPayAmt]
, t.[LastPayCheckNum]
, t.[LastPayDate]
, t.[LastSaleAmt]
, t.[LastSaleDate]
, t.[LastSaleInvc]
, t.[NewFinch]
, t.[PartialShip]
, t.[Phone]
, t.[Phone1]
, t.[Phone2]
, t.[PmtMethod]
, t.[PONumberRequiredYn]
, t.[PostalCode]
, t.[PriceCode]
, t.[Region]
, t.[Rep1PctInvc]
, t.[Rep2PctInvc]
, t.[SalesRepId1]
, t.[SalesRepId2]
, t.[ShipZone]
, t.[Status]
, t.[StmtInvcCode]
, t.[Taxable]
, t.[TaxCertExpDate]
, t.[TaxExemptId]
, t.[TaxLocId]
, t.[TermsCode]
, t.[TerrId]
, t.[UnapplCredit]
, t.[UnpaidFinch]
, t.[WebDisplInQtyYn]
, e.[cf_Tax Exempt Cert Expiration]
 FROM dbo.[tblArCust] t
 LEFT JOIN
 ( SELECT pvt.[CustId]
	, Cast(pvt.[Tax Exempt Cert Expiration] As datetime) AS [cf_Tax Exempt Cert Expiration]
	 FROM
		 ( SELECT t.[CustId], [Name], [Value]
		 FROM
			 ( SELECT t.[CustId]
			 , e.props.value('./Name[1]', 'NVARCHAR(max)') as [Name]
			 , e.props.value('./Value[1]', 'NVARCHAR(max)') as [Value]
			 FROM dbo.[tblArCust] t
			 CROSS APPLY t.CF.nodes('/ArrayOfEntityPropertyOfString/EntityPropertyOfString') as e(props)
			 WHERE (e.props.exist('Name') = 1) AND (e.props.exist('Value') = 1)
		 ) t
	 ) tmp
	 PIVOT (Max([Value]) FOR [Name] IN ([Tax Exempt Cert Expiration])) AS pvt
) e on  t.[CustId] = e.[CustId]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblArCust_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblArCust_view';

