<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="tei:unclear tei:gap"/>

    <xsl:output indent="yes"/>
    <xsl:param name="csv">no</xsl:param>
    <xsl:template match="*|text()|@*">
        <!-- Identity transform ignores comments and processing instructions -->
        <xsl:copy>
            <xsl:apply-templates select="*|text()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Structural elements -->
    <xsl:template match="tei:head|tei:trailer|tei:ab">
        <xsl:variable name="id">
            <xsl:value-of select="@xml:id"/>
        </xsl:variable>
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <!-- pass 1 flatten-->
            <xsl:variable name="flat">
                <xsl:apply-templates/>
            </xsl:variable>
            <!-- pass 2 separate with temporary element milestone[@unit='sep'] -->
            <xsl:variable name="separate">
                <xsl:apply-templates select="$flat" mode="separate"/>
            </xsl:variable>

            <!-- pass 3 group on temporary milestone element -->
            <!-- move to template ***Note when moved to template, does not wrap properly*** -->
            <!-- also uses http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/201009/msg00089.html -->
            <xsl:variable name="wordWrap">
                <xsl:for-each-group select="$separate/node()"
                    group-adjacent="not(self::tei:milestone[@unit='sep'])">
                    <xsl:variable name="str" as="xs:string">
                        <xsl:value-of select="current-group()"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <!-- selects nodes that are not adjacent milestone elements -->
                            <xsl:choose>
                                <!-- omit empty <w>s, and keep other elements outside of <w>s -->
                                <xsl:when
                                    test="not(normalize-space($str)) and current-group()[self::element()]">
                                    <xsl:copy-of select="current-group()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <w>
                                        <xsl:copy-of select="current-group()"/>
                                    </w>

                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:variable>
            <!-- pass 4 xml:id Can this be combined with pass 3? -->
            <!-- move to template -->
            <xsl:for-each select="$wordWrap/node()">
                <xsl:choose>
                    <xsl:when test="self::tei:w">
                        <xsl:variable name="num">
                            <xsl:number/>
                        </xsl:variable>
                        <xsl:element name="w">
                            <xsl:attribute name="xml:id" select="concat($id,'.',$num)"/>
                            <xsl:copy-of select="node() except ."/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>


    <!-- elements to remove [for the present]-->
    <xsl:template
        match="tei:milestone|tei:pc|tei:label|tei:surplus|
        tei:fw|tei:space|tei:gap[not(@reason='damage')]|tei:note[ancestor::tei:body]"/>

    <!-- elements that require space adjustments -->
    <xsl:template match="tei:cb|tei:pb|tei:lb">
        <xsl:choose>
            <xsl:when test="@break='no'">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- elements to preserve contents -->
    <xsl:template match="tei:num|tei:am|tei:seg">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- elements to process specially -->
    <xsl:template match="tei:w|tei:choice">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>   
    </xsl:template>
    <xsl:template match="tei:abbr|tei:expan">
        <!--<xsl:text> </xsl:text>-->
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"></xsl:copy-of><xsl:apply-templates/></xsl:element>
    </xsl:template>
    <xsl:template match="tei:listTranspose|tei:transpose|tei:ptr|tei:supplied|tei:damageSpan|tei:anchor">
        <!-- for now just deleting. Needs better handling later --> 
    </xsl:template>
    <xsl:template match="tei:damage|tei:unclear|tei:gap[@reason='damage']">
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
<!--<xsl:template match="tei:add">
        <xsl:element name="{concat(name(),'Span')}">
            <xsl:attribute name="spanTo" select="concat('#',generate-id())"/><xsl:copy-of select="@*"/></xsl:element><xsl:apply-templates/><xsl:element name="anchor">
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:attribute name="type" select="name()"/>
        </xsl:element>
    </xsl:template>-->
    <xsl:template match="tei:add|tei:del">
        <xsl:element name="{concat(name(),'Span')}">
            <xsl:attribute name="spanTo" select="concat('#',generate-id())"/><xsl:copy-of select="@*"/></xsl:element><xsl:apply-templates/>
        <xsl:for-each select="1 to @extent"><xsl:value-of select="'◌'"></xsl:value-of></xsl:for-each>
        <xsl:element name="anchor">
                <xsl:attribute name="xml:id" select="generate-id()"/>
                <xsl:attribute name="type" select="name()"/>
            </xsl:element>
    </xsl:template>
    <xsl:template match="tei:c">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <!-- Temp fix for current CSV tokenization -->
            <xsl:if test="parent::tei:seg[@type='altChar']">
                <xsl:attribute name="type" select="'altChar'"></xsl:attribute>
            </xsl:if><xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- process nodes to separate with temporary milestone element -->
    <!-- See http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/201009/msg00089.html -->
    <xsl:template match="text()" mode="separate">
        <xsl:analyze-string select="." regex="\s+">
            <xsl:matching-substring>
                <milestone unit="sep"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="element()|@*" mode="separate">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="/">
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
            <xsl:apply-templates/>



    </xsl:template>
</xsl:stylesheet>
