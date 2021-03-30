CREATE TABLE [dbo].[tblCfConfigFieldValueMedia] (
    [MediaId]   BIGINT         NOT NULL,
    [ValueId]   BIGINT         NOT NULL,
    [MediaCode] NVARCHAR (10)  NOT NULL,
    [SeqNum]    INT            NOT NULL,
    [Link]      NVARCHAR (MAX) NULL,
    [Notes]     NVARCHAR (MAX) NULL,
    [CF]        XML            NULL,
    [ts]        ROWVERSION     NULL,
    CONSTRAINT [PK_tblCfConfigFieldValueMedia] PRIMARY KEY CLUSTERED ([MediaId] ASC),
    CONSTRAINT [UX_tblCfConfigFieldValueMedia_ValueId_MediaCode] UNIQUE NONCLUSTERED ([ValueId] ASC, [MediaCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldValueMedia';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldValueMedia';

