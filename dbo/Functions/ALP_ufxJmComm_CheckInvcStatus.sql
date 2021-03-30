CREATE FUNCTION [dbo].[ALP_ufxJmComm_CheckInvcStatus]
(
	@InvcNum varchar(15)
)
returns varchar(4)
AS
BEGIN
declare @InvcStatus varchar(4)
declare @UniqueInvcNum varchar(15)
SET @InvcStatus = 'PAID'
SET @UniqueInvcNum = 'NotUnique'

SET @UniqueInvcNum =
	(SELECT AROI.InvcNum
	FROM tblArOpenInvoice AROI
	WHERE AROI.InvcNum = @InvcNum
	GROUP BY  
		AROI.InvcNum, 
		AROI.Status  
	HAVING Count(AROI.InvcNum)=1 AND AROI.Status <>4)
IF EXISTS
	(SELECT 
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
		AND AROI.InvcNum = @UniqueInvcNum
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
		AND AROI.InvcNum = @UniqueInvcNum
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
)
BEGIN
	SET @InvcStatus = 'OPEN'
END
RETURN @InvcStatus
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatus] TO [JMCommissions]
    AS [dbo];

