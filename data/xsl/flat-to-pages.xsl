<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its tei" version="2.0">
    <xsl:output encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="tei:damageSpan and damagespan and tei:anchor and anchor and
        tei:gap and gap and xs:comment"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 24, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
<xsl:template match="tei:div[@ana='temp']">
    <xsl:apply-templates/>
</xsl:template>
    
    <xsl:template match="tei:body/tei:div/tei:p">
        
        
            
            <xsl:for-each-group select="element()|comment()|processing-instruction()|text()"
                group-starting-with="tei:pb[ancestor::tei:div]">
                
                <xsl:apply-templates select="." mode="group"/>
            </xsl:for-each-group>
        
    </xsl:template>
    
   
    <xsl:template match="tei:pb" mode="group">
        <div type="page">
            
            <xsl:attribute name="n"><xsl:value-of select="@n"></xsl:value-of></xsl:attribute>
        
                <xsl:if test="following-sibling::tei:cb">
                    <xsl:for-each-group select="current-group() except ."
                        group-starting-with="tei:cb">
                        <xsl:apply-templates select="." mode="group-cb"/>
                    </xsl:for-each-group>
                </xsl:if>
                <xsl:if test="not(following-sibling::tei:cb)">
                    <ab><xsl:copy-of select="current-group() except ."></xsl:copy-of></ab>
                </xsl:if>
            
        </div>
        
    </xsl:template>
    <xsl:template match="tei:cb[preceding-sibling::tei:pb]" mode="group-cb">
        <div type="column">
            <xsl:attribute name="n"><xsl:value-of select="@n"></xsl:value-of></xsl:attribute>
            <ab><xsl:copy-of select="current-group() except ."/></ab>
        </div>
    </xsl:template>

    
    <xsl:template match="element()|comment()|processing-instruction()" mode="group">
        <xsl:apply-templates select="current-group()"/>
    </xsl:template>
</xsl:stylesheet>
