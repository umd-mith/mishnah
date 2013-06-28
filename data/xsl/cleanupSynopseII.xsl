<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:my="local-functions.uri"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs my tei" version="2.0">
    <xsl:variable name="qm" as="xs:string">?</xsl:variable>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        
    </xsl:template>
    
        

        
        
    

    <!-- Templates to fix encoding errors -->
    <xsl:template match="tei:am">
        <xsl:choose>
            <xsl:when test="@type='abbr'">
                <am>
                    <xsl:copy-of select="@* except @type"/>
                    <xsl:apply-templates/>
                </am>
            </xsl:when>
            <xsl:when test="@rend='uncertain'">
                <damage>
                    <unclear>
                        <xsl:copy-of select="@* except @rend"/>
                        <xsl:apply-templates/>
                    </unclear>
                </damage>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:text//text()[contains(.,$qm)]">
        <xsl:call-template name="otherQmarks">
            <xsl:with-param name="str" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Convert the qms to damage/unclear elements -->
    <xsl:template name="otherQmarks">
        <xsl:param name="str"/>
        <xsl:variable name="first" select="substring-before($str, '?')"/>
        <xsl:variable name="rest" select="substring-after($str, '?')"/>
        <xsl:value-of select="$first"/>
        <damage>
            <unclear reason="damage" extent="1" unit="chars"/>
        </damage>
        <xsl:choose>
            <xsl:when test="contains($rest,'?')">
                <xsl:call-template name="otherQmarks">
                    <xsl:with-param name="str" select="$rest"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rest"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<xsl:template match="tei:ab">
<xsl:element name="{name()}"><xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
    <xsl:variable name="regularized">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:variable>
    <!-- Group once on damage nodes -->
    <xsl:for-each-group select="$regularized/node()" group-adjacent=" boolean(self::tei:damage)">
        
        <xsl:choose>
            <xsl:when test="current-grouping-key()">
                <damage>
                    <xsl:variable name="groupedOnDam" select="current-group()/*"/>
                <xsl:for-each-group select="$groupedOnDam" group-adjacent="boolean(self::tei:unclear[@extent='1'])">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:variable name="numUncl" select="count(current-group())"/>
                            <unclear reason="damage" unit="chars">
                                <xsl:attribute name="extent"><xsl:choose>
                                    <xsl:when test="$numUncl > 2"><xsl:value-of select="$numUncl"></xsl:value-of></xsl:when>
                                    <xsl:otherwise><xsl:text>tbd</xsl:text></xsl:otherwise>
                                </xsl:choose></xsl:attribute>
                            </unclear>
                        </xsl:when>
                        <xsl:otherwise><xsl:copy-of select="current-group()"></xsl:copy-of></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
                </damage>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="current-group()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:for-each-group>
    </xsl:element>
</xsl:template>
</xsl:stylesheet>
