
CREATE Procedure [dbo].[ALP_CopyTrav11TransList_sp]  AS
 Begin
	
	IF  NOT EXISTS (SELECT * FROM sys.tables
	WHERE name = 'ALP_tmpTransactionList' AND type = 'U')
	CREATE TABLE ALP_tmpTransactionList( TransId pTransId NOT NULL PRIMARY KEY CLUSTERED ([TransId]))

Delete from ALP_tmpTransactionList
INSERT INTO ALP_tmpTransactionList (TransId )
SELECT * from #tmpTransactionList

select * from Alp_tmptransactionList 
 End