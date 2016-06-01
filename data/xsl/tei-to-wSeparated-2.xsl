<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:strip-space elements="*"/>
    <!--<xsl:strip-space elements="tei:damage tei:unclear tei:gap"/>-->

    <xsl:output indent="yes"/>
    <xsl:param name="iterate" select="'no'"/>
    <xsl:param name="csv">no</xsl:param>
    <xsl:param name="path" select="'../tei'"/>

    <xsl:variable name="files"
        select="collection(iri-to-uri(concat($path, '?select=[PS][0-9]{5}.xml;recurse=no')))"/>

    <xsl:template match="@* | text() | element() | comment()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$iterate = 'no'">
                <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" </xsl:text>
                <xsl:text>schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
            </xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                 <xsl:text>schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
            </xsl:processing-instruction>
                <xsl:call-template name="doText"/>
            </xsl:when>
            <xsl:when test="$iterate = 'yes'">
                <xsl:for-each select="$files/*">
                    <xsl:result-document
                        href="{concat('../tei/w-sep/',/*/*/*/*/tei:idno[@type='local'],'-w-sep.xml')}"
                        method="xml" indent="yes" encoding="utf-8">
                        <TEI>
                            <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                <xsl:text>schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
            </xsl:processing-instruction>
                            <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                 <xsl:text>schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
            </xsl:processing-instruction>
                            <xsl:call-template name="doText"/>
                        </TEI>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="doText">
        <!-- pass 1 do the segmenation -->
        <!--<xsl:variable name="segmented">-->
            <xsl:apply-templates/>
        <!--</xsl:variable>-->
        <!--<xsl:copy-of select="$segmented"/>-->
        <!--<xsl:apply-templates mode="cleanup" select="$segmented"/>-->
    </xsl:template>


    <xsl:template match="tei:damage | tei:unclear | tei:gap[@reason = 'damage']">
        <!-- NB on revision, gap should just be passed through -->
        <damageSpan type="{name()}" spanTo="#{generate-id()}">
            <xsl:if test="@reason">
                <xsl:attribute name="subtype" select="@reason"/>
            </xsl:if>
            <xsl:copy-of select="@* except @reason"/>
        </damageSpan>
        <xsl:apply-templates/>
        <anchor xml:id="{generate-id()}" type="{name()}"/>
    </xsl:template>
    <xsl:template match="tei:add | tei:del">
        <xsl:element name="{concat(name(),'Span')}">
            <xsl:attribute name="spanTo" select="concat('#', generate-id())"/>
            <xsl:copy-of select="@*"/>
        </xsl:element>
        <xsl:apply-templates/>
        <xsl:element name="anchor">
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:attribute name="type" select="name()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:seg">
        <span>
            <xsl:attribute name="to" select="concat('#', generate-id())"/>
            <xsl:attribute name="type" select="'seg'"></xsl:attribute>
            <xsl:copy-of select="@*"/>
        </span>
        <xsl:apply-templates/>
        <xsl:element name="anchor">
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:attribute name="type" select="name()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:note" mode="add-sep">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- Elements to remove as no longer supported in main transcription -->
    <xsl:template match="tei:supplied | tei:damageSpan | tei:anchor"/>
    <!-- elements to preserve contents but are no longer supported in main transcription-->
    <xsl:template match="tei:num | tei:persName[ancestor::tei:body]">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- some error cleanup -->
    <xsl:template match="tei:expan/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
 
    

    <!-- grouping words on separators -->
    <!-- also uses http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/201009/msg00089.html -->
    <xsl:template match="tei:ab | tei:head | tei:trailer">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="sep" as="node()*">
                <xsl:apply-templates mode="add-sep"/>
            </xsl:variable>
            <xsl:for-each-group select="current-group()"
                group-adjacent="not(self::tei:milestone[@unit = 'sep'])">
                <xsl:if test="current-grouping-key()">

                    <xsl:choose>
                        <xsl:when test="current-group()/self::tei:surplus or current-group()/self::tei:label or current-group()/self::tei:w">
                            <xsl:apply-templates select="current-group()"></xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise><w><xsl:apply-templates select="current-group()"/></w></xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:copy>

    </xsl:template>
    <!-- process nodes to separate with temporary milestone element -->
    <!-- See http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/201009/msg00089.html -->
    <xsl:template
        match="text()[not(ancestor::tei:c) and not(ancestor::tei:label) and not(ancestor::tei:expan) and not(preceding-sibling::node()[1][@break='no'])]"
        mode="add-sep">
        <xsl:analyze-string select="." regex="\s+">
            <xsl:matching-substring>
                <milestone unit="sep"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!-- elements that effect word segmentation [in part getting around encoding errors that need to be fixed -->
    <xsl:template match="tei:milestone[@unit = 'MSMishnah']" mode="add-sep">
        <milestone unit="sep"/>        
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="tei:lb | tei:cb | tei:pb" mode="add-sep">
        <xsl:copy-of select="."/>
        <xsl:if test="not(@break = 'no')">
            <milestone unit="sep"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:choice[tei:abbr]" mode="add-sep">
        <milestone unit="sep"/>
        <choice>
            <xsl:apply-templates/>
        </choice>
    </xsl:template>

    <!-- clean up operations -->
    <xsl:template match="tei:w" mode="cleanup">
        <xsl:choose>
            <xsl:when test="tei:w">
                <xsl:sequence select="*"></xsl:sequence>
            </xsl:when>
            <xsl:when test="not(string(.))">
                <xsl:apply-templates mode="cleanup"/>
            </xsl:when>
            <xsl:when test="//*[normalize-space()]">
                <xsl:copy-of
                    select="*[self::tei:lb[not(@break='no')] | self::tei:cb | self::tei:pb | tei:milestone][preceding-sibling::node()[not(string(.)) or not(preceding-sibling::node())]]"/>
                <w>
                    <xsl:copy-of select="@* except @xml:id"/>
                    <xsl:attribute name="xml:id"
                        select="normalize-space(concat(parent::*/@xml:id, '.', count(preceding-sibling::tei:w[//text()]) + 1))"/>
                    <xsl:apply-templates mode="cleanup"/>
                </w>
                <xsl:copy-of
                    select="*[self::tei:pc | self::tei:lb[not(@break='no')] | self::tei:cb | self::tei:pb|self::tei:milestone][following-sibling::node()[not(string(.)) or not(following-sibling::node())]]"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- get rid of lbs etc that are within words and should not be because of coding errors -->
    <xsl:template match="tei:w/tei:lb[not(@break='no')] | tei:w/tei:cb | tei:w/tei:pb| tei:w/tei:pc |tei:milestone" mode="cleanup">
        <!-- omit -->
    </xsl:template>

    <!-- is this necessary? -->
    <xsl:template match="tei:c">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:if test="parent::tei:seg[@type = 'altChar']">
                <xsl:attribute name="type" select="'altChar'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
