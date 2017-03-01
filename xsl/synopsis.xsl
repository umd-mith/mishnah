<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="tei:w">
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="self::text()">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="self::tei:lb">
                    <xsl:choose>
                        <xsl:when test="@n mod 10 = 0">
                            <span xmlns="http://www.w3.org/1999/xhtml" class="lb10-intra"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <span xmlns="http://www.w3.org/1999/xhtml" class="lb-intra"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="self::tei:pb">
                    <span class="{name(.)}">
                        <xsl:value-of select="@xml:id"/>
                    </span>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:label">
        <span xmlns="http://www.w3.org/1999/xhtml" class="label">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:del">
        <span xmlns="http://www.w3.org/1999/xhtml" class="del">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:add">
        <span xmlns="http://www.w3.org/1999/xhtml" class="add">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:cb">
        <span xmlns="http://www.w3.org/1999/xhtml" class="cb">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:pb">
        <span xmlns="http://www.w3.org/1999/xhtml" class="pb">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:choice">
        <xsl:value-of select="tei:abbr"/>
    </xsl:template>
    <xsl:template match="tei:lb[not(parent::tei:w)]">
        <xsl:choose>
            <xsl:when test="@n mod 10 = 0">
                <span xmlns="http://www.w3.org/1999/xhtml" class="lb10"/>
            </xsl:when>
            <xsl:otherwise>
                <span xmlns="http://www.w3.org/1999/xhtml" class="lb">&#160;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:surplus">
        <span xmlns="http://www.w3.org/1999/xhtml" class="surplus">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:c | //tei:am | //tei:pc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="//tei:damage">
        <span xmlns="http://www.w3.org/1999/xhtml" class="damage">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:unclear">
        <span xmlns="http://www.w3.org/1999/xhtml" class="unclear">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:note"/>
</xsl:stylesheet>