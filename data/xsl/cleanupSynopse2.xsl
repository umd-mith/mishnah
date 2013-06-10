<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:my="local-functions.uri"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs my tei" version="2.0">
    <xsl:preserve-space elements="*"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <!-- group the ams that contain uncertain readins (error in encoding) -->
        <xsl:variable name="group-am">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:copy-of select="$group-am"/>
        <!-- group damage nodes together. -->
        <!--<xsl:apply-templates select="$group-am/*" mode="pass-2"/>-->
    </xsl:template>

    <xsl:template match="tei:am[not(@rend='uncertain')]" mode="pass-2">
        <am>
            <xsl:copy-of select="@* except @type"/>
            <xsl:apply-templates/>
        </am>
    </xsl:template>
    <xsl:template match="tei:ab|tei:surplus">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="grouped-1">
                <xsl:for-each-group select="node()"
                    group-adjacent="boolean(self::tei:am[@rend='uncertain'])">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <damage>
                                <unclear reason="damage">
                                    <xsl:value-of select="current-group()" xml:space="preserve"/>
                                </unclear>
                            </damage>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:for-each-group>
            </xsl:variable>
            <xsl:for-each-group select="$grouped-1/*|text()" group-adjacent="boolean(self::tei:damage)">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <damage>
                            <xsl:copy-of select="current-group()/*" xml:space="preserve"/>
                        </damage>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="otherQmarks">
        <xsl:param name="str"/>
        <xsl:variable name="first" select="substring-before($str, '?')"/>
        <xsl:variable name="rest" select="substring-after($str, '?')"/>
        <xsl:value-of select="$first"/>
        <damage>
            <unclear reason="damage" extent="1"/>
        </damage>
        <xsl:choose><xsl:when test="contains($rest,'?')">
            <xsl:call-template name="otherQmarks"><xsl:with-param name="str" select="$rest"></xsl:with-param></xsl:call-template>
        </xsl:when>
            <xsl:otherwise><xsl:value-of select="$rest"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
