<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">

    <xsl:output indent="yes" encoding="UTF-8" media-type="txt/json" omit-xml-declaration="yes"/>
    <xsl:param name="mcite" select="'4.1.2.2'"/>
    <xsl:param name="wits" select="''" as="xs:string"/>

    <xsl:template match="@* | text() | element() | comment()">
        <xsl:copy>
            <xsl:apply-templates select="@* | text() | element() | comment()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:strip-space elements="*"/>
  
    <xsl:variable name="files" select="collection('../tei/w-sep/?select=*.xml')"/>
    <xsl:template match="/">
        <xsl:text>{&#xa;"witnesses": [&#xa;</xsl:text>
        <xsl:for-each select="$files/*[*/*/*/*/*/tei:ab[matches(@xml:id, concat($mcite, '$'))]]">
            
            <xsl:text>{&#xa;"id" : "</xsl:text><xsl:value-of select="//tei:idno[@type='local']"/>
            <xsl:text>",&#xa;"tokens" : [&#xa;</xsl:text>
            <xsl:apply-templates
                select="*/*/*/*/*/tei:ab[matches(@xml:id, concat($mcite, '$'))]/*"/>
            <xsl:text>&#xa;]&#xa;}</xsl:text>
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>&#xa;]&#xa;}</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:lb | tei:cb | tei:pb | tei:note | tei:label | tei:fw| tei:pc|tei:surplus|tei:milestone"/>
    <xsl:template match="tei:damageSpan | tei:anchor[@type = 'damage'] | tei:gap"/>
    <xsl:template match="tei:choice">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:w">
        <xsl:text>&#xa;{ "t" : "</xsl:text><xsl:value-of select="."
        /><xsl:text>", &#xa;"n" : "</xsl:text>normalized here<xsl:text>", &#xa;"id" : "</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>"}</xsl:text>
        <xsl:if test="count(following-sibling::tei:w)!=0">,</xsl:if>
    </xsl:template>

<!-- elements to deal with -->
    <xsl:template match="tei:addSpan|tei:delSpan|tei:span|tei:anchor|tei:choose|tei:expan|tei:abbr|tei:seg"></xsl:template>

</xsl:stylesheet>
