<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri" >
    <xsl:strip-space elements="tei:w"/>
    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:param name="rqs"/>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:variable name="cite" select="if (string-length($mcite) = 0) then '4.2.2.1' else $mcite"/>
    <xsl:variable name="queryParams" select="tokenize($rqs, '&amp;')"/>
    <xsl:variable name="sel" select="for $p in $queryParams[starts-with(., 'wit=')] return substring-after($p, 'wit=')"/> 
    <xsl:template match="/tei:TEI">
        <!-- Copy witness list into temporary node for reference -->
        <xsl:variable name="witlist">
            <xsl:copy-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit"/> 
        </xsl:variable>
        <xsl:variable name="refList" select="for $ab in tei:text/tei:body/tei:div1/tei:div2/tei:div3/tei:ab return substring-after($ab/@xml:id, 'ref.')"/>
        <cx:collation xmlns:cx="http://interedition.eu/collatex/ns/1.0">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit//tei:witness[@corresp and (count($sel) = 0 or count(index-of($sel, @xml:id)) != 0)]">
                <xsl:variable name="Wit">
                    <xsl:value-of select="@xml:id"/>
                </xsl:variable>
                <cx:witness>
                    <xsl:attribute name="sigil">
                        <xsl:value-of select="$Wit"/>
                    </xsl:attribute>
                    <!-- Build URI from ref.xml, assemble in buildURI -->
                    <xsl:variable name="buildURI">
                        <xsl:text>../tei/</xsl:text><xsl:value-of select="@corresp"/>
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="$Wit"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="$cite"/>
                    </xsl:variable>
                    
                    <!-- Extract text -->
                    <xsl:variable name="mExtract">
                        <xsl:copy-of select="document($buildURI)/node()"/> <!--|@*"/>-->
                    </xsl:variable>
                    <xsl:variable name="mTokenized">
                        <tokens><xsl:apply-templates select="$mExtract" mode="strip"/></tokens>
                    </xsl:variable>
                    <xsl:apply-templates select="$mTokenized" mode="tokenize"/>
                </cx:witness>
            </xsl:for-each>
        </cx:collation>
    </xsl:template>
    <!-- Remove signposts, structural text, and extraneous text -->
    <xsl:template match="//tei:surplus" mode="strip"/>
    <xsl:template match="//tei:ref" mode="strip"/>
    <xsl:template match="//tei:lb[not(parent::tei:w)]" mode="strip">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="//tei:lb[parent::tei:w]" mode="strip"/>
    <xsl:template match="//tei:milestone" mode="strip"/>
    <xsl:template match="//tei:c[@rend='lig']" mode="strip">
        <xsl:apply-templates mode="strip"/>
    </xsl:template>
    <xsl:template match="//tei:g" mode="strip"><xsl:apply-templates mode="strip"></xsl:apply-templates></xsl:template>
    <xsl:template match="//tei:label" mode="strip"/>
    <xsl:template match="//tei:pc" mode="strip"/>
    <xsl:template match="//tei:note" mode="strip"/>
    <xsl:template match="//tei:corr" mode="strip"/>
    <!-- Decide to deal only with original writing of scribe, omitting all scribal corrections by
        same or later hand. -->
    <xsl:template match="//tei:del" mode="strip">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="//tei:add" mode="strip"/>
    <xsl:template match="//tei:supplied" mode="strip">
        <xsl:text>[ ]</xsl:text>
    </xsl:template>
    <!-- If choose to tokenize with abbreviated fix in files and replace the next line with:
        <xsl:template match="//tei:choice/tei:expan" mode="strip"/> -->
    <xsl:template match="//tei:expan" mode="strip"/>
<!--    <!-\- If choose to tokenize with expanded forms not abbrev 
      fix in files then replace next line with 
      //tei:choice/tei:abbr" mode="strip"/>-\->
    <xsl:template match="//tei:abbr" mode="strip"/>
        <xsl:template match="*/text()" mode="tokenize">
        <xsl:choose>
            <xsl:when test=".[parent::tei:tokens]">
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="src" select="normalize-space(.)"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>-->
     <!-- recursively splits string into <token> elements -->
    <!-- Adapts a template from: http://www.usingxml.com/Transforms/XslTechniques -->
    <xsl:template name="tokenize">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <xsl:value-of select="translate(substring-before($src,' '),'?','*')"/><xsl:text> </xsl:text>
                <!-- recurse -->
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="src" select="translate(substring-after($src,' '),'?','*')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <xsl:value-of select="translate($src,'?','*')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
