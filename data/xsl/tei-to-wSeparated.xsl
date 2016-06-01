<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:strip-space elements="*"/>
    <!--<xsl:strip-space elements="tei:damage tei:unclear tei:gap"/>-->

    <xsl:output indent="yes"/>
    <xsl:param name="iterate" select="'yes'"/>
    <xsl:param name="csv">no</xsl:param>
    <xsl:param name="path" select="'../tei'"/>

    <xsl:variable name="files"
        select="collection(iri-to-uri(concat($path, '?select=[PS][0-9]{5}.xml;recurse=no')))"/>

    <xsl:template match="* | text() | @* | comment() | processing-instruction()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="* | text() | @* | comment() | processing-instruction()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:choose>
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
            <xsl:when test="$iterate='no'">
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
        <xsl:variable name="segment">
            <xsl:apply-templates/>
        </xsl:variable>

 <xsl:variable name="cleanup"><xsl:apply-templates mode="group" select="$segment"/></xsl:variable>
        <xsl:apply-templates select="$cleanup" mode="cleanup"></xsl:apply-templates>
    </xsl:template>

    <!-- Flatten every relevant descendant of head, trailer, ab -->
    <!-- damage and unclear to spans -->
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
    <!-- segments to spans -->
    <xsl:template match="tei:seg">
        <sep xmlns="http://www.tei-c.org/ns/1.0"/>
        <span type="seg">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="to" select="concat('#', generate-id())"/>
        </span>
        <xsl:apply-templates/>
        <xsl:element name="anchor">
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:attribute name="type" select="'seg'"/>
        </xsl:element>
    </xsl:template>
    <!-- special handling of elements we don't want subordinated to <w>s -->
    <!-- special case of existing w and choice elements, needs returning to. -->
    <xsl:template match="tei:w|tei:surplus|tei:gap|tei:fw|tei:lb[not(@break = 'no')] | tei:pb | tei:cb |tei:label|tei:pc|tei:milestone">
        <xsl:choose>
            <!-- ignore pbs etc in divs -->
            <xsl:when test="parent::tei:div1|parent::tei:div2|parent::tei:div3"/>
            <xsl:otherwise><sep xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="."></xsl:copy-of>
            </sep></xsl:otherwise></xsl:choose>
    </xsl:template>
    <xsl:template match="tei:choice[tei:abbr|tei:expan]|tei:choice[not(ancestor::tei:w)][tei:orig|tei:reg]">
        <sep xmlns="http://www.tei-c.org/ns/1.0">
            <w><xsl:copy-of select="."></xsl:copy-of></w>
        </sep>
    </xsl:template>
    
    <!-- removing elements not used currently -->
    <xsl:template match="tei:supplied | tei:damageSpan | tei:anchor"> </xsl:template>
    <xsl:template match="tei:num">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template
        match="text()[ancestor::tei:ab  
or ancestor::tei:head 
or ancestor::tei:trailer]">
        <xsl:variable name="curr" select="parent::*/name()"></xsl:variable>
        <xsl:if test="not(ancestor::tei:surplus|ancestor::tei:fw|ancestor::tei:note |ancestor::tei:surplus |ancestor::tei:w |ancestor::tei:label|ancestor::tei:pc)"><xsl:analyze-string select="." regex="\s+">
            <xsl:matching-substring>
                <xsl:if test="not($curr='expan')"><sep xmlns="http://www.tei-c.org/ns/1.0"/></xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string></xsl:if>
    </xsl:template>

    <!-- grouping -->
    <xsl:template match="tei:ab | tei:head | tei:trailer" mode="group">
        <xsl:element name="{name()}"><xsl:copy-of select="@*"/>
            <!-- namespace problem I can't sort out -->
        <xsl:for-each-group select="node()" group-adjacent="not(self::*[name()='sep'])">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <w><xsl:copy-of select="current-group()"></xsl:copy-of></w>
                </xsl:when>
                <xsl:otherwise><xsl:copy-of select="current-group()/self::*[name()='sep']/node()"></xsl:copy-of></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group></xsl:element>
    </xsl:template>

<xsl:template match="tei:w" mode="cleanup">
    <w><!-- need to deal with <w>s that already have IDs from transcription (e.g., transposition) -->
        <xsl:copy-of select="@*"></xsl:copy-of>
        <xsl:attribute name="xml:id" select="concat(parent::*/@xml:id,'.',count(preceding-sibling::tei:w)+1)"></xsl:attribute>
        <xsl:apply-templates mode="cleanup"></xsl:apply-templates>
    </w>
</xsl:template>
</xsl:stylesheet>
