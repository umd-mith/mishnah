<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its local my tei"
    version="2.0" xmlns:my="http://http://dev.digitalmishnah.org/local-functions.uri"
    xmlns:local="local-functions.uri">

    <xsl:output method="html" indent="no" encoding="UTF-8" omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD HTML 4.01//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
    <xsl:strip-space
        elements=" tei:choice and tei:am and
        tei:gap and xs:comment and tei:orig and tei:reg and tei:unclear and tei:damage and tei:gap
        tei:del tei:add"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 23, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Need to run flattening stylsheet then unflattentopages -->
    <!--Updated transformations to result in valid TEI in xml output and valid HTML in html output -->
    <!--<xsl:param name="rqs">ch=4.2.10&amp;pg=163r&amp;col=163rA&amp;mode=col</xsl:param>-->

    <xsl:param name="ch" select="'4.2.6'"/>
    <xsl:param name="pg" select="'163r'"/>
    <xsl:param name="col" select="'157rB'"/>
    <xsl:param name="mode" select="'col'"/>
    <xsl:variable name="wit" select="tei:TEI/tei:teiHeader//tei:idno/text()"/>
    <xsl:variable name="thisURI" select="concat('../tei/',$wit,'.xml')"/>
    <xsl:variable name="thisId">
        <!-- locates first, last, next, prev for processing links -->
        <xsl:choose>
            <xsl:when test="$mode='pg'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$pg))"/>
            </xsl:when>
            <xsl:when test="$mode='col'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$col))"/>
            </xsl:when>
            <xsl:when test="$mode='ch'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$ch))"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="thisPgColCh">
        <xsl:variable name="thisElement">
            <xsl:copy-of select="document($thisURI)//element()[@xml:id=$thisId]"/>
        </xsl:variable>
        <xsl:variable name="name" select="$thisElement/element()/name()"/>
        <xsl:variable name="id" select="$thisElement/element()/@xml:id"/>
        <this>
            <xsl:value-of select="$id"/>
        </this>
        <first>
            <xsl:choose>
                <xsl:when
                    test="document($thisURI,(document('')))/*/*//*/preceding::element()[name()=$name]">
                    <xsl:value-of
                        select="(document($thisURI,(document('')))/*/*//*)[name()=$name][1]/@xml:id"
                    />
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </first>
        <last>
            <xsl:choose>
                <xsl:when
                    test="document($thisURI,(document('')))/*/*//*/following::element()[name()=$name]">
                    <xsl:value-of
                        select="(document($thisURI,(document('')))/*/*//*)[name()=$name][last()]/@xml:id"
                    />
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>

        </last>
        <prev>
            <xsl:choose>
                <xsl:when
                    test="(document($thisURI,(document('')))/*/*//*)[@xml:id=$id]/preceding::element()[name()=$name][1]">
                    <xsl:value-of
                        select="(document($thisURI,(document('')))/*/*//*)[@xml:id=$id]/preceding::element()[name()=$name][1]/@xml:id"
                    />
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </prev>
        <next>
            <xsl:choose>
                <xsl:when
                    test="(document($thisURI,(document('')))/*/*//*)[@xml:id=$id]/following::element()[name()=$name][1]">
                    <xsl:value-of
                        select="(document($thisURI,(document('')))/*/*//*)[@xml:id=$id]/following::element()[name()=$name][1]/@xml:id"
                    />
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </next>

    </xsl:variable>
    <xsl:template match="*|@*|text()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template
        match="//tei:anchor | //tei:damageSpan |
        tei:milestone[@unit='MSMishnah'] | tei:milestone[@unit='fragment']"> </xsl:template>
    <!-- for now ignoring fw for running heads etc. -->
    <xsl:template match="//tei:fw"/>
    <xsl:template match="tei:w">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:ab">

        <xsl:choose>
            <xsl:when test="$mode='ch'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'mishnah-ch'"/>

                    <xsl:analyze-string select="@xml:id"
                        regex="^([^\.]+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(5)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'mishnah'"/>
                    <xsl:attribute name="style">dir:rtl;text-align:right;</xsl:attribute>


                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>

                <xsl:apply-templates/>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/FormattingforHTML.css"
                    title="Documentary"/>
                <link rel="stylesheet" type="text/css" href="../css/FormattingforHTML.css"
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
                    <xsl:value-of
                        select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
                </h1>
                <h2 style="font-size:80%;">[<a href="demo">Back to Demo Home Page</a>] [<a
                        href="browse">Back to Browse</a>]</h2>
                <h2 style="font-size:80%;"/>
                <div class="nav">
                    <!-- variables for building urls for paramaterized links -->
                    <xsl:variable name="goNext">
                        <xsl:variable name="ref"
                            select="substring-after($thisPgColCh/tei:next,concat($wit,'.'))"/>
                            mode=<xsl:value-of select="$mode"/>&amp;pg=<xsl:if test="$mode='pg'"
                                ><xsl:value-of select="$ref"/></xsl:if>&amp;col=<xsl:if
                            test="$mode='col'"><xsl:value-of select="$ref"/></xsl:if>&amp;ch=<xsl:if
                            test="$mode='ch'"><xsl:value-of select="$ref"/></xsl:if>
                    </xsl:variable>
                    <xsl:variable name="goFirst">
                        <xsl:variable name="ref"
                            select="substring-after($thisPgColCh/tei:first,concat($wit,'.'))"/>
                            mode=<xsl:value-of select="$mode"/>&amp;pg=<xsl:if test="$mode='pg'"
                                ><xsl:value-of select="$ref"/></xsl:if>&amp;col=<xsl:if
                            test="$mode='col'"><xsl:value-of select="$ref"/></xsl:if>&amp;ch=<xsl:if
                            test="$mode='ch'"><xsl:value-of select="$ref"/></xsl:if>
                    </xsl:variable>
                    <xsl:variable name="goPrev">
                        <xsl:variable name="ref"
                            select="substring-after($thisPgColCh/tei:prev,concat($wit,'.'))"/>
                        mode=<xsl:value-of select="$mode"/>&amp;pg=<xsl:if test="$mode='pg'"
                            ><xsl:value-of select="$ref"/></xsl:if>&amp;col=<xsl:if
                                test="$mode='col'"><xsl:value-of select="$ref"/></xsl:if>&amp;ch=<xsl:if
                                    test="$mode='ch'"><xsl:value-of select="$ref"/></xsl:if>
                    </xsl:variable>
                    <xsl:variable name="goLast">
                        <xsl:variable name="ref"
                            select="substring-after($thisPgColCh/tei:last,concat($wit,'.'))"/>
                        mode=<xsl:value-of select="$mode"/>&amp;pg=<xsl:if test="$mode='pg'"
                            ><xsl:value-of select="$ref"/></xsl:if>&amp;col=<xsl:if
                                test="$mode='col'"><xsl:value-of select="$ref"/></xsl:if>&amp;ch=<xsl:if
                                    test="$mode='ch'"><xsl:value-of select="$ref"/></xsl:if>
                    </xsl:variable>
                    <span class="last">
                        <xsl:choose>
                            <xsl:when test="$thisPgColCh/tei:last='null'">|&lt; Last</xsl:when>
                            <xsl:otherwise>
                                <a href="{$wit}.browse-param.html?{normalize-space($goLast)}">|&lt;
                                    Last</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <span class="next">
                        <xsl:choose>
                            <xsl:when test="$thisPgColCh/tei:next='null'">&lt;&lt; Next</xsl:when>
                            <xsl:otherwise>
                                <a href="{$wit}.browse-param.html?{normalize-space($goNext)}"
                                    >&lt;&lt; Next</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <span class="first">
                        <xsl:choose>
                            <xsl:when test="$thisPgColCh/tei:first='null'">First &gt;|</xsl:when>
                            <xsl:otherwise>
                                <a href="{$wit}.browse-param.html?{normalize-space($goFirst)}">First
                                    &gt;|</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <span class="prev">
                        <xsl:choose>
                            <xsl:when test="$thisPgColCh/tei:prev='null'">Previous
                                &gt;&gt;</xsl:when>
                            <xsl:otherwise>
                                <a href="{$wit}.browse-param.html?{normalize-space($goPrev)}"
                                    >Previous &gt;&gt;</a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <form action="{$wit}.browse-param.html" method="get" class="current-block"
                        >Browse by:<br/>
                        <span class="current"><xsl:variable name="refValue"><xsl:choose>
                                    <xsl:when test="$mode='pg'"><xsl:value-of
                                            select="substring-after($thisPgColCh/tei:this,concat($wit,'.'))"
                                        /></xsl:when><xsl:otherwise><xsl:value-of
                                            select="substring-after(document($thisURI)//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:pb[1]/@xml:id,concat($wit,'.'))"
                                        /></xsl:otherwise>
                                </xsl:choose></xsl:variable><xsl:choose><xsl:when test="$mode='pg'"
                                        ><input type="radio" name="mode" value="pg"
                                        checked="checked"/></xsl:when><xsl:otherwise><input
                                        type="radio" name="mode" value="pg"
                                /></xsl:otherwise></xsl:choose>Page<input type="text" name="pg"
                                size="8" value="{$refValue}"/></span>
                        <span class="current"><xsl:variable name="refValue"><xsl:choose>
                                    <xsl:when test="$mode='col'"><xsl:value-of
                                            select="substring-after($thisPgColCh/tei:this,concat($wit,'.'))"
                                        /></xsl:when><xsl:otherwise><xsl:value-of
                                            select="substring-after(document($thisURI)//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:col[1]/@xml:id,concat($wit,'.'))"
                                        /></xsl:otherwise>
                                </xsl:choose></xsl:variable>&#160;&#160;<xsl:choose><xsl:when
                                    test="$mode='col'"><input type="radio" name="mode" value="col"
                                        checked="checked"/></xsl:when><xsl:otherwise><input
                                        type="radio" name="mode" value="col"
                                /></xsl:otherwise></xsl:choose>Column<input type="text" name="col"
                                size="8" value="{$refValue}"/></span>
                        <span class="current"><xsl:variable name="refValue"><xsl:choose>
                                    <xsl:when test="$mode='ch'"><xsl:value-of
                                            select="substring-after($thisPgColCh/tei:this,concat($wit,'.'))"
                                        /></xsl:when><xsl:otherwise><xsl:choose><xsl:when
                                                test="document($thisURI)//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3"
                                                  ><xsl:value-of
                                                  select="substring-after(document($thisURI)//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3/@xml:id,concat($wit,'.'))"
                                                /></xsl:when><xsl:otherwise><xsl:value-of
                                                  select="substring-after(document($thisURI)//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:div3[1]/@xml:id,concat($wit,'.'))"
                                                /></xsl:otherwise></xsl:choose></xsl:otherwise>
                                </xsl:choose></xsl:variable>&#160;&#160;<xsl:choose><xsl:when
                                    test="$mode='ch'"><input type="radio" name="mode" value="ch"
                                        checked="checked"/></xsl:when><xsl:otherwise><input
                                        type="radio" name="mode" value="ch"
                                /></xsl:otherwise></xsl:choose>Chapter<input type="text" name="ch"
                                size="8" value="{$refValue}"/></span><input type="submit"
                            class="submForm"/></form>
                </div>
                <div class="meta" dir="ltr">
                    <xsl:variable name="nli"
                        select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:note[@type
                        = 'nli-ref']"/>
                    <table class="meta">

                        <tr>
                            <td class="data">Repository</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository"/>
                                <xsl:text>
                            (</xsl:text>
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement"/>
                                <xsl:text>) </xsl:text>
                            </td>
                            <td class="data">Dimensions:</td>
                            <td/>
                        </tr>
                        <tr>
                            <td class="data">Id no.</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno"
                                />
                            </td>
                            <td class="data">Sheet</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='sheet']/tei:height"/>
                                <xsl:text>
                                × </xsl:text>
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='sheet']/tei:width"
                                /> cm</td>
                        </tr>
                        <tr>
                            <td class="data">Hand</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/@script"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]"
                                            ><xsl:text>; </xsl:text><xsl:value-of
                                            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]/text()"
                                            />&#xa0;<xsl:value-of
                                            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]/tei:desc"/>
                                        <xsl:if
                                            test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc//tei:desc[contains(.,'pointed')]/ancestor-or-self::tei:handNote/@scribe
                                    != 'first'"
                                            > (not by primary scribe)</xsl:if>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when
                                        test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]"
                                            ><xsl:text>; </xsl:text><xsl:value-of
                                            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]/text()"
                                            />&#xa0;<xsl:value-of
                                            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]/tei:desc"/>
                                        <xsl:if
                                            test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc//tei:desc[contains(.,cantillation)]/ancestor-or-self::tei:handNote/@scribe
                                       != 'first'"
                                            > (not by primary scribe)</xsl:if>
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                            <td class="data">Written Column</td>
                            <td class="descr"><xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-cm']/tei:height"
                                    /><xsl:text>
                                × </xsl:text><xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-cm']/tei:width"
                                /> cm</td>
                        </tr>
                        <tr>
                            <td class="data">Date</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/tei:date"
                                />
                            </td>
                            <td class="data">Lines per column</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:height"
                                />
                            </td>
                        </tr>
                        <tr>
                            <td class="data">Region</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/tei:region"
                                />
                            </td>
                            <td class="data">Characters/line</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:width"
                                />
                            </td>
                        </tr>
                        <tr>
                            <td class="data">Format</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/@form"
                                />
                            </td>
                            <td class="data">Characters/cm</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:dim[@type='char-p-cm']"
                                />
                            </td>
                        </tr>
                        <tr>
                            <td class="data">Material</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/@material"
                                />
                            </td>
                            <td class="data"/>
                            <td class="descr"/>
                        </tr>
                        <tr>
                            <td class="data">Extent</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:extent"
                                /> leaves </td>
                            <td class="data">Contributions:</td>
                            <td class="descr"/>
                        </tr>
                        <tr>
                            <td class="data">Columns</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@columns"
                                />
                            </td>
                            <td class="data">Transcription</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[./tei:resp/text()='transcriber']/tei:persName"
                                />
                            </td>
                        </tr>
                        <tr>
                            <td class="data">Scribe</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:persName"
                                    separator="; "/>
                            </td>
                            <td class="data">Markup</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[./tei:resp/text()='markup']/tei:persName"
                                />
                            </td>
                        </tr>
                        <tr>
                            <td class="data">Place of copying</td>
                            <td class="descr">
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:placeName"
                                    separator="; "/>
                            </td>
                            <td class="data">
                                <xsl:if test="normalize-space($nli)">
                                    <a href="{$nli}">NLI Catalog</a>
                                </xsl:if>
                            </td>
                            <td class="descr"/>
                        </tr>
                    </table>
                </div>
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
    <xsl:template match="tei:milestone[@unit='Order' or @unit='div1']">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute name="class"
                >ord</xsl:attribute> Order <xsl:value-of select="./@xml:id"/>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Tractate' or @unit='div2']">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute name="class"
                >tr</xsl:attribute> Tractate <xsl:value-of select="./@xml:id"/>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Chapter' or @unit='div3']">
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>

        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">chapter</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^P_([^\.]+)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(4)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='ab']">
        <xsl:variable name="col">
            <xsl:value-of select="./ancestor::tei:div[1]/@n"/>
        </xsl:variable>
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">mishnah</xsl:attribute>
            <xsl:analyze-string select="$ref"
                regex="^([^\.]+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(5)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb[@n]">
        <xsl:choose>
            <xsl:when test="$mode='ch'">
                <!-- in compact ch mode mark major and minor line numbers, here set at 5 and 10 lines -->
                <xsl:choose>
                    <xsl:when test="(@n + 1) mod 5 = 0 and (@n +1) mod 2 = 1">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-ch-min</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-min-marker</xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="(@n + 1) mod 5 = 0 and (@n +1) mod 2 = 0">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-ch-maj</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-maj-marker</xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do nothing -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="(./@n + 1) mod 5 = 0">
                        <br xmlns="http://www.w3.org/1999/xhtml"/>
                        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <br xmlns="http://www.w3.org/1999/xhtml"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:space">
        <!-- in page or col view -->
        <!-- needs to be redone for @unit='lines' -->
        <xsl:choose>
            <xsl:when test="not($mode='ch')">
                <xsl:call-template name="add-char">
                    <xsl:with-param name="howMany" select="./@extent"/>
                    <xsl:with-param name="char" select="'&#160;'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><!-- ignore --></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:gap">
        <xsl:choose>
            <xsl:when test="@reason='Maimonides' or @reason='Bavli' or @reason='Yerushalmi' ">
                <!-- no not process if in ch mode -->
                <xsl:choose>
                    <xsl:when test="$mode='ch'">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'skipped'"/>
                            <xsl:value-of select="@extent"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="not($mode = 'ch')">
                        <xsl:if test="./@unit='chars'">
                            <xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="'&#160;'"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="./@unit='lines'">
                            <xsl:variable name="char">
                                <br xmlns="http://www.w3.org/1999/xhtml"/>
                            </xsl:variable>
                            <xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="$char"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="not(@reason='Maimonides' or @reason='Bavli' or @reason='Yerushalmi')">
                <xsl:choose>
                    <xsl:when test="not($mode='ch')">
                        <xsl:choose>
                            <!-- NB: Need to fix last <gap> of div -->
                            <!--  -->
                            <!-- Temporary transformation, for files still containing <supplied> -->
                            <xsl:when test="./following-sibling::*[1]/self::tei:supplied">
                                <xsl:for-each select="./following-sibling::*[1]/self::tei:supplied">
                                    <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                                        <xsl:attribute name="class">supplied</xsl:attribute>
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:when>
                            <!-- the other handlings of tei:gap -->
                            <!-- These use cases needs fixing -->
                            <!-- will need to be altered when change coding of damage -->
                            <xsl:when
                                test="preceding::*[1]/self::tei:lb and
                        not(preceding::node()[1]/text()|tei:unclear)">
                                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"
                                        ><xsl:attribute name="class" select="'missing'"
                                        /><xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="'&#160;'"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:when>
                            <xsl:when
                                test="following::*[1]/self::tei:lb and
                        not(following::node()[1]/text()|tei:unclear)">
                                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"
                                        ><xsl:attribute name="class" select="'missing'"
                                        />[<xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="'&#160;'"/>
                                    </xsl:call-template></xsl:element>
                            </xsl:when>
                            <xsl:when
                                test="following::tei:lb[1]/@n='1' and not(preceding::node()[1]/text())">
                                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"
                                        ><xsl:attribute name="class" select="'missing'"
                                        /><xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="'&#160;'"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"
                                        ><xsl:attribute name="class" select="'missing'"
                                        />[<xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="'&#160;'"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$mode='ch'">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'gap-ch'"/>
                            <xsl:value-of select="@extent"/>
                        </xsl:element>
                    </xsl:when>
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
        <div class="page" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:if test="not(descendant::tei:div[1][@type='column'])">
                <div class="oneCol">
                    <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute
                            name="class" select="'pageNo'"/>Folio <xsl:value-of select="./@n"
                        /></xsl:element>
                    <xsl:if test="descendant::tei:lb[count(preceding::tei:lb) = 0]/@n &gt; 1">
                        <xsl:variable name="firstline">
                            <xsl:value-of
                                select="descendant::tei:lb[count(preceding::tei:lb) = 0]/@n"/>
                        </xsl:variable>
                        <xsl:variable name="char">
                            <br xmlns="http://www.w3.org/1999/xhtml"/>
                        </xsl:variable>
                        <xsl:call-template name="add-char">
                            <xsl:with-param name="howMany" select="$firstline - 1"/>
                            <xsl:with-param name="char" select="$char"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates/>
                </div>
                <div xmlns="http://www.w3.org/1999/xhtml" class="hr">
                    <hr> </hr>
                </div>
            </xsl:if>
            <xsl:if test="descendant::tei:div[1][@type='column']">
                <xsl:apply-templates/>
            </xsl:if>
        </div>
        <div xmlns="http://www.w3.org/1999/xhtml" class="hr">
            <hr> </hr>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type='column']">
        <xsl:variable name="col">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">
                <xsl:if test="contains($col, 'A')">columnA</xsl:if>
                <xsl:if test="contains($col, 'B')">columnB</xsl:if>
            </xsl:attribute>
            <xsl:if test="contains($col, 'A')">
                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute
                        name="class" select="'pageNo'"/>folio <xsl:value-of
                        select="./ancestor::tei:div[@type='page']/@n"/></xsl:element>
            </xsl:if>
            <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class" select="'colNo'"/>
                <xsl:value-of select="./@n"/>
            </xsl:element>
            <xsl:if test="descendant::tei:lb[position() = 1]/@n &gt; 1">
                <xsl:variable name="firstline">
                    <xsl:value-of select="descendant::tei:lb[position() = 1]/@n"/>
                </xsl:variable>
                <xsl:variable name="char">
                    <br xmlns="http://www.w3.org/1999/xhtml"/>
                </xsl:variable>
                <xsl:call-template name="add-char">
                    <xsl:with-param name="howMany" select="$firstline - 1"/>
                    <xsl:with-param name="char" select="$char"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
        <div xmlns="http://www.w3.org/1999/xhtml" class="hr">
            <hr> </hr>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type='singCol']">
        <xsl:variable name="col">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">columnA</xsl:attribute>



            <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class" select="'colNo'"/>
                <xsl:value-of select="./@n"/>
            </xsl:element>
            <xsl:if test="descendant::tei:lb[position() = 1]/@n &gt; 1">
                <xsl:variable name="firstline">
                    <xsl:value-of select="descendant::tei:lb[position() = 1]/@n"/>
                </xsl:variable>
                <xsl:variable name="char">
                    <br xmlns="http://www.w3.org/1999/xhtml"/>
                </xsl:variable>
                <xsl:call-template name="add-char">
                    <xsl:with-param name="howMany" select="$firstline - 1"/>
                    <xsl:with-param name="char" select="$char"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type='chap']">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'page'"/>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class" select="'chap'"/>
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">chapter-ch</xsl:attribute>
                    <xsl:analyze-string select="@n"
                        regex="^([^\.]+)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:element>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
        <div xmlns="http://www.w3.org/1999/xhtml" class="hr">
            <hr> </hr>
        </div>
    </xsl:template>
    <!-- PB and CB only exist in ch mode -->
    <xsl:template match="tei:pb">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">pageNo-ch</xsl:attribute>
            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
        </xsl:element>
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">pageNo-ch-marker</xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:cb">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">colNo-ch</xsl:attribute>
            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
        </xsl:element>
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">colNo-ch-marker</xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:surplus">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'surplus'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:seg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:add[@type='comm']"/>
    <xsl:template match="tei:add[not(@type='comm')]">

        <xsl:choose>
            <xsl:when test="$mode='ch'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'add'"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- next stage to fix: want to allow margin-right margin left, etc -->
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'add'"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:del">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'del'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:metamark[@function='transposition']">
        <xsl:choose>
            <xsl:when test="string-length(.)=0">
                <!-- For now do nothing. At some point refine handling of this -->
            </xsl:when>
            <xsl:when test="string-length(.) &gt; 0">
                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'metamark'"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:listTranspose">
        <!-- For now, skip this element. -->
    </xsl:template>
    <xsl:template match="tei:quote">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'quote'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'bibQuote'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:sic">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'sic'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:corr">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'corr'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!-- Process <damage> -->
    <xsl:template match="tei:unclear">
        <xsl:choose>
            <xsl:when test="not($mode='ch')">
                <!-- In page and col mode -->
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
                <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'unclear'"/>
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
                </xsl:element>
            </xsl:when>
            <!-- in compact ch mode -->
            <xsl:when test="$mode='ch'">
                <xsl:choose>
                    <xsl:when test="@extent">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'unclear-ext-ch'"/>
                            <xsl:value-of select="@extent"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'unclear-chars-ch'"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:damage">
        <!-- based on a sample template at: http://www.w3.org/TR/xslt20/#grouping-examples -->
        <xsl:for-each-group select="node()" group-adjacent="self::tei:unclear or self::tei:gap">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class" select="'damage'"/>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="tei:choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:orig">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'pointed'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:reg">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'unpointed'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:expan">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'expan'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:abbr">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'abbr'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:persName">
        <!-- ignore for now -->
        <!--<xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute name="class" select="'persName'"/>
            <xsl:apply-templates/>
        </xsl:element>-->
    </xsl:template>
    <xsl:template match="//tei:trailer">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'label'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="//tei:label">
        <xsl:choose>
            <!-- pg and col mode -->
            <xsl:when test="not($mode='ch')">
                <xsl:choose>
                    <xsl:when test=".[contains(@rend,'margin-right')]">
                        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'marg-label-r'"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'label'"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode='ch'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'label-ch'"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="//tei:head">
        <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'label'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
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
        <xsl:element name="a" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$href"/>
            </xsl:attribute>
            <xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class" select="'note-ref'"/>
                <xsl:text>˚</xsl:text>
            </xsl:element>
        </xsl:element>
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
        <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'note'"/>
            <xsl:element name="a" xmlns="http://www.w3.org/1999/xhtml">
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
            </xsl:element>
            <xsl:text>. </xsl:text>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
