<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="//tei:list">
        <witnesses>
            <xsl:for-each select="./tei:item">
                <id>
                    <xsl:value-of select="."/>
                </id>
                <xsl:variable name="mRef">
                    <xsl:text>BM_Ch2_</xsl:text><xsl:value-of select="."
                        /><xsl:text>.xml#M.</xsl:text><xsl:value-of select=". "/><xsl:value-of
                        select="tei:item"/>.<xsl:value-of select="parent::node()/@n"/>
                </xsl:variable>
                <xsl:variable name="mExtract">
                    <xsl:copy-of select="document($mRef)/node()|@*"/>
                </xsl:variable>
                <xsl:variable name="mTokenized">
                    <tokens><xsl:apply-templates select="$mExtract" mode="strip"/></tokens>
                </xsl:variable>
                <xsl:apply-templates select="$mTokenized" mode="tokenize"></xsl:apply-templates>
            </xsl:for-each>
            
        </witnesses>
    </xsl:template>
    <!-- Remove signposts, structural text, and extraneous text -->
    <xsl:template match="//tei:surplus" mode="strip"/>
    <xsl:template match="//tei:lb" mode="strip"/>
    <xsl:template match="//tei:milestone" mode="strip"/>
    <xsl:template match="//tei:label" mode="strip"/>
    <xsl:template match="//tei:pc" mode="strip"/>
    <!-- Choose to remove additions by second hand, etc. 
        Temp Solution. Will need refining to add <choice to
    encoding of <add><del> etc., to allow for processing of internal corrections -->
    <xsl:template match="//tei:add" mode="strip"/>
    <!-- Tokenize text-->
    <!-- Special tokenization for abbreviations -->
    <xsl:template match="tei:choice" mode="strip">
        <xsl:choose>
            <xsl:when test="./tei:abbr/not(descendant::text())">
                <xsl:copy-of select="node() except ."/>
            </xsl:when>
            <xsl:when test="./tei:abbr/child::node()">
                <token>
                    <xsl:attribute name="t">
                        <xsl:value-of select="./tei:abbr/descendant::text()"/>
                    </xsl:attribute>
                    <xsl:attribute name="n">
                        <xsl:value-of select="./tei:expan"/>
                    </xsl:attribute>
                </token>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:tokens" mode="tokenize">
        <tokens><xsl:apply-templates mode="tokenize"></xsl:apply-templates></tokens>
    </xsl:template>
    <xsl:template match="*/text()" mode="tokenize">
        <xsl:choose>
            <xsl:when test=".[parent::tei:tokens]">
                <xsl:for-each select="tokenize(., '[\s]')[.]">
                    <token>
                        <xsl:attribute name="t">
                            <xsl:sequence select="."/>
                        </xsl:attribute>
                    </token>
                </xsl:for-each>
            </xsl:when>
            
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:token" mode="tokenize">
        <xsl:copy-of select="."></xsl:copy-of>
    </xsl:template>
</xsl:stylesheet>
