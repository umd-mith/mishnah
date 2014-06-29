<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output indent="yes"/>
    <xsl:param name="diacr" select="'[&#1425;-&#1479;]'"/>
    <xsl:param name="otherIn" select="'שׁשׂשּׁשּׂאַאָאּבּגּדּהּוּזּטּיּךּכּלּמּנּסּףּפּצּקּרּשּתּוֹבֿכֿפֿ'"></xsl:param>
    <xsl:param name="otherOut" select="'ששששאאאבגדהוזטיךכלמנסףפצקרשתובכפ'"></xsl:param>
    
    <xsl:template match="/">
        <xsl:variable name="pass1"><xsl:apply-templates/></xsl:variable>
        <xsl:apply-templates select="$pass1" mode="pass2"/>
    </xsl:template>
    
    <!-- Pass 1 remove vocalization, pointing. -->
    <!-- modifies a stylesheet by Martin Honnen, http://stackoverflow.com/questions/19451097/remove-diacritics-in-whole-xml-document-via-xslt -->
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:attribute name="{name()}" namespace="{namespace-uri()}">
            <xsl:value-of select="replace(normalize-unicode(.,'NFKD'), $diacr, '')"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="replace(normalize-unicode(.,'NFKD'), $diacr, '')"/>
    </xsl:template>
    
    <xsl:template match="comment()">
        <xsl:comment>
    <xsl:value-of select="replace(normalize-unicode(.,'NFKD'), $diacr, '')"/>
  </xsl:comment>
    </xsl:template>
    
    <xsl:template match="processing-instruction()">
        <xsl:processing-instruction name="{name()}">
    <xsl:value-of select="replace(normalize-unicode(.,'NFKD'), $diacr, '')"/>
  </xsl:processing-instruction>
    </xsl:template>
    
<xsl:template match="node()|@*|comment()|processing-instruction()" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*|comment()|processing-instruction()"  mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    
     <xsl:template match="tei:seg" mode="pass2">
        <xsl:choose>
            <xsl:when test="@type='doubleRafe'">
                <xsl:apply-templates  mode="pass2"/>
            </xsl:when>
            <xsl:otherwise>
                <seg xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates  mode="pass2"/>
                </seg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:c"  mode="pass2">
        <xsl:choose>
            <xsl:when test="contains(@rend,'doubleRafe')">
                <xsl:apply-templates  mode="pass2"/>
            </xsl:when>
            <xsl:otherwise>
                <c xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates  mode="pass2"/>
                </c>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:damage[not(node()) or contains(.,'◌')]"  mode="pass2"/>
    <xsl:template match="tei:unclear[not(node()) and not(@extent)]"  mode="pass2"/>
    
    
</xsl:stylesheet>