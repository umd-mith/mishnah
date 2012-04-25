<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its local" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="no" method="xml" omit-xml-declaration="no" encoding="UTF-8"/>
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
                select="document('../tei/ref.xml',document(''))/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit except ."
            />
        </xsl:variable>
        <TEI xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:svg="http://www.w3.org/2000/svg"
            xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Title</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <div>
                        <xsl:attribute name="n">
                            <xsl:value-of select="$mcite"/>
                        </xsl:attribute>
                        <xsl:for-each select="./tei:item">
                            <xsl:variable name="Wit">
                                <xsl:copy-of select="."/>
                            </xsl:variable>
                            <ab>
                                <xsl:attribute name="n">
                                    <xsl:value-of select="$Wit"/>
                                </xsl:attribute>
                                <!-- Build URI from ref.xml, assemble in buildURI -->
                                <xsl:variable name="buildURI">
                                    <xsl:text>../tei/</xsl:text>
                                    <xsl:value-of
                                        select="$witlist//tei:witness[@xml:id=$Wit]/@corresp"/>
                                    <xsl:text>#</xsl:text>
                                    <xsl:value-of select="$Wit"/>
                                    <xsl:text>.</xsl:text>
                                    <xsl:value-of select="$mcite"/>
                                </xsl:variable>
                                <!-- Extract text -->
                                <xsl:variable name="mExtract">
                                    <extract>
                                        <xsl:copy-of select="document($buildURI)/node()|@*"/>
                                    </extract>
                                </xsl:variable>
                                <xsl:variable name="mPreproc-1">
                                    <!-- Preprocess pass 1. By sibling recursion (mode = "preproc-1")
                                    and processing within sibling nodes ("preproc-within"), convert
                                    to text + a few select elements. -->
                                    <xsl:apply-templates mode="preproc-1"
                                        select="$mExtract/tei:extract/node()[1]"/>
                                </xsl:variable>
                                <xsl:variable name="mTokenize">
                                    <xsl:apply-templates mode="tokenize"
                                        select="$mPreproc-1/node()[1]"/>
                                </xsl:variable>
                                <xsl:copy-of select="$mTokenize"/>
                            </ab>
                        </xsl:for-each>
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="node()" mode="preproc-1">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:c | self::tei:g[not(@ref = '#fill')]">
                <xsl:value-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:quote">
                <xsl:apply-templates mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:w">
                <xsl:choose>
                    <xsl:when test="./tei:lb/@n mod 10 = 0">
                        <w><xsl:apply-templates select="./node()" mode="preproc-within"/><reg>
