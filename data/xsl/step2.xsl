<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="*:div">
        <xsl:variable name="ord" select="concat('ref.',*:seg[1]/@x-s)"/>
        <div1 corresp="{concat('r:',$ord)}">
            <xsl:for-each-group select="*:seg" group-adjacent="@x-w">
                <xsl:variable name="wd" select=" current-grouping-key()"/>
                <key><xsl:value-of select="current-grouping-key()"></xsl:value-of></key>
                <w corresp="{concat('r:',$wd)}">
                    <xsl:attribute name="lemma" select="current-group()[1]/*:span/text()"/>
                    <choice>
                        <xsl:copy-of select="current-group()[1]"/>
                    </choice>
                </w>
            </xsl:for-each-group>
         </div1>
    </xsl:template>
</xsl:stylesheet>
