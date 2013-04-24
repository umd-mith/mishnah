<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its my"
    version="2.0" xmlns:my="local-functions.uri">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" omit-xml-declaration="no" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="alignType" select="/tei:struct/tei:alignType"/>
    <xsl:variable name="mcite" select="/tei:struct/tei:mcite"/>
    <xsl:variable name="unit" select="/tei:struct/tei:unit"/>
    <xsl:variable name="tractName" select="/tei:struct/tei:tractName"/>
    <xsl:variable name="rqs" select="/tei:struct/tei:rqs"/>
    <xsl:variable name="queryParams" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
        <xsl:variable name="params">
            <xsl:call-template name="tokenize-params">
                <xsl:with-param name="src" select="$rqs"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$params/tei:sortWit[@sortOrder != 0]">
            <xsl:sort select="@sortOrder" data-type="number"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="mIndex" select="document(concat('../static/index.xml#ref.',$mcite),document(''))"/>

    <xsl:template match="/">
        <xsl:variable name="chaptNo">
            <xsl:choose>
                <xsl:when test="$unit= 'm' or ($unit = 'ch' and normalize-space($mcite) !='')">
                    <xsl:analyze-string select="$mcite/text()" regex="\d\.\d{{1,2}}\.(\d{{1,2}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mishnNo">
            <xsl:choose>
                <xsl:when test="$unit = 'm' and normalize-space($mcite) !=''">
                    <xsl:analyze-string select="$mcite/text()" regex="\d\.\d{{1,2}}\.(\d{{1,2}}\.\d{{1,2}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:when test="$unit = 'ch'">OK</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="checkIfWits">
            <xsl:value-of select="$queryParams/tei:sortWit/@sortOrder"/>
        </xsl:variable>
        <!--<html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css" href="./css/compare-multi.css" title="Documentary"/>
                <title>Sample Output Collatex Output</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body>
                -->
        <div class="output-container">
            <a name="output"/>
            <div class="hr">
                <hr> </hr>
            </div>
           
            <xsl:choose>
                <xsl:when test="normalize-space($checkIfWits) ='' or $mishnNo = 'null' or $chaptNo ='null' or $alignType=''">
                    <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment"/>Output Will Display Here&#xA0;<span
                            class="link"><a href="#top">[top]</a></span></h3>
                    <p style="text-align:center;">Select Source, Witnesses, and Comparison Type From the Panel Above</p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$alignType= 'synopsis'">
                            <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment"/>Parallel-Column
                                    Synopsis&#xA0;<span class="link"><a href="#top">[top]</a></span></h3>
                            <xsl:choose>
                                <xsl:when test="$unit = 'm'">
                                    <h3><xsl:value-of select="translate($tractName,'_',' ')"/>&#xA0;<xsl:value-of
                                            select="$mishnNo"/></h3>
                                    <xsl:call-template name="build-m-synopsis"/>
                                </xsl:when>
                                <xsl:when test="$alignType = 'synopsis'">
                                    <xsl:choose>
                                        <xsl:when test="$unit= 'ch'">
                                            <h3><xsl:value-of select="translate($tractName,'_',' ')"
                                                    />&#xA0;Chapter&#xA0;<xsl:value-of select="$chaptNo"/></h3>
                                            <xsl:call-template name="build-ch-synopsis"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$alignType = 'align'">
                            <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment"/>Alignment Table, <xsl:value-of
                                    select="translate($tractName,'_',' ')"/>&#xA0;Chapter&#xA0;<xsl:value-of
                                    select="$chaptNo"/>&#xA0;<span class="link"><a href="#top">[top]</a></span></h3>
                            <xsl:apply-templates mode="alignment"/>
                        </xsl:when>
                        <xsl:when test="$alignType = 'apparatus'">
                            <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment"/>Text and Apparatus,
                                    <xsl:value-of select="translate($tractName,'_',' ')"
                                    />&#xA0;Chapter&#xA0;<xsl:value-of select="$chaptNo"/>&#xA0;<span class="link"><a
                                        href="#top">[top]</a></span></h3>
                            <h3 dir="ltr">Text of <xsl:value-of
                                select="/tei:struct/tei:test[1]/*/*/*/*/tei:ab[1]/@n"/>
                                as
                                Base Text </h3>
                            <xsl:apply-templates mode="apparatus"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <!--            </body>
        </html>-->
    </xsl:template>

    <xsl:template name="build-m-synopsis">
        <div class="synopsis" dir="rtl" xmlns="http://www.w3.org/1999/xhtml">
            <table class="synopsis-table" dir="rtl">
                <xsl:variable name="table-width" as="xs:integer" select="count($queryParams/tei:sortWit) * 10"/>
                <xsl:attribute name="style" select="concat('width:',$table-width,'em;')"/>
                <tr>
                    <xsl:for-each select="$queryParams/tei:sortWit">
                        <th class="text-column-head">
                            <xsl:value-of select="."/>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr class="synopsis">
                    <xsl:for-each select="$queryParams/tei:sortWit">
                        <xsl:variable name="currWit" select="text()"/>
                        <td class="text-col">
                            <!-- copy the relevant Mishnah from files, and apply templates. -->
                            <xsl:variable name="thisM"
                                select="document(concat('../tei/',text(),'.xml#',text(),'.',$mcite),document(''))"/>
                            <xsl:apply-templates select="$thisM" mode="synops-cols"/>
                        </td>
                    </xsl:for-each>
                </tr>
            </table>
        </div>
    </xsl:template>
    <xsl:template name="build-ch-synopsis">
        <!-- copy all of witnesses on selected chapter to temporary tree -->
        <xsl:variable name="mExtract">
            <xsl:for-each select="$queryParams/tei:sortWit">
                <xsl:copy-of select="document(concat('../tei/',text(),'.xml#',text(),'.',$mcite),document(''))"/>
            </xsl:for-each>
        </xsl:variable>

        <div class="synopsis" dir="rtl" xmlns="http://www.w3.org/1999/xhtml">
            <table class="synopsis-table" dir="rtl">
                <xsl:variable name="table-width" as="xs:integer" select="count($queryParams/tei:sortWit) * 10"/>
                <xsl:attribute name="style" select="concat('width:',$table-width,'em;')"/>
                <tr><th class="text-col" style="width:3em;"></th>
                    <xsl:for-each select="$queryParams/tei:sortWit">
                        <th class="text-column-head">
                            <xsl:value-of select="."/>
                        </th>
                    </xsl:for-each>
                </tr>
                <tr class="synopsis">
                    <td class="text-col" style="width:3em;height:16pt;"></td>
                    <xsl:for-each select="$queryParams/tei:sortWit">
                        <xsl:variable name="currWit" select="text()"/>
                        <td class="text-col" style="height:16pt;">
                            <xsl:apply-templates select="$mExtract//tei:head[@xml:id =concat($currWit,'.',$mcite,'.H')]"
                                mode="synops-cols"/>
                        </td>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="$mIndex//my:mishnah">
                    <xsl:variable name="currM" select="substring-after(@xml:id, 'ref.')"/>
                    <tr class="synopsis">
                        <td class="text-col" style="width:3em;"><xsl:value-of  select="substring-after(substring-after($currM,'.'),'.')"/></td>
                        <xsl:for-each select="$queryParams/tei:sortWit">
                            <xsl:variable name="currWit" select="text()"/>
                            <td class="text-col">
                                <xsl:apply-templates select="$mExtract//tei:ab[@xml:id =concat($currWit,'.',$currM)]"
                                    mode="synops-cols"/>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
                <tr class="synopsis">
                    <td class="text-col" style="width:3em;height:16pt;">&#160;</td>
                    <xsl:for-each select="$queryParams/tei:sortWit">
                        <xsl:variable name="currWit" select="text()"/>
                        <td class="text-col" style="height:16pt;">
                            <xsl:apply-templates
                                select="$mExtract//tei:trailer[@xml:id =concat($currWit,'.',$mcite,'.T')]"
                                mode="synops-cols"/>
                        </td>
                    </xsl:for-each>
                </tr>

            </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:w" mode="synops-cols">
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="self::text()">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="self::tei:lb">
                    <xsl:choose>
                        <xsl:when test="@n mod 10 = 0">
                            <span class="lb10-intra" xmlns="http://www.w3.org/1999/xhtml"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="lb-intra" xmlns="http://www.w3.org/1999/xhtml"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="self::tei:pb">
                    <span class="{name(.)}">
                        <xsl:value-of select="@xml:id"/>
                    </span>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:label" mode="synops-cols">
        <span class="label" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:del" mode="synops-cols">
        <span class="del" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:add" mode="synops-cols">
        <span class="add" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:cb" mode="synops-cols">
        <span class="cb" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:pb" mode="synops-cols">
        <span class="pb" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:choice" mode="synops-cols">
        <xsl:value-of select="tei:abbr"/>
    </xsl:template>
    <xsl:template match="tei:lb[not(parent::tei:w)]" mode="synops-cols">
        <xsl:choose>
            <xsl:when test="@n mod 10 = 0">
                <span class="lb10" xmlns="http://www.w3.org/1999/xhtml"/>
            </xsl:when>
            <xsl:otherwise>
                <span class="lb" xmlns="http://www.w3.org/1999/xhtml"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:surplus" mode="synops-cols">
        <span class="surplus" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:c | //tei:am | //tei:pc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="//tei:damage" mode="synops-cols">
        <span class="damage" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="synops-cols"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:unclear" mode="synops-cols">
        <span class="unclear" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="synops-cols"/>
        </span>
    </xsl:template>
    <xsl:template match="//tei:note" mode="synops-cols"/>


    <xsl:template match="tei:div" mode="alignment">
        <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment"/>Mishnah <xsl:value-of
                select="substring-after(@n,concat($mcite,'.'))"/></h3>

        <div class="alignment-table" xmlns="http://www.w3.org/1999/xhtml" dir="rtl">
            <table dir="rtl">
                <xsl:for-each select="tei:ab">
                    <tr>
                        <td class="wit">
                            <xsl:value-of select="./@n"/>
                        </td>
                        <xsl:for-each select="./tei:w">
                            <td>
                                <xsl:if test="@type ='variant'">
                                    <xsl:attribute name="class" select="'variant'"/>
                                </xsl:if>
                                <xsl:if test="@type='invariant'">
                                    <xsl:attribute name="class" select="'invariant'"/>
                                </xsl:if>
                                <xsl:variable name="text">
                                    <xsl:value-of select="text()"/>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="normalize-space(translate($text,'[]','')) != ''">
                                        <xsl:value-of select="$text"/>
                                    </xsl:when>
                                    <xsl:when test="normalize-space(translate($text,'[]','')) = ''">
                                        <xsl:text>–</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>
                        <td class="wit">
                            <xsl:value-of select="./@n"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:div" mode="apparatus">
        <h3 class="apparatus" xmlns="http://www.w3.org/1999/xhtml"><a name="apparatus"/>Mishnah <xsl:value-of
                select="substring-after(@n,concat($mcite,'.'))"/></h3>

        <div class="text" dir="rtl">
            <xsl:for-each select="tei:ab[1]/*">
                <xsl:choose>
                    <xsl:when test="self::tei:w and text() != ''">
                        <xsl:choose>
                            <xsl:when test="./tei:seg">
                                <xsl:apply-templates select="tei:seg" mode="within-wd"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- insert text where it exists -->
                                <xsl:sequence select="text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- add space word, but only if not followed by pc -->
                        <xsl:if test="not(following-sibling::element()[1][self::tei:pc])">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::tei:label">
                        <span class="label">
                            <xsl:value-of select="text()"/>
                            <xsl:text> </xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:lb and @n mod 5 = 0">
                        <xsl:text> | </xsl:text>
                        <span class="lb">
                            <xsl:value-of select="@n"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:pb">
                        <xsl:text> ¶ </xsl:text>
                        <span class="page">
                            <xsl:value-of select="@n"/>
                            <xsl:if test="following-sibling::element()[1][self::tei:cb]">
                                <xsl:analyze-string select="following-sibling::tei:cb/@n"
                                    regex="^([0-9]{{1,3}})[rv]([AB])$">
                                    <xsl:matching-substring>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:if>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:cb">
                        <xsl:if test="preceding-sibling::element()[1][not(self::tei:pb)]">
                            <xsl:text> | </xsl:text>
                            <span class="col">
                                <xsl:analyze-string select="@n" regex="^([0-9]{{1,3}}[rv])([AB])$">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </span>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::tei:pc[@type = 'unitEnd']">
                        <xsl:text>: </xsl:text>
                    </xsl:when>
                    <xsl:when test="self::tei:pc[@type = 'stop']">
                        <xsl:text>. </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </div>
        <div class="apparatus" dir="rtl">
            <xsl:variable name="numbWits" select="count(tei:ab)"/>
            <xsl:variable name="wit-list">
                <xsl:for-each select="tei:ab">
                    <xsl:element name="my:sigil" namespace="local-functions.uri">
                        <xsl:value-of select="@n"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="readings-list">
                <xsl:for-each select="tei:ab[1]/tei:w">
                    <xsl:variable name="position" select="count(preceding-sibling::tei:w) + 1"/>
                    <xsl:variable name="by-position">
                        <xsl:element name="tei:readings">
                            <xsl:copy-of select="ancestor::tei:div/tei:ab/tei:w[$position]"/>
                        </xsl:element>
                    </xsl:variable>
                    <my:lemma>
                        <xsl:namespace name="my" select="'local-functions.uri'"/>
                        <xsl:attribute name="position" select="$position"/>
                        <xsl:for-each select="$by-position/tei:readings/tei:w">
                            <xsl:variable name="sort-order" select="position()"/>
                            <my:reading>
                                <xsl:namespace name="my" select="'local-functions.uri'"/>
                                <xsl:attribute name="sort-order" select="$sort-order"/>
                                <xsl:attribute name="witness">
                                    <xsl:value-of select="normalize-space($wit-list/element()[$sort-order])"/>
                                </xsl:attribute>
                                <xsl:attribute name="rdg">
                                    <xsl:variable name="text">
                                        <xsl:value-of select="$by-position/tei:readings/tei:w[$sort-order]/text()"/>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when
                                            test="normalize-space(translate($text,'[]',''))
                                                != ''">
                                            <xsl:value-of select="normalize-space($text)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>–</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:variable name="text-to-put">
                                    <xsl:value-of select="$by-position/tei:readings/tei:w[$sort-order]/tei:reg"/>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when
                                        test="normalize-space(translate($text-to-put,'[]',''))
                                            != ''">
                                        <xsl:value-of select="normalize-space($text-to-put)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>–</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </my:reading>
                        </xsl:for-each>
                    </my:lemma>
                </xsl:for-each>
            </xsl:variable>
            <!-- Check if base text has a missing reading relative to others and group on