<xsl:value-of select="normalize-space(translate(.,'?וי','*'))"></xsl:value-of></reg></w>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="self::tei:persName">
                <xsl:apply-templates select="./node()" mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            
            <xsl:when test="self::tei:pc">
                <xsl:element name="{name()}">
                    <xsl:if test="./@type"><xsl:attribute name="type" select="./@type"/></xsl:if>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:label">
                <xsl:element name="{name()}">
                    <xsl:value-of select="."/>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:lb[not(./@type)]">
                <xsl:element name="{name()}">
                    <xsl:if test="./@n mod 10 = 0">
                        <xsl:attribute name="n" select="./@n"/>
                    </xsl:if>
                </xsl:element>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:seg">
                <!-- Currently selects only original text. Can be altered to include to include
                    added corrected text as well. -->
                <xsl:variable name="tempSeg">
                    <xsl:copy-of
                        select="(node() except child::tei:add |
                    tei:corr)"/>
                </xsl:variable>
                <xsl:value-of select="$tempSeg"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:choice">
                <xsl:variable name="expan" select="normalize-space(./tei:expan)">
                    
                </xsl:variable>
                <xsl:variable name="abbr" select="normalize-space(./tei:abbr)">
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not(contains($expan,' '))">
                        <w>
                            <xsl:value-of select="$abbr"/>
                            <expan>
                                <xsl:value-of select="$expan"/>
                            </expan>
                            <reg><xsl:value-of select="translate($expan,'?וי','*')"/></reg>
                        </w>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="tokenize-abbr">
                            <xsl:with-param name="abbr" select="$abbr">
                            </xsl:with-param>
                            <xsl:with-param name="src" select="$expan"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:when test="self::tei:damage">
                <xsl:apply-templates select="./node()" mode="preproc-within"/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <!-- Nodes to be removed altogether-->
            <xsl:when
                test="self::tei:g[@ref='#fill'] | self::tei:note | self::tei:space | self::tei:surplus | self::tei:milestone | self::comment()">
                <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
               <xsl:apply-templates select="following-sibling::node()[1]" mode="preproc-1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- These templates process notes within the siblings selected by sibling recursion -->
    <xsl:template match="//tei:choice" mode="preproc-within">
        <!-- For abbreviations embedded in other nodes (e.g., persName) use this template -->
        <xsl:variable name="expan">
            <xsl:value-of select="normalize-space(./tei:expan)"/>
        </xsl:variable>
        <xsl:variable name="abbr">
            <xsl:value-of select="normalize-space(./tei:abbr)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(contains($expan,' '))">
                <w>
                    <xsl:value-of select="$abbr"/>
                    <expan>
                        <xsl:value-of select="$expan"/>
                    </expan>
                    <reg><xsl:value-of select="translate($expan,'?וי','*')"/></reg>
                </w>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-abbr">
                    <xsl:with-param name="abbr">
                        <xsl:value-of select="$abbr"/>
                    </xsl:with-param>
                    <xsl:with-param name="src">
                        <xsl:value-of select="$expan"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="//tei:ref" mode="preproc-within"/>
    <xsl:template match="tei:g[@type='wordbreak'] | tei:c[@type='wordbreak']" mode="preproc-within"/>
    <xsl:template match="tei:g[@type!='wordbreak']" mode="preproc-within">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="tei:lb[@type = 'nobreak']" mode="spec-case">
        <xsl:text>|</xsl:text>
    </xsl:template>
    <xsl:template match="tei:lb | tei:pb | tei:cb" mode="preproc-within">
        <xsl:element name="{name()}">
            <xsl:if test="./@n mod 10 = 0">
                <xsl:attribute name="n">
                    <xsl:value-of select="./@n"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="//tei:supplied | //tei:damageSpan | //tei:anchor | //tei:space | //tei:note"
        mode="preproc-within"/>
    <xsl:template match="//tei:unclear | //tei:gap" mode="preproc-within">
        <xsl:text>[ ]</xsl:text>
    </xsl:template>
    <!-- Tokenize mode -->
    <xsl:template match="node()" mode="tokenize">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:variable name="string" select="normalize-space(replace(.,'\]\s*?\[',''))"></xsl:variable>
                <xsl:choose>
                    <xsl:when test="not(contains($string,' '))">
                        <w><xsl:value-of select="$string"/><reg><xsl:value-of select="translate($string,'?וי','*')"/></reg></w>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="tokenize-wds">
                            <xsl:with-param name="src" select="$string"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="following-sibling::node()[1]" mode="tokenize"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::node()[1]" mode="tokenize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- recursively splits string into <token> elements -->
    <!-- Adapts a template from: http://www.usingxml.com/Transforms/XslTechniques -->
    <!-- Two versions: one to deal with words in text nodes, another to process choice/abbr -->
    <xsl:template name="tokenize-wds">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <w><xsl:value-of select="translate(substring-before($src,' '),'?','*')"/><reg><xsl:value-of select="translate(substring-before($src,' '),'?וי','*')"></xsl:value-of></reg></w>
                <!-- recurse -->
                <xsl:call-template name="tokenize-wds">
                    <xsl:with-param name="src" select="translate(substring-after($src,' '),'?','*')"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <w><xsl:value-of select="translate($src,'?','*')"/><reg><xsl:value-of select="translate($src,'?וי','*')"></xsl:value-of></reg></w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="tokenize-abbr">
        <xsl:param name="src"/>
        <xsl:param name="abbr"/>
        <xsl:choose>
            <xsl:when test="contains($src,' ')">
                <!-- build first token element -->
                <w><xsl:value-of select="normalize-space($abbr)"/><expan><xsl:value-of select="normalize-space(translate(substring-before($src,'
                        '),'?','*'))"/></expan>
                    <reg><xsl:value-of select="normalize-space(translate(substring-before($src,' '),'?וי','*'))"/></reg></w>
                <!-- recurse -->
                <xsl:call-template name="tokenize-abbr">
                    <xsl:with-param name="src" select="translate(substring-after($src,' '),'?','*')"/>
                    <xsl:with-param name="abbr"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <w><expan><xsl:value-of select="normalize-space(translate($src,'?','*'))"/></expan>
                    <reg><xsl:value-of select="normalize-space(translate($src,'?וי','*'))"></xsl:value-of></reg></w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
