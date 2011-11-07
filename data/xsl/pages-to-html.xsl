<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output method="html" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="tei:damageSpan and tei:anchor and
        tei:gap and xs:comment"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 23, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Need to run flattening stylsheet then unflattentopages -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//tei:anchor | //tei:damageSpan | //tei:gap"> </xsl:template>
    <xsl:template match="//tei:ab">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/FormattingforHTML.css"
                    title="Documentary" alternate="no"/>
            </head>
            <body lang="he" dir="rtl">
                <h1>
                    <xsl:value-of select="//tei:title"/>
                </h1>
                <h2>Transcription</h2>
                <xsl:apply-templates select="//tei:text"/>
                <h2>Notes</h2>
                <xsl:apply-templates select="//tei:note" mode="notes"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:milestone[@Order]">
        <span class="ord"> Order <xsl:value-of select="./@xml:id"/>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@Tractate]">
        <span class="tr"> Tractate <xsl:value-of select="./@xml:id"/>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Chapter']">
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>
        <span>
            <xsl:attribute name="class">Chapter</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^P_([A-Z]{{1,2}})\.(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(5)"/>
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
            <xsl:attribute name="class">Mishnah</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^P_([A-Z]{{1,2}})\.(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(6)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb[ancestor::tei:div[1]]">
        <br/>
        <xsl:if test="(./@n + 1) mod 5 = 0">
            <span>
                <xsl:attribute name="class">lb</xsl:attribute>
                <xsl:value-of select="(./@n + 1)"/>
            </span>
        </xsl:if>
    </xsl:template>
    <xsl:template name="add-br">
        <xsl:param name="howMany">1</xsl:param>
        <xsl:if test="$howMany &gt; 0">
            <br/>
            <xsl:call-template name="add-br">
                <xsl:with-param name="howMany" select="$howMany - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:div[@type='page']">
        <div class="page">
            
            <xsl:if test="not(descendant::tei:div[1][@type='column'])">
                <div class="OneCol">
                    <span class="pageNo">Folio <xsl:value-of select="./@n"/></span>
                    <xsl:apply-templates/>
                    <xsl:if test="descendant::tei:lb[position() = 1]/@n &gt; 1">
                        <xsl:variable name="firstline">
                            <xsl:value-of select="descendant::tei:lb[position() = 1]/@n"/>
                        </xsl:variable>
                        <xsl:call-template name="add-br">
                            <xsl:with-param name="howMany" select="$firstline - 1"/>
                        </xsl:call-template>
                    </xsl:if>
                </div>
            </xsl:if>
            <xsl:if test="descendant::tei:div[1][@type='column']"><xsl:apply-templates></xsl:apply-templates></xsl:if>
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
                <xsl:if test="contains($col, 'A')">ColumnA</xsl:if>
                <xsl:if test="contains($col, 'B')">ColumnB</xsl:if>
            </xsl:attribute>
            <xsl:if test="contains($col, 'A')">
                <span class="pageNo">Folio <xsl:value-of
                        select="./ancestor::tei:div[@type='page']/@n"/></span></xsl:if>
            <span class="ColNo"><xsl:value-of select="./@n"/></span>
            <xsl:if test="descendant::tei:lb[position() = 1]/@n &gt; 1">
                <xsl:variable name="firstline">
                    <xsl:value-of select="descendant::tei:lb[position() = 1]/@n"/>
                </xsl:variable>
                <xsl:call-template name="add-br">
                    <xsl:with-param name="howMany" select="$firstline - 1"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:add">
        <span class="add">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:del">
        <span class="del">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:ref">
        <span class="bibQuote">
            <xsl:value-of select="tei:ref"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:supplied">
        <xsl:choose>
            <xsl:when test="parent::tei:unclear">
                <xsl:variable name="copynode">
                    <xsl:copy-of select=" descendant-or-self::tei:supplied"/>
                </xsl:variable>
                <span class="traces">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="preceding::tei:gap and not(parent::tei:unclear)">
                <xsl:variable name="copynode">
                    <xsl:copy-of select=" descendant-or-self::tei:supplied"/>
                </xsl:variable>
                <span class="missing">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="//tei:unclear[not(child::tei:supplied)]">
        <xsl:variable name="copynode">
            <xsl:copy-of select=" descendant-or-self::tei:supplied"/>
        </xsl:variable>
        <span class="unclear">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:choice">
        <span class="abbr">
            <xsl:value-of select="./tei:abbr"/>
        </span>
        <span class="expan">
            <xsl:value-of select="./tei:expan"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:trailer">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:label">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:head">
        <span class="label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Notes templates need revision.-->
    <xsl:template match="//tei:note">
        <xsl:variable name="id">
            <xsl:text>fnanc</xsl:text>
            <xsl:value-of select="count(preceding::tei:note)+1"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#fn</xsl:text>
            <xsl:value-of select="count(preceding::tei:note)+1"/>
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
    <xsl:template match="tei:note" mode="notes">
        <xsl:variable name="id">
            <xsl:text>fn</xsl:text>
            <xsl:value-of select="count(preceding::tei:note)+1"/>
        </xsl:variable>
        <xsl:variable name="href">
            <xsl:text>#fnanc</xsl:text>
            <xsl:value-of select="count(preceding::tei:note)+1"/>
        </xsl:variable>
        <p>
            <a>
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute> Fol. <xsl:value-of select="ancestor::tei:div[@type='page']/@n"/>,
                l. <xsl:value-of select="following::tei:lb[1]/@n"/>
            </a>
            <xsl:text>. </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
</xsl:stylesheet>
