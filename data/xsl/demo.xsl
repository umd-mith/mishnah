<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd"
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="html"></xsl:output>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 29, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:TEI/tei:teiHeader"></xsl:template>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Digital Mishnah Project Demo</title>
            </head>
            <body><h1>Demo Page of the Digital Mishnah Project</h1>
                <xsl:for-each select="tei:TEI/tei:text/tei:body/tei:p"><p><xsl:value-of
                    select="."/></p></xsl:for-each>
                <form name="selection" action="collate-hl" method="get">
                    <input value="Collate" type="submit" ></input><span style="inline-block">&#xa0;&#xa0;Sample output of collation</span>
                </form>    
                <form name="selection" action="browse" method="get">
                    <input value="Browse" type="submit" ></input><span
                        style="inline-block">&#xa0;&#xa0;Browse Individual Transcriptions</span>
                </form>  
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>