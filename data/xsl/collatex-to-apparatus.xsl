<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
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
pipeline. -->
    <xsl:param name="rqs"/>
    <xsl:param name="selected"/>
    <xsl:variable name="queryParams" select="tokenize($rqs, '&amp;')"/>
    <!--<xsl:variable name="sel" select="tokenize($selected, ',')"/>-->
    <xsl:variable name="sel" select="for $p in $queryParams[starts-with(., 'wit=')] return substring-after($p, 'wit=')"/> 
    <xsl:variable name="selList">
        <xsl:copy-of
            select="document('../tei/test-reflist-for-tokenizing.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item[count($sel) = 0 or count(index-of($sel, text())) != 0]"
        />
    </xsl:variable>
    <xsl:variable name="sortlist">
        <xsl:copy-of
            select="document('../tei/test-reflist-for-tokenizing.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item"
        />
    </xsl:variable>
    <xsl:variable name="numb-of-wits">
        <xsl:value-of select="count($sortlist/tei:item)"/>
    </xsl:variable>
    <xsl:variable name="data">
        <xsl:copy-of select="/cx:alignment/cx:row"/>
    </xsl:variable>
    <xsl:variable name="readings-list">
        <xsl:for-each select="$data/cx:row[1]">
            <xsl:for-each select="cx:cell">
                <xsl:variable name="position">
                    <xsl:value-of select="position()"/>
                </xsl:variable>
                <xsl:element name="my:lemma">
                    <xsl:attribute name="position" select="$position"/>
                    <xsl:for-each select="$sortlist/tei:item[count($sel) = 0 or count(index-of($sel, text())) != 0]">
                        <xsl:element name="my:reading">
                            <xsl:variable name="witness">
                                <xsl:value-of select="."/>
                            </xsl:variable>
                            <xsl:variable name="cell">
                                <xsl:value-of
                                    select="$data/cx:row[@sigil=$witness]/cx:cell[position()=$position]"
                                />
                            </xsl:variable>
                            <xsl:attribute name="witness">
                                <xsl:value-of select="$witness"/>
                            </xsl:attribute>
                            <xsl:attribute name="state">
                                <xsl:value-of
                                    select="$data/cx:row[@sigil=$witness]/cx:cell[position()=$position]/@state"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="sort-order" select="position()"/>
                            <xsl:choose>
                                <xsl:when test="$cell/text() = ''">
                                    <xsl:text>–</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$cell/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
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
                <title>Sample Collatex Output</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body xsl:exclude-result-prefixes="#all" dir="rtl">
                <h1>Digital Mishnah Project</h1>
                <h2>Sample Collatex Output</h2>

                <!-- Isn't this just generating an unnecessary heading? -->
                <h2><xsl:value-of select="count($readings-list)"/></h2>
                <h2><xsl:variable name="ref-cit">

                        <xsl:value-of
                            select="document('../tei/test-reflist-for-tokenizing.xml')/tei:TEI/tei:text/tei:body/tei:list/@n"
                        />
                    </xsl:variable>
                    <xsl:variable name="look-up">
                        <xsl:analyze-string select="$ref-cit"
                            regex="^([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                            <xsl:matching-substring>#ref.<xsl:value-of select="regex-group(1)"
                                    />.<xsl:value-of select="regex-group(2)"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:variable name="look-up-text">
                        <xsl:copy-of
                            select="document(normalize-space(concat('../tei/ref.xml',$look-up)),document(''))"
                        />
                    </xsl:variable>
                    <span class="tractate">
                        <xsl:value-of select="translate($look-up-text/*/@n,'_',' ')"/>
                    </span>
                    <xsl:analyze-string select="$ref-cit"
                        regex="^([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                        <xsl:matching-substring><xsl:text> </xsl:text><xsl:value-of
                                select="regex-group(3)"/>:<xsl:value-of select="regex-group(4)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </h2>

             
                <h3>1. Sources to Collate</h3>
                <form name="selection" action="collate" method="get">

                <table class="sources" dir="ltr">
                    <xsl:for-each select="$sortlist/tei:item">
                        <tr>
                            <td>
                          <input type="checkbox" name="wit">
                            <xsl:attribute name="id">
                               <xsl:text>sel</xsl:text><xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                               <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:if test="count($sel) = 0 or count(index-of($sel, .)) != 0">
                              <xsl:attribute name="checked"><xsl:text>checked</xsl:text></xsl:attribute>
                            </xsl:if>
                          </input>
                          <label>
                            <xsl:attribute name="for">
                               <xsl:text>sel</xsl:text><xsl:value-of select="."/>
                            </xsl:attribute>
                            <span class="ref-wit" style="display: inline-block;">
                                <xsl:value-of select="."/>
                            </span>
                            <span class="ref-data" style="display: inline-block;">
                                <xsl:value-of
                                    select="document(concat('../tei/ref.xml','#',.))/text()"/>
                            </span>
                          </label>
                          </td>
                            
                        </tr>
                    </xsl:for-each>
                    <tr></tr>
                    <tr><td><input type="submit" value="Collate"/></td></tr>
                </table>
                </form>
                <h3 dir="ltr">2. Alignment Table Format</h3>
                <p class="descr-text">The alignment table may scroll to the left. Use the scroll bar
                    to see additional columns. </p>
                <div class="alignment-table">
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
                                        <xsl:if
                                            test="./my:reading[@sort-order=$sort-order]/@state =
