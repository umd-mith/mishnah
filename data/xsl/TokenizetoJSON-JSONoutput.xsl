<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output indent="yes" omit-xml-declaration="yes" method="text" encoding="UTF-8"
        media-type="text/x-json"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="//tei:list">
        <!-- Copy witness list into temporary node for reference -->
        <xsl:variable name="mcite">
            <xsl:value-of select="./@n"/>
        </xsl:variable>
        <xsl:variable name="witlist">
            <xsl:copy-of
                select="document('../tei/mishnahhierarchy.xml',
                document(''))//tei:listWit except ."
            />
        </xsl:variable> { "witnesses" : [ <xsl:for-each select="./tei:item">
            <xsl:variable name="Wit"><xsl:copy-of select="."/></xsl:variable>
             {"id" : "<xsl:value-of select="$Wit"/><xsl:text>", </xsl:text>
            <!-- Build URI from hierarchy, assemble in buildURI -->
            <xsl:variable name="buildURI">
                <!-- This condition is temporary. M. and G. etc. indicators on xml:ids are going
                    to be removed-->
                <xsl:choose>
                    <xsl:when test="substring($Wit,1,1)!='G'">
                        <xsl:value-of
                            select="$witlist//tei:witness[@xml:id=$Wit]/tei:ptr/@target"/>
                        <xsl:text>#M.</xsl:text>
                        <xsl:value-of select="$Wit"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="$mcite"/>
                    </xsl:when>
                    <xsl:when test="substring($Wit,1,1)='G'">
                        <xsl:value-of
                            select="$witlist//tei:witness[@xml:id=$Wit]/tei:ptr/@target"/>
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="$Wit"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="$mcite"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            
           <!-- construct the actual URI to mRef -->
            <xsl:variable name="mRef">
                <xsl:value-of select="resolve-uri($buildURI,document-uri(/))"/>
            </xsl:variable>
            
            <!-- Extract text -->
            
            <xsl:variable name="mExtract">
                <xsl:copy-of select="document($mRef)/node()|@*"/>
            </xsl:variable>
            <xsl:variable name="mTokenized">
                <tokens><xsl:apply-templates select="$mExtract" mode="strip"/></tokens>}<xsl:choose>
                    <xsl:when test="position()!=last()">,</xsl:when>
                    <xsl:when test="position()=last()">]</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:apply-templates select="$mTokenized" mode="tokenize"/>
        </xsl:for-each> } </xsl:template>
    <!-- Remove signposts, structural text, and extraneous text -->
    <xsl:template match="//tei:surplus" mode="strip"/>
    <xsl:template match="//tei:lb" mode="strip"/>
    <xsl:template match="//tei:milestone" mode="strip"/>
    <xsl:template match="//tei:label" mode="strip"/>
    <xsl:template match="//tei:pc" mode="strip"/>
    <xsl:template match="//tei:note" mode="strip"/>
    <xsl:template match="//tei:supplied" mode="strip"/>
    <!-- Choose to remove additions by second hand, etc. 
        Temp Solution. Will need refining to add <choice to
    encoding of <add><del> etc., to allow for processing of internal corrections -->
    <xsl:template match="//tei:add" mode="strip"/>
    <!-- Tokenize text-->
    <!-- Special tokenization for abbreviations -->
    <xsl:template match="tei:choice" mode="strip">
        <xsl:choose>
            <xsl:when test="./tei:abbr/not(descendant::text())">
                <xsl:copy-of select="node() except ."/>
            </xsl:when>
            <xsl:when test="./tei:abbr">
                <token>
                    <xsl:attribute name="t">
                        <xsl:value-of select="./tei:abbr/descendant::text()"/>
                    </xsl:attribute>
                    <xsl:attribute name="expan">
                        <xsl:value-of select="./tei:expan/descendant::text()"/>
                    </xsl:attribute>
                </token>
                            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:tokens" mode="tokenize"> "tokens" : [<xsl:apply-templates
            mode="tokenize"/>] </xsl:template>
    <xsl:template match="*/text()" mode="tokenize">
        <xsl:choose>
            <xsl:when test=".[parent::tei:tokens]">
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="src" select="normalize-space(.)"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:token" mode="tokenize">
        <xsl:text>,  { "t" : "</xsl:text>
        <xsl:value-of select="@t"/>
        <xsl:text>", "expan" : "</xsl:text>
        <xsl:value-of select="@expan"/>
        <xsl:text>" }, </xsl:text>
    </xsl:template>
    <!-- recursively splits string into <token> elements -->
    <!-- Adapts a template from: http://www.usingxml.com/Transforms/XslTechniques, with output
        formatted to reflect JSON -->
    <xsl:template name="tokenize">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <xsl:text>{ "t" : "</xsl:text>
                <xsl:value-of select="substring-before($src,' ')"/>
                <xsl:text>" }, </xsl:text>
                <!-- recurse -->
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="src" select="substring-after($src,' ')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <xsl:text>{ "t" : "</xsl:text>
                <xsl:value-of select="$src"/>
                <xsl:text>" } </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
