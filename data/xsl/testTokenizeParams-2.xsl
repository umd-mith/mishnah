<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri" >
    <xsl:strip-space elements="*"/><xsl:output indent="yes" method="xml"
        omit-xml-declaration="no" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:p">
        <xsl:variable name="sortList"><xsl:call-template name="tokenize-params">
            
            <xsl:with-param name="src" select="text()"></xsl:with-param>
        </xsl:call-template></xsl:variable>
        <xsl:for-each select="$sortList/tei:sortItem[@sortOrder != '0']">
            <xsl:sort select="@sortOrder"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    
</xsl:template>
    <xsl:template name="tokenize-params">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,'&amp;')">
                <!-- build first token element -->
                <xsl:if test="not(contains(substring-before($src,'&amp;'),'mcite'))"><sortItem>
                    <xsl:attribute name="sortOrder">
                        <xsl:choose>
                            <xsl:when test="substring-after(substring-before($src,'&amp;'),'=')
                                =''"><xsl:value-of select="0"></xsl:value-of></xsl:when>
                            <xsl:otherwise><xsl:value-of select="substring-after(substring-before($src,'&amp;'),'=')"></xsl:value-of></xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute><xsl:value-of
                        select="substring-before(substring-before($src,'&amp;'),'=')"/></sortItem></xsl:if>
                <!-- recurse -->
                <xsl:call-template name="tokenize-params">
                    
                    <xsl:with-param name="src" select="substring-after($src,'&amp;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <sortItem><xsl:attribute name="sortOrder">
                    <xsl:choose>
                        <xsl:when test="substring-after($src,'=')
                            =''"><xsl:value-of select="0"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="substring-after($src,'=')"></xsl:value-of></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute><xsl:value-of
                        select="substring-before($src,'=')"/></sortItem>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>

