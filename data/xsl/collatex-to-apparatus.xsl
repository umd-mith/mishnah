<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:my="local-functions.uri"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd cx tei my" version="2.0">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 8, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- xslt transformation of output from collatex demo for automated transformation in Cocoon
        pipeline.  -->
    <xsl:variable name="sortlist">
        <xsl:copy-of
            select="document('../tei/test-reflist-for-tokenizing.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item"
        />
    </xsl:variable>
    <xsl:variable name="numb-of-wits">
        <xsl:value-of select="count($sortlist/tei:item)"/>
    </xsl:variable>
    <xsl:variable name="data">
        <xsl:copy-of select="cx:alignment/cx:row"/>
    </xsl:variable>
    <xsl:variable name="readings-list">
        <xsl:for-each select="$data/cx:row[1]">
            <xsl:for-each select="cx:cell">
                <xsl:variable name="position">
                    <xsl:value-of select="position()"/>
                </xsl:variable>
                <xsl:element name="my:lemma">
                    <xsl:attribute name="position" select="$position"/>
                    <xsl:for-each select="$sortlist/tei:item">
                        <xsl:element name="my:reading">
                            <xsl:variable name="witness">
                                <xsl:value-of select="."/>
                            </xsl:variable>
                            <xsl:attribute name="witness">
                                <xsl:value-of select="$witness"/>
                            </xsl:attribute>
                            <xsl:attribute name="sort-order" select="position()"/>
                            <xsl:for-each select="$data/cx:row[@sigil=$witness]">
                                <!-- If empty insert emdash as null token -->
                                <xsl:if test="./cx:cell[position()=$position] = ''">
                                    <xsl:text>–</xsl:text>
                                </xsl:if>
                                <!-- else, if not empty, insert token -->
                                <xsl:if
                                    test="./cx:cell[position()=$position]
                                    != ''">
                                    <xsl:value-of select="./cx:cell[position()=$position]"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/CollatexOutput.css"
                    title="Documentary"/>
                <title>Sample Output Collatex Output</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body xsl:exclude-result-prefixes="#all" dir="rtl">
                <h1>Digital Mishnah Project</h1>
                <h2 dir="ltr">1. Sample Collatex Output, Alignment Table Format</h2>
                <table dir="rtl">
                    <xsl:for-each select="$readings-list/my:lemma[1]/my:reading/@sort-order">
                        <xsl:variable name="sort-order">
                            <xsl:value-of select="."/>
                        </xsl:variable>
                        <tr>
                            <td class="wit">
                                <xsl:value-of
                                    select="$readings-list/my:lemma[1]/my:reading[@sort-order = $sort-order]/@witness"
                                />
                            </td>
                            <xsl:for-each select="$readings-list/my:lemma">
                                <td>
                                    <xsl:value-of select="./my:reading[@sort-order=$sort-order]"/>
                                </td>
                            </xsl:for-each>
                            <td class="wit">
                                <xsl:value-of
                                    select="$readings-list/my:lemma[1]/my:reading[@sort-order = $sort-order]/@witness"
                                />
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <div class="text" dir="rtl">
                    <h2 dir="ltr">2. Text of <xsl:value-of select="$sortlist/tei:item[1]"/></h2>
                    <xsl:for-each select="$readings-list/my:lemma/my:reading[./@sort-order='1']">
                        <xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </div>
                <div class="apparatus" dir="rtl">
                    <h2 dir="ltr">3. Sample Apparatus, Text of <xsl:value-of
                            select="$sortlist/tei:item[1]"/> as Base Text </h2>
                    <xsl:for-each select="$readings-list/my:lemma">
                        <!-- Condition for processing: all readings are not identical -->
                        <xsl:variable name="string">
                            <xsl:value-of select="my:reading[1]"/>
                        </xsl:variable>
                        <xsl:if test="count(my:reading[text() = $string]) &lt; $numb-of-wits">
                            <span class="reading-group">
                                <xsl:for-each-group select="my:reading" group-by="text()">
                                    <xsl:choose>
                                        <xsl:when test="current-grouping-key()">
                                            <xsl:choose>
                                                
                                                <xsl:when
                                                  test="current-group()/self::my:reading[@sort-order='1']">
                                                  <span class="lemma">
                                                  <xsl:choose>
                                                 
                                                  <xsl:when
                                                  test="self::my:reading[@sort-order='1'] =
                                                          '–'">
                                                  <xsl:value-of
                                                  select="self::my:reading[@sort-order='1']/@witness"/>
                                                  <xsl:text>:
                                                              ח׳</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="self::my:reading[@sort-order='1']"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </span>
                                                  <span class="matches">
                                                  <xsl:for-each-group select="current-group()"
                                                  group-by="@sort-order">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="current-group()/self::my:reading[@sort-order='1']"/>
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
                                                  <xsl:value-of select="current-group()[1]"/>
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
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="apparatus"> </xsl:template>
</xsl:stylesheet>