'variant'">
                                            <xsl:attribute name="class" select="'variant'"/>
                                        </xsl:if>
                                        <xsl:value-of
                                            select="./my:reading[@sort-order=$sort-order]/text()"/>
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
                </div>
                <div class="text" dir="rtl">
                    <h3 dir="ltr">3. Text of <xsl:value-of select="$selList/tei:item[1]"/></h3>
                    <xsl:for-each select="$readings-list/my:lemma/my:reading[@sort-order='1']">
                        <xsl:choose>
                            <xsl:when test=". =
'–'">
                                <!-- skip empty readings (emdash) in base text -->
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- insert text where it exists -->
                                <xsl:value-of select="."/>
                                <xsl:text> </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </div>
                <div class="apparatus" dir="rtl">
                    <h3 dir="ltr">4. Sample Apparatus, Text of <xsl:value-of
                            select="$selList/tei:item[1]"/> as Base Text </h3>
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
readings) for each
witness -->
                                <!-- 3. Then copy the whole to a new variable, to process with
grouping as with the single readings (below) -->
                                <!-- There has got to be a better way of doing this! -->
                                <xsl:variable name="complex-readings-group">
                                    <xsl:for-each
                                        select="$temp-group/my:lemma[1]/my:reading/@sort-order">
                                        <xsl:variable name="sort-order" select="."/>
                                        <xsl:element name="my:complex-reading">
                                            <xsl:attribute name="witness">
                                                <xsl:value-of
                                                  select="$sortlist/tei:item[position()
= $sort-order]"
                                                />
                                            </xsl:attribute>
                                            <xsl:attribute name="sort-order" select="$sort-order"/>
                                            <xsl:attribute name="position"
                                                select="$temp-group/my:lemma[1]/@position"/>
                                            <xsl:for-each select="$temp-group/my:lemma">
                                                <xsl:variable name="position">
                                                  <xsl:value-of select="@position"/>
                                                </xsl:variable>
                                                <xsl:value-of
                                                  select="$temp-group/my:lemma[@position =
$position]/my:reading[@sort-order =
$sort-order]"/>
                                                <xsl:text> </xsl:text>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:for-each>
                                </xsl:variable>
                                <span class="reading-group">
                                    <xsl:for-each-group
                                        select="$complex-readings-group/my:complex-reading"
                                        group-by="text()">
                                        <xsl:choose>
                                            <!-- process base text -->
                                            <xsl:when test="current-grouping-key()">
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="current-group()/self::my:complex-reading[@sort-order='1']">
                                                  <span class="lemma">
                                                  <!-- Check if empty (emdash) and process -->
                                                  <xsl:value-of
                                                  select="normalize-space(translate(self::my:complex-reading[@sort-order='1'],'–
',
' '))"
                                                  />
                                                  </span>
                                                  <span class="matches">
                                                  <xsl:for-each-group select="current-group()"
                                                  group-by="@sort-order">
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
                                                  <xsl:when
                                                  test="normalize-space(translate(current-group()[1],'–',''))
= ''">
                                                  <bdo dir="rtl">–</bdo>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <bdo dir="rtl">
                                                  <xsl:value-of
                                                  select="translate(current-group()[1],'–',
'')"/>
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
                                    <xsl:if
                                        test="count(my:reading[text() = $string]) &lt; $numb-of-wits">
                                        <span class="reading-group">
                                            <xsl:for-each-group select="my:reading"
                                                group-by="text()">
                                                <xsl:choose>
                                                  <xsl:when test="current-grouping-key()">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="current-group()/self::my:reading[@sort-order='1']">
                                                  <span class="lemma">
                                                  <!-- Check if empty (emdash) and process -->
                                                  <xsl:choose>
                                                  <!-- If empty -->
                                                  <xsl:when
                                                  test="self::my:reading[@sort-order='1'] =
'–'">
                                                  <xsl:text>(</xsl:text>
                                                  <xsl:value-of
                                                  select="count(preceding::my:lemma[my:reading[@sort-order
= 1] = '–'])+1"/>
                                                  <xsl:text>) </xsl:text>
                                                  <xsl:value-of
                                                  select="
self::my:reading[@sort-order='1']/@witness"/>
                                                  <xsl:text>
                                                          </xsl:text>
                                                  <xsl:text>ח׳</xsl:text>
                                                  </xsl:when>
                                                  <!-- If not empty -->
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
                                                  <bdo dir="rtl">
                                                  <xsl:value-of select="current-group()[1]"/>
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
            </body>
        </html>
    </xsl:template>
    <xsl:template name="apparatus"> </xsl:template>
    <xsl:template name="string">
        <xsl:param name="sort-order"/>
        <xsl:param name="position"/>
    </xsl:template>
</xsl:stylesheet>
