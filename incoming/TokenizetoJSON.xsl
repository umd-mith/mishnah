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
                    <xsl:value-of select="."/></id>
                    
                        <xsl:variable name="mRef">
                            <xsl:text>BM_Ch2_</xsl:text><xsl:value-of select="."
                                /><xsl:text>.xml#M.</xsl:text><xsl:value-of select=". "
                                /><xsl:value-of select="tei:item"/>.<xsl:value-of
                                select="parent::node()/@n"/>
                        </xsl:variable>
                        <xsl:variable name="mExtract">
                            <xsl:copy-of select="document($mRef)"/>
                        </xsl:variable>
                        <xsl:variable name="mTokenized"><tokens><xsl:apply-templates
                            select="$mExtract" mode="strip"/></tokens></xsl:variable>
                    
                <xsl:apply-templates select="$mTokenized" mode="tokenize"></xsl:apply-templates>
                    
               
            </xsl:for-each>
        </witnesses>
    </xsl:template>
    <!-- Convert the <abbr> and <expan> tags to <t> and <n>-->
    <xsl:template match="//tei:choice" mode="strip">
        <xsl:choose>
            <xsl:when test="./tei:abbr/not(descendant::text())">
                <xsl:copy-of select="node() except ."/>
            </xsl:when>
            <xsl:when test="./tei:abbr/child::node()">
                <t><xsl:value-of select="./tei:abbr/descendant::text()"/></t>
                <n><xsl:value-of select="./tei:expan"/></n>
            </xsl:when>
        </xsl:choose>
        <!-- Remove signposts, structural text, and extraneous text -->
    </xsl:template>
    <xsl:template match="tei:lb | tei:milestone | tei:label | tei:surplus" mode="strip"> </xsl:template>
    
    <!-- Choose to remove additions by second hand, etc. Will need refining to include variation
      within mss, to be added to the tokenized string -->
    <xsl:template match="tei:add" mode="strip"> </xsl:template>
    

   <!-- Tokenize text-->

    <xsl:template match="tei:tokens" mode="tokenize">
        <tokens><xsl:apply-templates mode="tokenize"/></tokens>
    </xsl:template><xsl:template match="*/text()" mode="tokenize">
       
<xsl:choose><xsl:when test=".[parent::tei:tokens]"><xsl:for-each select="tokenize(., '[\s]')[.]">
            <t><xsl:sequence select="."/></t>
</xsl:for-each>
</xsl:when>
<xsl:when test=".[parent::tei:t]">
    <t><xsl:value-of select="."></xsl:value-of></t>
</xsl:when>
<xsl:when test=".[parent::tei:n]">
    <n><xsl:value-of select="."></xsl:value-of></n>
</xsl:when></xsl:choose>
        
        
        

    </xsl:template>
    
</xsl:stylesheet>
