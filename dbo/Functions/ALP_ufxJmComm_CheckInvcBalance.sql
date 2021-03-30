

CREATE FUNCTION [dbo].[ALP_ufxJmComm_CheckInvcBalance]
(
	@InvcNum varchar(15)
)
returns PDEC
AS
BEGIN
declare @InvcBalance pDec
declare @UniqueInvcNum varchar(15)
SET @InvcBalance = 0
SET @UniqueInvcNum = 'NotUnique'

SET @UniqueInvcNum =
	(SELECT AROI.InvcNum
	FROM tblArOpenInvoice AROI
	WHERE AROI.InvcNum = @InvcNum
	GROUP BY  
		AROI.InvcNum, 
		AROI.Status  
	HAVING Count(AROI.InvcNum)=1 AND AROI.Status <>4)
SET @InvcBalance = 
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
	))
If @InvcBalance = 0 OR @InvcBalance IS NULL 
Begin 
SET @InvcBalance = 
	(SELECT 
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
	)

	If @InvcBalance = 0  OR @InvcBalance IS NULL
	Begin 
	SET @InvcBalance = 
		(SELECT 
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
		Sum(CASE WHEN (RecType=-1 AND [Amt]>0) THEN [Amt]*-1 ELSE 0 END)<>0 
		AND AROI.Status<>4)
		)
	
	If @InvcBalance = 0  OR @InvcBalance IS NULL
		Begin 
		SET @InvcBalance = 
			(SELECT 
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
			)
		If @InvcBalance = 0  OR @InvcBalance IS NULL
			Begin 
			SET @InvcBalance = 
				(SELECT 
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
			IF @InvcBalance IS NULL
				BEGIN
				SET @InvcBalance = 0
				END
			END
			ELSE
			BEGIN SET @InvcBalance = 0
			END
		END
	END
END

--BEGIN
--	SET @InvcBalance = 0
--END
RETURN @InvcBalance
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcBalance] TO [JMCommissions]
    AS [dbo];

