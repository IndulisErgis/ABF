CREATE PROCEDURE ALP_ArAgeCustomer_proc (@CustId pcustId=null ,@ApplyCreditsToOldest bit)  AS
BEGIN
  
 
 CREATE TABLE #GlobalValues( [Key] varchar(50), [Value] nvarchar(max)
 CONSTRAINT [PK_#GlobalValues] PRIMARY KEY CLUSTERED ([Key]) ON [PRIMARY])
 INSERT INTO  #GlobalValues VALUES ('WrkStnDate',GETDATE())
 INSERT INTO  #GlobalValues VALUES ('ApplyCreditsToOldest',@ApplyCreditsToOldest)
 INSERT INTO  #GlobalValues VALUES ('BFRollBalances',null)
  
   --Customer selection based upon contents of the #CustomerList table  
	CREATE TABLE #CustomerList (CustID pCustId) 
	INSERT INTO #CustomerList VALUES(@CustId)
	
	EXEC dbo.trav_ArAgeCustomer_proc 
	
	DROP TABLE #GlobalValues
	DROP TABLE #CustomerList
END