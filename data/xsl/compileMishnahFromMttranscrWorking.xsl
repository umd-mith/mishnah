<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:my="local-functions.uri"
   xmlns:tei="www.tei-c.org/ns/1.0"
   xmlns="www.tei-c.org/ns/1.0"
   exclude-result-prefixes="xs my tei"
   version="2.0">
   <xsl:template match="my:struct">
      <TEI>
         <teiHeader>
            
         </teiHeader>
         <text>
            <body></body>
         </text>
      </TEI>
   </xsl:template>
</xsl:stylesheet>