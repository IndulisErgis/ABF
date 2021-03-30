
CREATE PROCEDURE dbo.trav_BmWorkOrderPost_Clear_proc 
AS
BEGIN TRY

UPDATE dbo.tblSmTransLink SET DestStatus = 1 
	WHERE DestId IN (SELECT TransId FROM dbo.#PostTransList) 
		AND DestType = 10

	DELETE dbo.tblBmWorkOrderLot
	WHERE TransId IN (SELECT TransId FROM dbo.#PostTransList)

	DELETE dbo.tblBmWorkOrderSer
	WHERE TransId IN (SELECT TransId FROM dbo.#PostTransList)

	DELETE dbo.tblBmWorkOrderDetail
	WHERE TransId IN (SELECT TransId FROM dbo.#PostTransList)

	DELETE dbo.tblBmWorkOrder 
	WHERE TransId IN (SELECT TransId FROM dbo.#PostTransList)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_Clear_proc';

