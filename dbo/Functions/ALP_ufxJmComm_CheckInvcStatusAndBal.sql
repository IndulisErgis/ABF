CREATE FUNCTION [dbo].[ALP_ufxJmComm_CheckInvcStatusAndBal]
(
	@InvcNum varchar(15)
)
RETURNS TABLE 
AS
RETURN
--declare @InvcStatus varchar(4)
--declare @UniqueInvcNum varchar(15)
--declare @InvcBalance decimal(14,2)

--SET @InvcStatus = 'PAID'
--SET @UniqueInvcNum = 'NotUnique'
--SET @InvcBalance = 0

--SET @UniqueInvcNum =
--	(SELECT AROI.InvcNum
--	FROM tblArOpenInvoice AROI
--	WHERE AROI.InvcNum = @InvcNum
--	GROUP BY  
--		AROI.InvcNum, 
--		AROI.Status  
--	HAVING Count(AROI.InvcNum)=1 AND AROI.Status <>4)
--IF EXISTS
	--(
	SELECT 
		Balance=
		Sum(CASE WHEN RecType=1 THEN [Amt] ELSE 0 END)+
		Sum(CASE WHEN RecType<0 THEN [Amt]*-1 ELSE 0 END)
	FROM tblArOpenInvoice AROI 
	WHERE AROI.InvcNum=@InvcNum
	GROUP BY  
		AROI.InvcNum, 
		AROI.Status  
	HAVING 
	(
	AROI.InvcNum Not Like 'on acc%'
	AND 
	Sum(CASE WHEN RecType=1 THEN [Amt] ELSE 0 END)<>0 
	AND 
	(Sum(CASE WHEN RecType=1 THEN [Amt] ELSE 0 END)+
	Sum(CASE WHEN RecType<0 THEN [Amt]*-1 ELSE 0 END)<>0)
	AND 
	AROI.Status<>4
	)
UNION 
SELECT 
		Balance=
		Sum(CASE WHEN (RecType=-1 AND [Amt]>0) THEN [Amt]*-1 ELSE 0 END)+ 
		Sum(CASE WHEN (RecType=-1 AND [Amt]<0) THEN [Amt]*-1 ELSE 0 END)
	FROM tblArOpenInvoice AROI 
	WHERE AROI.InvcNum=@InvcNum
	GROUP BY 
		AROI.InvcNum, 
		AROI.Status
	HAVING 
		(
		AROI.InvcNum Not Like 'on acc%' AND 
		Sum(CASE WHEN (RecType=-1 AND [Amt]<0) THEN Amt*-1 ELSE 0 END) <>0
		) 
		AND 
		(
		(
		Sum(CASE WHEN (RecType=-1 AND [Amt]>0) THEN [Amt]*-1 ELSE 0 END)+
		Sum(CASE WHEN (RecType=-1 AND [Amt]<0) THEN [Amt]*-1 ELSE 0 END)<>0
		)
		AND AROI.Status<>4
		)
UNION 
SELECT 
		Balance=
 		Sum(CASE WHEN (RecType=-1 AND [Amt]>0) THEN [Amt]*-1 ELSE 0 END)+ 
 		Sum(CASE WHEN (RecType=-1 AND [Amt]<0) THEN [Amt]*-1 ELSE 0 END)
	FROM tblArOpenInvoice AROI
	WHERE AROI.InvcNum=@InvcNum
		AND AROI.InvcNum = @InvcNum
	GROUP BY 
		AROI.InvcNum, 
		AROI.Status
	HAVING 
		(AROI.InvcNum Not Like 'on acc%' 
		AND 
		(Sum(CASE WHEN (RecType=-1 AND [Amt]>0) THEN [Amt]*-1 ELSE 0 END)<>0 
		AND AROI.Status<>4))
UNION 
SELECT 
		Balance =
			Sum(CASE WHEN (Rectype=-2 AND [amt]>0) THEN [amt]*-1 ELSE 0 END)+ 
			Sum(CASE WHEN (Rectype=-2 AND [amt]<0) THEN [amt]*-1 ELSE 0 END)
	FROM tblArOpenInvoice AROI 
	WHERE AROI.InvcNum=@InvcNum
	GROUP BY 
		AROI.InvcNum, 
		AROI.Status
	HAVING 
		(
		AROI.InvcNum Like 'on acc%' 
		AND 
		(
 		Sum(CASE WHEN (Rectype=-2 AND [amt]>0) THEN [amt]*-1 ELSE 0 END)+ 
 		Sum(CASE WHEN (Rectype=-2 AND [amt]<0) THEN [amt]*-1 ELSE 0 END)<>0
		) 
		AND AROI.Status<>4
		)
UNION 
SELECT 
		Balance = 
		Sum(CASE WHEN (RecType=-2) THEN [Amt]*-1 ELSE 0 END)
	FROM tblArOpenInvoice AROI
	WHERE AROI.InvcNum=@InvcNum
		AND AROI.InvcNum = @InvcNum
	GROUP BY 
		AROI.InvcNum, 
		AROI.Status
	HAVING 
		(
		AROI.InvcNum Not Like 'on acc%' 
		AND
		Sum(CASE WHEN RecType=-2 THEN [Amt]*-1 ELSE 0 END)<>0 
		AND AROI.Status<>4
		)
--)
--BEGIN
--	SET @InvcStatus = 'OPEN'
--END
--RETURN  SELECT @InvcStatus as InvcStatus, @InvcBalance as InvcBalance
--END
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatusAndBal] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatusAndBal] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatusAndBal] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatusAndBal] TO [JMCommissions]
    AS [dbo];

