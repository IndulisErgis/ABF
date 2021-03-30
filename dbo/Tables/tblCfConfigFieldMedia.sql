CREATE TABLE [dbo].[tblCfConfigFieldMedia] (
    [MediaId]   BIGINT         NOT NULL,
    [FieldId]   BIGINT         NOT NULL,
    [MediaCode] NVARCHAR (10)  NOT NULL,
    [SeqNum]    INT            NOT NULL,
    [Link]      NVARCHAR (MAX) NULL,
    [Notes]     NVARCHAR (MAX) NULL,
    [CF]        XML            NULL,
    [ts]        ROWVERSION     NULL,
    CONSTRAINT [PK_tblCfConfigFieldMedia] PRIMARY KEY CLUSTERED ([MediaId] ASC),
    CONSTRAINT [UX_tblCfConfigFieldMedia_FieldId_MediaCode] UNIQUE NONCLUSTERED ([FieldId] ASC, [MediaCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldMedia';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldMedia';

