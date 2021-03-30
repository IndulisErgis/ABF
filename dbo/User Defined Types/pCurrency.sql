CREATE TYPE [dbo].[pCurrency]
    FROM VARCHAR (6) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pCurrency] TO PUBLIC;

