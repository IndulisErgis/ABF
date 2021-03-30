CREATE TABLE [dbo].[tblSmSynchSnapshot] (
    [ID]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [FunctionId]     UNIQUEIDENTIFIER NOT NULL,
    [FullEntityName] NVARCHAR (255)   NOT NULL,
    [DataKey]        NVARCHAR (255)   NOT NULL,
    [DataTs]         BINARY (8)       NOT NULL,
    [ServiceKey]     NVARCHAR (255)   NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblSmSynchSnapshot] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmSynchSnapshot_FunctionId]
    ON [dbo].[tblSmSynchSnapshot]([FunctionId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmSynchSnapshot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmSynchSnapshot';

