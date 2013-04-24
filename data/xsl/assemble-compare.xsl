<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="html" encoding="UTF-8"/>

    <!-- Assembles the parts of the "compare" module of the demo -->

    <xsl:template match="/" xmlns="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tempDiv">
        <div class="about">
            <xsl:copy-of select="*[local-name()= 'div'][@class = 'about']"/>
        </div>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'dropdown']"/>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'selectionList']"/>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'output-container']"/>
    </xsl:template>
</xsl:stylesheet>