this -->
            <xsl:for-each-group select="$readings-list/my:lemma"
                group-adjacent="my:reading[@sort-order = 1] =
                        '–' or following::my:reading[1][@sort-order = 1] = '–'">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:variable name="temp-group">
                            <xsl:copy-of select="current-group()"/>
                        </xsl:variable>
                        <!-- 1. Copy current group to text -->
                        <!-- 2. Process using for each to generate strings of text (complex
                                    readings) for each witness -->
                        <!-- 3. Then copy the whole to a new variable, to process with
                                    grouping as with the single readings (below) -->
                        <!-- There has got to be a better way of doing this! -->
                        <xsl:variable name="complex-readings-group">
                            <xsl:for-each select="$temp-group/my:lemma[1]/my:reading/@sort-order">
                                <xsl:variable name="sort-order" select="."/>
                                <my:complex-reading>
                                    <xsl:namespace name="my" select="'local-functions.uri'"/>
                                    <xsl:attribute name="witness">
                                        <xsl:value-of select="parent::my:reading/@witness"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="sort-order" select="$sort-order"/>
                                    <xsl:attribute name="position" select="$temp-group/my:lemma[1]/@position"/>
                                    <xsl:for-each select="$temp-group/my:lemma">
                                        <xsl:variable name="position">
                                            <xsl:value-of select="@position"/>
                                        </xsl:variable>
                                        <xsl:value-of
                                            select="normalize-space($temp-group/my:lemma[@position =
                                                  $position]/my:reading[@sort-order =
                                                  $sort-order]/@rdg)"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </my:complex-reading>
                            </xsl:for-each>
                        </xsl:variable>
                        <span class="reading-group">
                            <xsl:for-each-group select="$complex-readings-group/my:complex-reading" group-by="text()">
                                <xsl:choose>
                                    <!-- process base text -->
                                    <xsl:when test="current-grouping-key()">
                                        <xsl:choose>
                                            <xsl:when test="current-group()/self::my:complex-reading[@sort-order='1']">
                                                <span class="lemma">
                                                    <!-- Check if empty (emdash) and process -->
                                                    <xsl:value-of
                                                        select="normalize-space(translate(self::my:complex-reading[@sort-order='1']/text(),'–',''))"
                                                    />
                                                </span>
                                                <span class="matches">
                                                    <xsl:for-each-group select="current-group()" group-by="@sort-order">
                                                        <xsl:choose>
                                                            <xsl:when
                                                            test="current-group()/self::my:complex-reading[@sort-order='1']"/>
                                                            <xsl:otherwise>
                                                            <xsl:value-of select="current-group()/@witness"/>
                                                            <xsl:text> </xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:for-each-group>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span class="readings">
                                                    <xsl:choose>
                                                        <xsl:when test="current-group()[1]='–'">
                                                            <bdo dir="rtl">–</bdo>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <bdo dir="rtl">
                                                            <xsl:value-of select="translate(current-group()[1],'–',
