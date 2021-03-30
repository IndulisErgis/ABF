CREATE TYPE [dbo].[pCurrDecimal]
    FROM DECIMAL (28, 3) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pCurrDecimal] TO PUBLIC;

