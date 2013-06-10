<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:my="local-functions.uri"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs my tei" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/">
        <!-- group the ams that contain uncertain readings (error in encoding) -->
        <xsl:variable name="group-am">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:copy-of select="$group-am"/>
        
        <!--<xsl:apply-templates select="$group-am/*" mode="pass-2"/>-->
    </xsl:template>

    <xsl:template match="tei:am[@type='abbr']">
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
                                    <xsl:value-of select="current-group()" separator=""/>
                                </unclear>
                            </damage>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="current-group()">
                                
                                <xsl:variable name="qm" as="text()">?</xsl:variable>
                                <xsl:choose>
                                    <!--<xsl:when
                                        test="self::text()[contains(.,$qm) and (replace(.,$qm,'') = $qm)]">
                                        <damage><unclear unit="chars" reason="damage" extent="1"><xsl:value-of select="."></xsl:value-of></unclear></damage>
                                    </xsl:when>-->
                                    <xsl:when
                                        test="self::text()[contains(.,$qm)]">
                                        <xsl:call-template name="otherQmarks"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:variable>
            <!--<xsl:copy-of select="$grouped-1"></xsl:copy-of>-->
            
            <xsl:variable name="grouped-2"><xsl:for-each-group select="$grouped-1/node()" group-adjacent="boolean(self::tei:damage)">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <damage>
                            <xsl:copy-of select="current-group()/*"/>
                        </damage>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group></xsl:variable>
            <xsl:for-each-group select="$grouped-2/node()" group-adjacent="boolean(self::tei:damage)">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <damage>
                            <xsl:copy-of select="current-group()/*"/>
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

</xsl:stylesheet>