'')"
                                                            />
                                                            </bdo>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                <span class="witnesses">
                                                    <xsl:value-of select="current-group()/@witness"/>
                                                    <xsl:text> </xsl:text>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Now process all the "single" readings -->
                        <xsl:for-each select="current-group()">
                            <!-- Condition for processing: all readings are not identical -->
                            <xsl:variable name="string">
                                <xsl:value-of select="./my:reading[1]"/>
                            </xsl:variable>
                            <xsl:if test="count(my:reading[text() = $string]) &lt; $numbWits">
                                <span class="reading-group">
                                    <xsl:for-each-group select="my:reading" group-by="text()">
                                        <xsl:choose>
                                            <xsl:when test="current-grouping-key()">
                                                <xsl:choose>
                                                    <xsl:when test="current-group()/self::my:reading[@sort-order='1']">
                                                        <span class="lemma">
                                                            <!-- Check if empty (emdash) and process -->
                                                            <xsl:choose>
                                                            <!-- If empty -->
                                                            <xsl:when
                                                            test="normalize-space(self::my:reading[@sort-order='1'])
                                                  = ''">
                                                            <xsl:text>(</xsl:text>
                                                            <xsl:value-of
                                                            select="count(preceding::my:lemma[my:reading[@sort-order
                                                  = 1] = ''])+1"/>
                                                            <xsl:text>) </xsl:text>
                                                            <xsl:value-of
                                                            select="self::my:reading[@sort-order='1']/@witness"/>
                                                            <xsl:text>
                                                          </xsl:text>
                                                            <xsl:text>ח׳</xsl:text>
                                                            </xsl:when>
                                                            <!-- If not empty -->
                                                            <xsl:otherwise>
                                                            <xsl:value-of
                                                            select="self::my:reading[@sort-order='1']/@rdg"/>
                                                            </xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                        <span class="matches">
                                                            <xsl:for-each-group select="current-group()"
                                                            group-by="@sort-order">
                                                            <xsl:choose>
                                                            <xsl:when
                                                            test="current-group()/self::my:reading[@sort-order='1']/text()"/>
                                                            <xsl:otherwise>
                                                            <xsl:value-of select="current-group()/@witness"/>
                                                            <xsl:text> </xsl:text>
                                                            </xsl:otherwise>
                                                            </xsl:choose>
                                                            </xsl:for-each-group>
                                                        </span>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <span class="readings">
                                                            <bdo dir="rtl">
                                                            <xsl:value-of select="current-group()[1]/@rdg"/>
                                                            </bdo>
                                                        </span>
                                                        <span class="witnesses">
                                                            <xsl:value-of select="current-group()/@witness"/>
                                                            <xsl:text> </xsl:text>
                                                        </span>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:for-each-group>
                                </span>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    <xsl:template match="tei:teiHeader | tei:alignType | tei:unit | tei:mcite | tei:tractName | tei:rqs" mode="#all"/>

    <xsl:template name="tokenize-params">
        <!-- revise me -->
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,'&amp;')">
                <!-- build first token element -->
                <xsl:if test="not(contains(substring-before($src,'&amp;'),'mcite'))">
                    <tei:sortWit xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="sortOrder">
                            <xsl:choose>
                                <xsl:when
                                    test="substring-after(substring-before($src,'&amp;'),'=')
                                    =''">
                                    <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring-after(substring-before($src,'&amp;'),'=')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="substring-before(substring-before($src,'&amp;'),'=')"/>
                    </tei:sortWit>
                </xsl:if>
                <!-- recurse -->
                <xsl:call-template name="tokenize-params">
                    <xsl:with-param name="src" select="substring-after($src,'&amp;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <tei:sortWit xpath-default-namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="sortOrder">
                        <xsl:choose>
                            <xsl:when test="substring-after($src,'=')
                                =''">
                                <xsl:value-of select="0"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after($src,'=')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before($src,'=')"/>
                </tei:sortWit>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
