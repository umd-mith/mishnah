<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei xi" version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    <xsl:param name="dir" select="'ref'"/>
    <xsl:param name="corpus" select="'t'"/>
    <xsl:param name="inclID" select="'n'"/>
    <xsl:param name="chunk" select="'tract'">
        <!-- values: whole, order, tract, ch  -->
    </xsl:param>
    <xsl:variable name="path">
        <xsl:choose>
            <xsl:when test="$corpus = 't'">
                <xsl:value-of
                    select="concat('../tei/t/', $dir, '?select=', $dir, '*.xml;recurse=yes')"/>
            </xsl:when>
            <xsl:when test="$corpus = 'm'">
                <xsl:value-of
                    select="concat('../tei/', $dir, '?select=', $dir, '*.xml;recurse=yes')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="files" select="collection($path)"/>
    <xsl:template match="/">
        <xsl:choose>
            <!-- Chunk whole -->
            <xsl:when test="$chunk = 'whole'">
                <xsl:call-template name="chunk-whole"/>
            </xsl:when>
            <!-- Chunk by Order -->
            <xsl:when test="$chunk = 'order'">
                <!-- Not yet implemented -->
            </xsl:when>
            <!-- Chunk by Tractate -->
            <xsl:when test="$chunk = 'tract'">
                <xsl:call-template name="chunk-tract"></xsl:call-template>
            </xsl:when>
            <!-- Chunk by Chapter -->
            <xsl:when test="$chunk = 'ch'">
                <!-- Not yet implemented -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="output">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:w">
        <xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="$inclID = 'n'">
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="$inclID = 'y'">
                <xsl:text>,</xsl:text><xsl:value-of select="@xml:id"
                /><xsl:text>&#xD;&#xA;</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:label | tei:head | tei:trailer | tei:link | tei:ref"/>
    <xsl:template match="tei:delSpan">(</xsl:template>
    <xsl:template match="tei:addSpan">[</xsl:template>
    <xsl:template match="tei:damageSpan">&lt;</xsl:template>
    <xsl:template match="tei:anchor">
        <xsl:choose>
            <xsl:when test="@type = 'del'">)</xsl:when>
            <xsl:when test="@type = 'add'">]</xsl:when>
            <xsl:when test="@type = 'gap'">&gt;</xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- whole work in one file -->
    <xsl:template name="chunk-whole">
        <xsl:variable name="txt">
            <xsl:for-each select="$files">
                <xsl:apply-templates select="*"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="pathOut">
            <xsl:choose>
                <xsl:when test="$corpus = 'm'">file:/C:/users/hlapin/desktop/out/<xsl:value-of select="$dir"/>.txt</xsl:when>
                <xsl:when test="$corpus = 't'">file:/C:/users/hlapin/desktop/out/<xsl:value-of select="$dir"/>.txt</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:result-document href="{$pathOut}" method="text" indent="no" encoding="utf-8"
            omit-xml-declaration="yes" byte-order-mark="yes">
            <xsl:value-of select="$txt"/>
        </xsl:result-document>
    </xsl:template>
    <!-- Chunk by seder -->
    <xsl:template name="chunk-ord"></xsl:template>
    <!-- Chunk by tractate -->
    <xsl:template name="chunk-tract">

        <xsl:for-each select="$files">
        <xsl:variable name="fname">
            <xsl:choose>
                <xsl:when test="$corpus = 'm'"><xsl:text>m-</xsl:text></xsl:when>
                <xsl:when test="$corpus = 't'"><xsl:text>t-</xsl:text></xsl:when>
            </xsl:choose>
            <xsl:value-of select="tei:div2/@n"/>
        </xsl:variable>
            <xsl:result-document href="file:/C:/users/hlapin/desktop/out/{$fname}.xml" method="text" indent="no" encoding="utf-8"
                omit-xml-declaration="yes" byte-order-mark="yes">
                <xsl:apply-templates select="*"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <!-- Chunk by chapt -->
    <xsl:template name="chunk-ch"></xsl:template>
</xsl:stylesheet>
