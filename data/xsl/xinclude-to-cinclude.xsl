<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:cinclude="http://apache.org/cocoon/include/1.0"
    exclude-result-prefixes="xs cx xd my xsl" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>
    
    <xsl:template match="xi:include">
        <cinclude:include xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://apache.org/cocoon/include/1.0">
            <xsl:attribute name="src" select="concat('cocoon&#58;&#47;',@href)"></xsl:attribute>
        </cinclude:include>
    </xsl:template>

    

</xsl:stylesheet>