<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my="local-functions.uri" 
    version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:output method="html" indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="mcite" select="'4.2.2.3'"/>
    <xsl:param name="unit" select="'m'"/>
    <xsl:param name="tractName" select="'Bava_Metsia'"/>    
    
    <xsl:variable name="ref.cit" select="concat('ref.',$mcite)"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()">        
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="my:chapter">
        <xsl:if test=" $unit = 'ch' and @xml:id=$ref.cit">
            <xsl:for-each select="my:mishnah">
                
            </xsl:for-each>
            
        </xsl:if><xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="my:mishnah">
        <xsl:if test="$unit = 'm' and @xml:id = $ref.cit"> 
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="my:order|my:tract">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="my:struct">
        <struct xmlns="http://www.tei-c.org/ns/1.0">
            <unit>
                <xsl:value-of select="$unit"/>
            </unit>
            <mcite>
                <xsl:value-of select="$mcite"/>
            </mcite>
            <tractName>
                <xsl:value-of select="$tractName"/>
            </tractName>
            
            <xsl:apply-templates select="*"/>
        </struct>
    </xsl:template>
    
    
</xsl:stylesheet>
