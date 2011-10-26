<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its"
xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#default" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="//tei:list">
        <xsl:for-each select="./tei:item">
            <xsl:variable name="mRef">
                <xsl:text>BM_Ch2_</xsl:text><xsl:value-of select="."
                    /><xsl:text>.xml#M.</xsl:text><xsl:value-of select=". "/><xsl:value-of
                    select="tei:item"/>.<xsl:value-of select="parent::node()/@n"/>
            </xsl:variable>
            <xsl:variable name="mExtract"><xsl:copy-of 
                select="document($mRef)"/></xsl:variable>
            <xsl:apply-templates select="$mExtract/tei:ab" mode="strip"/>

        </xsl:for-each>
    </xsl:template>
    
    


   
    <xsl:template match="tei:choice" mode="strip">
        <xsl:copy-of select="node() except ."></xsl:copy-of>
        
    </xsl:template>
      <xsl:template match="tei:lb | tei:milestone | tei:label" mode="strip">

    </xsl:template>
    <xsl:template match="tei:c" mode="strip">
   <xsl:value-of select="."/>
        
    </xsl:template>
</xsl:stylesheet>
