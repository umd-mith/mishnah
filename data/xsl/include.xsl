<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri" xmlns:cinclude="http://apache.org/cocoon/include/1.0"
    exclude-result-prefixes="xs cx xd my xsl" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <div><xsl:apply-templates/></div>
    </xsl:template>
    
    <xsl:template match="tei:idno[@type = 'local']">
        <xsl:variable name="id" select="./text()" as="text()"/>
        <test><xsl:copy-of select="$id"></xsl:copy-of></test>
        <div><cinclude:include
            src="cocoon:/{$id}.flat.xml" element="test"/></div>
        <div><cinclude:include
            src="cocoon:/{$id}.pages.xml" element="test"/></div>
    </xsl:template>
    
    <xsl:template match="element()|comment()|text()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text"></xsl:template>
    <xsl:template match="tei:TEI">
        <xsl:apply-templates select="//tei:idno[@type='local']"/>
    </xsl:template>
</xsl:stylesheet>
