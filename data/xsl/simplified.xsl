<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="categName">
        <xsl:for-each select="/worksheet/sheetData/row[@r='1']/c">
            <xsl:element name="{translate(@r,'0123459789','')}">
                <xsl:call-template name="cellValue">
                    <xsl:with-param name="c" select="."/>
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="sheetData/row">
        <!-- "sibling recursion" to group alternate analyses of the same token -->
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::row)">
                <!-- skip first row, which has only category names --> </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="cells">
                    <xsl:apply-templates/>
                </xsl:variable>
                <expectedOutput><xsl:copy-of select="$cells"/></expectedOutput>
                <xsl:call-template name="spanGroup">
                    <xsl:with-param name="cells" select="$cells"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="c">
        <xsl:variable name="coll" as="xs:string">
            <xsl:variable name="matchColl" select="translate(@r,'0123456789','')"/>
            <xsl:value-of select="$categName/*[name()=$matchColl]"/>
        </xsl:variable>
        <xsl:element name="{$coll}">
            <xsl:call-template name="cellValue">
                <xsl:with-param name="c" select="."/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <xsl:template match="/">
        <markup>
            <xsl:copy-of select="$categName"/>
            <xsl:apply-templates/>
        </markup>
    </xsl:template>
    <xsl:template name="cellValue">
        <xsl:param name="c" select="'null'"/>
        <xsl:choose>
            <!-- borrowed from oxygen sample -->
            <xsl:when test="$c/@t='s'">
                <!-- this is an excel shared string, requires lookup in sharedStrings.xml -->
                <xsl:variable name="string-index" select="number(normalize-space($c/v)) + 1"/>
                <xsl:value-of
                    select="normalize-space(document('../sharedStrings.xml',.)/sst/si[position() =  $string-index]/t)"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- can copy the text in child v element -->
                <xsl:value-of select="normalize-space($c/v)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="spanGroup">
        <xsl:param name="cells"/>
        <output>
            <xsl:copy-of select="*[1]"/>
        </output>
    </xsl:template>
</xsl:stylesheet>
