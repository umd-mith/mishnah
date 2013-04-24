<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:my="local-functions.uri" >
    <xsl:strip-space elements="*"/><xsl:output indent="yes" method="xml"
        omit-xml-declaration="no" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="rqs" select="'&#38;Kauf=1&#38;ParmA=2&#38;Camb=3&#38;S00651=4&#38;S08174=5&#38;P00001=&#38;Vilna=&#38;Mun=&#38;Hamb=&#38;Vat114=&#38;Vat115=&#38;Vat117=&#38;Leid=&#38;S01724=&#38;S01832=&#38;S01835=&#38;S03524=&#38;S04533=&#38;S04589=&#38;S04624=&#38;S06241=&#38;S01715=&#38;S02491=&#38;S00792=&#38;S05134=&#38;S01721=&#38;S01719=&#38;S04944=&#38;S04636='"></xsl:param>
    <xsl:variable name="queryParams" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
        <xsl:variable name="params">
            <xsl:call-template name="tokenize-params">
                <xsl:with-param name="src" select="$rqs"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$params/*[text()]">
            <xsl:sort select="@sortOrder" data-type="number"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:copy-of select="$queryParams"></xsl:copy-of>
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="tei:div">
        <!--<xsl:copy-of select="."></xsl:copy-of>-->
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template name="tokenize-params">
        <!-- revise me -->
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,'&amp;')">
                <!-- build first token element -->
                <xsl:if test="not(contains(substring-before($src,'&amp;'),'mcite'))">
                    <tei:sortWit xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="sortOrder">
                            <xsl:choose>
                                <xsl:when
                                    test="substring-after(substring-before($src,'&amp;'),'=')
                                    =''">
                                    <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="substring-after(substring-before($src,'&amp;'),'=')"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="substring-before(substring-before($src,'&amp;'),'=')"
                        />
                    </tei:sortWit>
                </xsl:if>
                <!-- recurse -->
                <xsl:call-template name="tokenize-params">
                    <xsl:with-param name="src" select="substring-after($src,'&amp;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <tei:sortWit xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="sortOrder">
                        <xsl:choose>
                            <xsl:when
                                test="substring-after($src,'=')
                                =''">
                                <xsl:value-of select="0"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after($src,'=')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before($src,'=')"/>
                </tei:sortWit>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>