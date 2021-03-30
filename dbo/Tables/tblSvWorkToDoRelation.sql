CREATE TABLE [dbo].[tblSvWorkToDoRelation] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [WorkToDoID] NVARCHAR (10) NOT NULL,
    [RelationID] NVARCHAR (10) NOT NULL,
    [CF]         XML           NULL,
    [ts]         ROWVERSION    NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkToDoRelation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkToDoRelation';

