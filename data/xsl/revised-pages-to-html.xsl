<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output method="html" indent="no" encoding="UTF-8" omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
    
    <xsl:strip-space
        elements=" tei:choice and tei:am and
        tei:gap and xs:comment and tei:orig and tei:reg and tei:unclear and tei:damage and tei:gap"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 23, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Need to run flattening stylsheet then unflattentopages -->
    <!--Updated transformations to result in valid TEI in xml output and valid HTML in html output -->
    <xsl:template match="*|@*|text()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template
        match="//tei:anchor | //tei:damageSpan |
        tei:milestone[@unit='MSMishnah'] | tei:milestone[@unit='fragment']"> </xsl:template>
    <xsl:template match="tei:ab | tei:w">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="/">
        
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/FormattingforHTML.css"
                    title="Documentary"/>
                <title>
                    <xsl:value-of
                        select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"
                        exclude-result-prefixes="#all"/>
                </title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body xsl:exclude-result-prefixes="#all" dir="rtl">
                <h1>
                    <xsl:value-of select="//tei:title"/>
                </h1>
                <h2>Transcription</h2>
                <xsl:apply-templates select="//tei:text"/>
                <h2>Notes</h2>
                <xsl:apply-templates select="//tei:note[ancestor::tei:body]" mode="notes"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:body |tei:text | tei:c | tei:g | //tei:pc |tei:c | tei:am">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- remove the temporary supplied text -->
    <xsl:template match="tei:supplied"> </xsl:template>
    <!-- Hide in CSS. Eventually, extract order name and tractate name from id. -->
    <xsl:template match="tei:milestone[@unit='Order']">
        <span class="ord"> Order <xsl:value-of select="./@xml:id"/>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Tractate']">
        <span class="tr"> Tractate <xsl:value-of select="./@xml:id"/>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Chapter']">
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>
        <span>
            <xsl:attribute name="class">chapter</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^P_(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(4)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='ab']">
        <xsl:variable name="col">
            <xsl:value-of select="./ancestor::tei:div[1]/@n"/>
        </xsl:variable>
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>
        <span>
            <xsl:attribute name="class">mishnah</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^P_(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(5)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:choose>
            <xsl:when test="(./@n + 1) mod 5 = 0">
                <br/>
                <span>
                    <xsl:attribute name="class">lb</xsl:attribute>
                    <xsl:value-of select="(./@n + 1)"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:space">
        <xsl:call-template name="add-char">
            <xsl:with-param name="howMany" select="./@extent"/>
            <xsl:with-param name="char" select="'&#160;'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="tei:gap">
        <xsl:choose>
            <xsl:when test="./@reason='Maimonides'">
                <xsl:if test="./@unit='chars'">
                    <xsl:call-template name="add-char">
                        <xsl:with-param name="howMany" select="./@extent"/>
                        <xsl:with-param name="char" select="'&#160;'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="./@unit='lines'">
                    <xsl:variable name="char">
                        <br/>
                    </xsl:variable>
                    <xsl:call-template name="add-char">
                        <xsl:with-param name="howMany" select="./@extent"/>
                        <xsl:with-param name="char" select="$char"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="not(./@reason='Maimonides')">
                <xsl:choose>
                    <!-- NB: Need to fix last <gap> of div -->
                    <!--  -->
                    <!-- Temporary transformation, for files still containing <supplied> -->
                    <xsl:when test="./following-sibling::*[1]/self::tei:supplied">
                        <xsl:for-each select="./following-sibling::*[1]/self::tei:supplied">
                            <span class="supplied">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- the other handlings of tei:gap -->
                    <!-- These use cases needs fixing -->
                    <xsl:when test="preceding::*[1]/self::tei:lb and
                        not(preceding::node()[1]/text()|tei:unclear)">
                        <span class="missing"><xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="'&#160;'"/>
                            </xsl:call-template>]</span>
                    </xsl:when>
                    <xsl:when test="following::*[1]/self::tei:lb and
                        not(following::node()[1]/text()|tei:unclear)">
                        <span class="missing">[<xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="'&#160;'"/>
                            </xsl:call-template></span>
                    </xsl:when>
                    <xsl:when
                        test="following::tei:lb[1]/@n='1' and not(preceding::node()[1]/text())">
                        <span class="missing"><xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="'&#160;'"/>
                            </xsl:call-template>]</span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="missing">[<xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="'&#160;'"/>
                            </xsl:call-template>]</span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="add-char">
        <xsl:param name="howMany">1</xsl:param>
        <xsl:param name="char">-</xsl:param>
        <xsl:if test="$howMany &gt; 0 and $char !='^'">
            <xsl:copy-of select="$char"/>
            <xsl:call-template name="add-char">
                <xsl:with-param name="howMany" select="$howMany - 1"/>
                <xsl:with-param name="char" select="$char"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:div[@type='page']">
        <div class="page">
            <xsl:if test="not(descendant::tei:div[1][@type='column'])">
                <div class="oneCol">
                    <span class="pageNo">Folio <xsl:value-of select="./@n"/></span>
                     <xsl:if test="descendant::tei:lb[count(preceding::tei:lb) = 0]/@n &gt; 1">
                        <xsl:variable name="firstline">
                            <xsl:value-of select="descendant::tei:lb[count(preceding::tei:lb) = 0]/@n"/>
                        </xsl:variable>
                        <xsl:variable name="char">
                            <br/>
                        </xsl:variable>
                        <xsl:call-template name="add-char">
                            <xsl:with-param name="howMany" select="$firstline - 1"/>
                            <xsl:with-param name="char" select="$char"/>
                        </xsl:call-template>
                    </xsl:if><xsl:apply-templates/>
                   
                </div>
            </xsl:if>
            <xsl:if test="descendant::tei:div[1][@type='column']">
                <xsl:apply-templates/>
            </xsl:if>
        </div>
        <div class="hr">
            <hr/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type='column']">
        <xsl:variable name="col">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <div>
            <xsl:attribute name="class">
                <xsl:if test="contains($col, 'A')">columnA</xsl:if>
                <xsl:if test="contains($col, 'B')">columnB</xsl:if>
            </xsl:attribute>
            <xsl:if test="contains($col, 'A')">
                <span class="pageNo">folio <xsl:value-of
                        select="./ancestor::tei:div[@type='page']/@n"/></span>
            </xsl:if>
            <span class="colNo">
                <xsl:value-of select="./@n"/>
            </span>
            <xsl:if test="descendant::tei:lb[position() = 1]/@n &gt; 1">
                <xsl:variable name="firstline">
                    <xsl:value-of select="descendant::tei:lb[position() = 1]/@n"/>
                </xsl:variable>
                <xsl:variable name="char">
                    <br/>
                </xsl:variable>
                <xsl:call-template name="add-char">
                    <xsl:with-param name="howMany" select="$firstline - 1"/>
                    <xsl:with-param name="char" select="$char"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:surplus">
        <span class="surplus">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:add">
        <span class="add">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:del">
        <span class="del">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:quote">
        <span class="quote">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:ref">
        <span class="bibQuote">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:sic">
        <span class="sic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:corr">
        <span class="corr">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Process <damage> -->
    <xsl:template match="tei:unclear">
        <!-- Represent unclear text as periods using extent-->
        <!-- When text is present in <unclear> add difference between @extent and
            the number of characters present in the form of dots-->
        <xsl:variable name="adj-length">
            <!-- Removes spaces and geresh from string length -->
            <xsl:value-of
                select="number(string-length(translate(normalize-space(.),'&#x32;&#1523;
                ','')))"
            />
        </xsl:variable>
        <span class="unclear">
            <!-- replacement string of thin-space/period/thin-space -->
            <xsl:variable name="dots" as="xs:string">
                <xsl:text>&#8201;.&#8201;</xsl:text>
            </xsl:variable>
            
                <xsl:choose>
                    <!-- converts node to text  and replaces ? with dots. Assumes that will not be
                        retaining child nodes of unclear. This may change.  -->
                    <xsl:when test="string(.)">
                        <xsl:value-of
                            select="normalize-space(replace(. except tei:note,'\?',$dots))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''"/>
                    </xsl:otherwise>
                </xsl:choose>
            
           
            <xsl:choose>
                <xsl:when test="number(./@extent) - $adj-length &lt;= 0">
                    <!-- If traces = extent then do not add dots -->
                </xsl:when>
                <xsl:when test="number(./@extent) - $adj-length &gt; 0">
                    <!-- add dots -->
                   
                    <xsl:call-template name="add-char">
                        <xsl:with-param name="howMany">
                            <xsl:value-of select="number(./@extent) - $adj-length"/>
                        </xsl:with-param>
                        <xsl:with-param name="char">
                            <xsl:value-of select="$dots"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:template>
    <xsl:template match="tei:damage">
        <!-- based on a sample template at: http://www.w3.org/TR/xslt20/#grouping-examples -->
        <xsl:for-each-group select="node()" group-adjacent="self::tei:unclear or self::tei:gap">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <span class="damage"><xsl:apply-templates select="current-group()"/></span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="tei:choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:orig">
        <span class="pointed">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:reg">
        <span class="unpointed">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:expan">
        <span class="expan">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:abbr">
        <span class="abbr">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:persName">
        <span class="persName">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:trailer">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:label">
        <span class="label">
            <xsl:apply-templates select="node()"></xsl:apply-templates>
        </span>
    </xsl:template>
    <xsl:template match="//tei:head">
        <span class="label">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:note[ancestor::tei:body]">
        <xsl:variable name="id">
            <xsl:text>fnanc</xsl:text>
            <xsl:value-of select="count(preceding::tei:note[ancestor::tei:body])+1"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#fn</xsl:text>
            <xsl:value-of select="count(preceding::tei:note[ancestor::tei:body])+1"/>
        </xsl:variable>
        <a>
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$href"/>
            </xsl:attribute>
            <span class="note-ref">
                <xsl:text>˚</xsl:text>
            </span>
        </a>
    </xsl:template>
    <xsl:template match="tei:note[ancestor::tei:body]" mode="notes">
        <xsl:variable name="id">
            <xsl:text>fn</xsl:text>
            <xsl:value-of select="count(preceding::tei:note[ancestor::tei:body])+1"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#fnanc</xsl:text>
            <xsl:value-of select="count(preceding::tei:note[ancestor::tei:body])+1"/>
        </xsl:variable>
        <p>
            <a>
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:text> Fol. </xsl:text>
                <xsl:value-of select="ancestor::tei:div[@type='page']/@n"/>
                <xsl:if test="ancestor::tei:div[@type='column']">
                    <xsl:choose>
                        <xsl:when test="contains(ancestor::tei:div[@type='column']/@n, 'A')"
                            >A</xsl:when>
                        <xsl:when test="contains(ancestor::tei:div[@type='column']/@n, 'B')"
                            >B</xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:text>, l. </xsl:text>
                <xsl:value-of select="following::tei:lb[1]/@n"/>
            </a>
            <xsl:text>. </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
</xsl:stylesheet>
