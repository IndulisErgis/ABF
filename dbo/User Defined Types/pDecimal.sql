﻿CREATE TYPE [dbo].[pDecimal]
    FROM DECIMAL (28, 10) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pDecimal] TO PUBLIC;

