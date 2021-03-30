CREATE TYPE [dbo].[pTermsCode]
    FROM VARCHAR (6) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pTermsCode] TO PUBLIC;

