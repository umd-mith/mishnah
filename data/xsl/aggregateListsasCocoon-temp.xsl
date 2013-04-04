<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"    xmlns:my="local-functions.uri" exclude-result-prefixes="xs my tei" version="2.0">
    
    <!-- emulates cocoon aggregation for testing results -->
    
    
    <xsl:template match="/">
        <my:div xmlns="local-functions.uri">
            <xsl:copy-of select="document('../tei/wit-index-ref.xml',document(''))"></xsl:copy-of>
        
            <my:wits><xsl:copy-of select="document('../tei/groupedList.xml',document(''))"/></my:wits>
        </my:div>
    </xsl:template>
    <xsl:template match="tei:teiHeader"></xsl:template>
    <xsl:template match="tei:div1">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:ab">
        <xsl:element name="my:mishnah" xmlns="http://www.digitalmishnah.org">
            <xsl:attribute name="n" select="substring-after(@xml:id,concat('ref','.'))"/>
            <xsl:attribute name="order" select="substring-after(ancestor::tei:div1/@xml:id,concat('ref','.'))"/>
            <xsl:attribute name="tractate" select="substring-after(ancestor::tei:div2/@xml:id,concat('ref','.'))"/>
            <xsl:attribute name="chapter" select="substring-after(parent::tei:div3/@xml:id,concat('ref','.'))"/>
            <xsl:attribute name="orderName" select="ancestor::tei:div1/@n"/>
            <xsl:attribute name="tractateName" select="ancestor::tei:div2/@n"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()"></xsl:template>
</xsl:stylesheet>