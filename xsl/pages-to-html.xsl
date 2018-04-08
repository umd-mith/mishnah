<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:my="http://http://dev.digitalmishnah.org/local-functions.uri" xmlns:local="local-functions.uri" exclude-result-prefixes="xd xs its local my tei" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:strip-space elements=" tei:choice and tei:am and         tei:gap and xs:comment and tei:orig and tei:reg and tei:unclear and tei:damage and tei:gap         tei:del tei:add"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jul 23, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc><!-- Need to run flattening stylsheet then unflattentopages --><!--Updated transformations to result in valid TEI in xml output and valid HTML in html output --><!--<xsl:param name="rqs">ch=4.2.10&pg=163r&col=163rA&mode=col</xsl:param>-->
    <xsl:param name="num"/>
    <xsl:param name="mode"/>
    <xsl:param name="tei-loc"/>
    <xsl:variable name="wit" select="//tei:TEI/tei:teiHeader//tei:publicationStmt/tei:idno[@type='local']/text()"/>
    <xsl:variable name="sourceDoc" select="document(concat($tei-loc, $wit,'.xml'))"/>
    <xsl:variable name="thisId"><!-- locates first, last, next, prev for processing links -->
        <xsl:choose>
            <xsl:when test="$mode='page'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$num))"/>
            </xsl:when>
            <xsl:when test="$mode='column'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$num))"/>
            </xsl:when>
            <xsl:when test="$mode='chapter'">
                <xsl:value-of select="normalize-space(concat($wit,'.',$num))"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable xmlns="http://www.tei-c.org/ns/1.0" name="thisPgColCh">
        <xsl:variable name="thisElement">
            <xsl:copy-of select="$sourceDoc//*[@xml:id=$thisId]"/>
        </xsl:variable>
        <xsl:variable name="name" select="$thisElement/element()/name()"/>
        <xsl:variable name="id" select="$thisElement/element()/@xml:id"/>
        <this>
            <xsl:value-of select="$id"/>
        </this>
        <first>
            <xsl:choose>
                <xsl:when test="$sourceDoc/*/*//*/preceding::element()[name()=$name]">
                    <xsl:value-of select="(($sourceDoc/*/*//*)[name()=$name])[1]/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </first>
        <last>
            <xsl:choose>
                <xsl:when test="$sourceDoc/*/*//*/following::element()[name()=$name]">
                    <xsl:value-of select="(($sourceDoc/*/*//*)[name()=$name])[last()]/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </last>
        <prev>
            <xsl:choose>
                <xsl:when test="($sourceDoc/*/*//*)[@xml:id=$id]/preceding::element()[name()=$name][1]">
                    <xsl:value-of select="($sourceDoc/*/*//*)[@xml:id=$id]/preceding::element()[name()=$name][1]/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </prev>
        <next>
            <xsl:choose>
                <xsl:when test="($sourceDoc/*/*//*)[@xml:id=$id]/following::element()[name()=$name][1]">
                    <xsl:value-of select="(($sourceDoc/*/*//*)[@xml:id=$id]/following::element()[name()=$name])[1]/@xml:id"/>
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
    <xsl:template match="//tei:anchor | //tei:damageSpan |         tei:milestone[@unit='MSMishnah'] | tei:milestone[@unit='fragment']"/><!-- for now ignoring fw for running heads etc. -->
    <xsl:template match="//tei:fw"/><!-- for now, removing num markup. May need to be restored. -->
    <xsl:template match="//tei:num">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:w">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:ab">
        <xsl:choose>
            <xsl:when test="$mode='chapter'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'mishnah-ch'"/>
                    <xsl:analyze-string select="@xml:id" regex="^([^\.]+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
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
        <div xsl:exclude-result-prefixes="tei" dir="rtl" class="row"><!--<xsl:attribute name="title">
                <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title" exclude-result-prefixes="#all"/>
            </xsl:attribute>-->
            <nav class="navbar navbar-default" role="navigation">
                <div class="container-fluid">
                    <div class="navbar-brand">Browse by</div>
                    <ul class="nav navbar-nav">
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Page <span class="caret"/>
                            </a>
                            <ul class="dropdown-menu scrollable-menu">
                                <xsl:for-each select="$sourceDoc//tei:pb">
                                    <li class="dropdown">
                                        <xsl:if test="$thisPgColCh/tei:this = @xml:id or not($mode = 'page') and  @xml:id = $sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:pb[1]/@xml:id">
                                            <xsl:attribute name="class" select="'active'"/>
                                        </xsl:if>
                                        <a href="../page/{substring-after(@xml:id,concat($wit,'.'))}">
                                            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </li>
                        <li>
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Column <span class="caret"/>
                            </a>
                            <ul class="dropdown-menu scrollable-menu">
                                <xsl:for-each select="$sourceDoc//tei:div3">
                                    <li>
                                        <xsl:variable name="isFirst" as="xs:boolean" select="not(preceding::tei:div3)"/>
                                        <xsl:if test="$thisPgColCh/tei:this = @xml:id or not($mode = 'chapter') and (                                         @xml:id = $sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3/@xml:id                                         or (not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3) and                                             @xml:id = $sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/following::tei:div3[1]/@xml:id)                                         or ($isFirst                                              and not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3)                                             and not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:div3))                                         )">
                                            <xsl:attribute name="class" select="'active'"/>
                                        </xsl:if>
                                        <a href="../chapter/{substring-after(@xml:id,concat($wit,'.'))}">
                                            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </li>
                        <li>
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Chapter <span class="caret"/>
                            </a>
                            <ul class="dropdown-menu scrollable-menu">
                                <xsl:for-each select="$sourceDoc//tei:div3">
                                    <li>
                                        <xsl:variable name="isFirst" as="xs:boolean" select="not(preceding::tei:div3)"/>
                                        <xsl:if test="$thisPgColCh/tei:this = @xml:id or not($mode = 'chapter') and (                                         @xml:id = $sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3/@xml:id                                         or (not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3) and                                             @xml:id = $sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/following::tei:div3[1]/@xml:id)                                         or ($isFirst                                              and not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/ancestor::tei:div3)                                             and not($sourceDoc//element()[@xml:id=$thisPgColCh/tei:this]/preceding::tei:div3))                                         )">
                                            <xsl:attribute name="class" select="'active'"/>
                                        </xsl:if>
                                        <a href="../chapter/{substring-after(@xml:id,concat($wit,'.'))}">
                                            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </li>
                    </ul>
                    <ul class="nav navbar-nav navbar-right">
                        <div class="btn-group" role="group">
                            <xsl:choose>
                                <xsl:when test="$thisPgColCh/tei:this = $thisPgColCh/tei:last">
                                    <a class="btn btn-default btn-last" disabled="disabled" type="button">Last &gt;|</a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a class="btn btn-default btn-last" type="button" href="{substring-after($thisPgColCh/tei:last,concat($wit,'.'))}">Last &gt;|</a>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$thisPgColCh/tei:next='null'">
                                    <a class="btn btn-default btn-next" disabled="disabled" type="button">Next &gt;&gt;</a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a class="btn btn-default btn-next" type="button" href="{substring-after($thisPgColCh/tei:next,concat($wit,'.'))}">Next &gt;&gt;</a>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$thisPgColCh/tei:prev='null'">
                                    <a class="btn btn-default btn-previous" disabled="disabled" type="button">&lt;&lt; Previous</a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a class="btn btn-default btn-previous" type="button" href="{substring-after($thisPgColCh/tei:prev,concat($wit,'.'))}">&lt;&lt; Previous</a>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$thisPgColCh/tei:this = $thisPgColCh/tei:first">
                                    <a class="btn btn-default btn-first" disabled="disabled" type="button">First &lt;|</a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a class="btn btn-default btn-first" type="button" href="{substring-after($thisPgColCh/tei:first,concat($wit,'.'))}">First  &lt;|</a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </ul>
                </div>
            </nav>
            <div class="row" dir="ltr">
                <xsl:variable name="nli" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:note[@type= 'nli-ref']"/>
                <table class="table">
                    <tr>
                        <th>Repository</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository"/>
                            <xsl:text>
                            (</xsl:text>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement"/>
                            <xsl:text>) </xsl:text>
                        </td>
                        <th>Dimensions:</th>
                        <td/>
                    </tr>
                    <tr>
                        <th>Id no.</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno"/>
                        </td>
                        <td>Sheet</td>
                        <th>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='sheet']/tei:height"/>
                            <xsl:text>
                                × </xsl:text>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='sheet']/tei:width"/> cm</th>
                    </tr>
                    <tr>
                        <th>Hand</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/@script"/>
                            <xsl:choose>
                                <xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]">
                                    <xsl:text>; </xsl:text>
                                    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]/text()"/> <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'pointed')]/tei:desc"/>
                                    <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc//tei:desc[contains(.,'pointed')]/ancestor-or-self::tei:handNote/@scribe                                     != 'first'"> (not by primary scribe)</xsl:if>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]">
                                    <xsl:text>; </xsl:text>
                                    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]/text()"/> <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:desc[contains(.,'cantillation')]/tei:desc"/>
                                    <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc//tei:desc[contains(.,cantillation)]/ancestor-or-self::tei:handNote/@scribe                                        != 'first'"> (not by primary scribe)</xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </td>
                        <th>Written Column</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-cm']/tei:height"/>
                            <xsl:text>
                                × </xsl:text>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-cm']/tei:width"/> cm</td>
                    </tr>
                    <tr>
                        <th>Date</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/tei:date"/>
                        </td>
                        <th>Lines per column</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:height"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Region</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote[1]/tei:region"/>
                        </td>
                        <th>Characters/line</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:width"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Format</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/@form"/>
                        </td>
                        <th>Characters/cm</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:dimensions[@scope='col-writ']/tei:dim[@type='char-p-cm']"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Material</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/@material"/>
                        </td>
                        <th/>
                        <td/>
                    </tr>
                    <tr>
                        <th>Extent</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:extent"/>
                            leaves </td>
                        <th>Contributions:</th>
                        <td/>
                    </tr>
                    <tr>
                        <th>Columns</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@columns"/>
                        </td>
                        <th>Transcription</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[./tei:resp/text()='transcriber']/tei:persName"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Scribe</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:persName" separator="; "/>
                        </td>
                        <th>Markup</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[./tei:resp/text()='markup']/tei:persName"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Place of copying</th>
                        <td>
                            <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:placeName" separator="; "/>
                        </td>
                        <th>
                            <xsl:if test="normalize-space($nli)">
                                <a href="{$nli}">NLI Catalog</a>
                            </xsl:if>
                        </th>
                        <td/>
                    </tr>
                </table>
            </div>
            <div class="row">
                <h3 dir="ltr">Transcription</h3>
                <div dir="rtl">
                    <xsl:apply-templates select="//tei:text"/>
                </div><!--<div xmlns="http://www.w3.org/1999/xhtml" class="hr">
                    <hr/>
                </div>-->
            </div>
            <div class="row" dir="ltr">
                <h3>Notes</h3>
                <xsl:if test="count(//tei:note[ancestor::tei:body]) = 0">
                    <p class="empty">There are no notes available.</p>
                </xsl:if>
                <xsl:apply-templates select="//tei:note[ancestor::tei:body]" mode="notes"/>
            </div>
        </div><!--</body>
        </html>-->
    </xsl:template>
    <xsl:template match="tei:body |tei:text | tei:c | tei:g | //tei:pc |tei:c | tei:am">
        <xsl:apply-templates/>
    </xsl:template><!-- remove the temporary supplied text -->
    <xsl:template match="tei:supplied"/><!-- Hide in CSS. Eventually, extract order name and tractate name from id. -->
    <xsl:template match="tei:milestone[@unit='Order' or @unit='div1']">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class">ord</xsl:attribute> Order <xsl:value-of select="./@xml:id"/>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Tractate' or @unit='div2']">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class">tr</xsl:attribute> Tractate <xsl:value-of select="./@xml:id"/>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:milestone[@unit='Chapter' or @unit='div3']">
        <xsl:variable name="ref">
            <xsl:value-of select="./@xml:id"/>
        </xsl:variable>
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class">chapter</xsl:attribute>
            <xsl:analyze-string select="$ref" regex="^P_([^\.]+)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
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
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class">mishnah</xsl:attribute>
            <xsl:analyze-string select="$ref" regex="^([^\.]+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(5)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb[@n]">
        <xsl:choose>
            <xsl:when test="$mode='chapter'"><!-- in compact ch mode mark major and minor line numbers, here set at 5 and 10 lines -->
                <xsl:choose>
                    <xsl:when test="(@n + 1) mod 5 = 0 and (@n +1) mod 2 = 1">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-ch-min</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-min-marker</xsl:attribute>  </xsl:element>
                    </xsl:when>
                    <xsl:when test="(@n + 1) mod 5 = 0 and (@n +1) mod 2 = 0">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-ch-maj</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class">lb-maj-marker</xsl:attribute>  </xsl:element>
                    </xsl:when>
                    <xsl:otherwise><!-- do nothing --></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="(./@n + 1) mod 5 = 0">
                        <br xmlns="http://www.w3.org/1999/xhtml">  </br>
                        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                            <xsl:attribute name="class">lb</xsl:attribute>
                            <xsl:value-of select="(./@n + 1)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <br xmlns="http://www.w3.org/1999/xhtml">  </br>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:space"><!-- in page or col view --><!-- needs to be redone for @unit='lines' -->
        <xsl:choose>
            <xsl:when test="not($mode='chapter')">
                <xsl:call-template name="add-char">
                    <xsl:with-param name="howMany" select="./@extent"/>
                    <xsl:with-param name="char" select="' '"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><!-- ignore --></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:gap">
        <xsl:choose>
            <xsl:when test="@reason='Maimonides' or @reason='Bavli' or @reason='Yerushalmi' "><!-- no not process if in ch mode -->
                <xsl:choose>
                    <xsl:when test="$mode='chapter'">
                        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:attribute name="class" select="'skipped'"/>
                            <xsl:value-of select="@extent"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="not($mode = 'chapter')">
                        <xsl:if test="./@unit='chars'">
                            <xsl:call-template name="add-char">
                                <xsl:with-param name="howMany" select="./@extent"/>
                                <xsl:with-param name="char" select="' '"/>
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
                    <xsl:when test="not($mode='chapter')">
                        <xsl:choose><!-- NB: Need to fix last <gap> of div --><!--  --><!-- Temporary transformation, for files still containing <supplied> -->
                            <xsl:when test="./following-sibling::*[1]/self::tei:supplied">
                                <xsl:for-each select="./following-sibling::*[1]/self::tei:supplied">
                                    <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                        <xsl:attribute name="class">supplied</xsl:attribute>
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:when><!-- the other handlings of tei:gap --><!-- These use cases needs fixing --><!-- will need to be altered when change coding of damage -->
                            <xsl:when test="preceding::*[1]/self::tei:lb and                         not(preceding::node()[1]/text()|tei:unclear)">
                                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                    <xsl:attribute name="class" select="'missing'"/>
                                    <xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="' '"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:when>
                            <xsl:when test="following::*[1]/self::tei:lb and                         not(following::node()[1]/text()|tei:unclear)">
                                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                    <xsl:attribute name="class" select="'missing'"/>[<xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="' '"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="following::tei:lb[1]/@n='1' and not(preceding::node()[1]/text())">
                                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                    <xsl:attribute name="class" select="'missing'"/>
                                    <xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="' '"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                    <xsl:attribute name="class" select="'missing'"/>[<xsl:call-template name="add-char">
                                        <xsl:with-param name="howMany" select="./@extent"/>
                                        <xsl:with-param name="char" select="' '"/>
                                    </xsl:call-template>]</xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$mode='chapter'">
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
        <div xmlns="http://www.w3.org/1999/xhtml" class="page">
            <xsl:choose>
                <xsl:when test="not(descendant::tei:div[@type='column'])"><!-- there are not multiple comlumns in this view -->
                    <xsl:choose>
                        <xsl:when test="not(descendant::tei:div[@type='singCol'])"><!-- when original laid out in a single column -->
                            <div class="oneCol">
                                <xsl:element name="span">
                                    <xsl:attribute name="class" select="'pageNo'"/>Folio <xsl:value-of select="./@n"/>
                                </xsl:element>
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
                                </xsl:if>
                                <xsl:apply-templates/>
                            </div>
                        </xsl:when>
                        <xsl:when test="descendant::tei:div[@type='singCol']"><!-- A multi-column original presented in single column view -->
                            <xsl:element name="span">
                                <xsl:attribute name="class" select="'pageNo'"/>Folio <xsl:value-of select="./@n"/>
                            </xsl:element>
                            <xsl:apply-templates/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="descendant::tei:div[@type='column']"><!-- there are multiple columns in this view -->
                    <xsl:apply-templates/>
                </xsl:when>
            </xsl:choose>
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
                <xsl:element name="span">
                    <xsl:attribute name="class" select="'pageNo'"/>folio <xsl:value-of select="./ancestor::tei:div[@type='page']/@n"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="span">
                <xsl:attribute name="class" select="'colNo'"/>
                <xsl:value-of select="./@n"/>
            </xsl:element>
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
    <xsl:template match="tei:div[@type='singCol']"><!-- browsing in single column view --><!-- CSS for column A will apply throughout -->
        <xsl:variable name="col">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">columnA</xsl:attribute>
            <xsl:element name="span">
                <xsl:attribute name="class" select="'colNo'"/>
                <xsl:value-of select="./@n"/>
            </xsl:element>
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
                    <xsl:analyze-string select="@n" regex="^([^\.]+)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(4)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:element>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template><!-- PB and CB only exist in ch mode -->
    <xsl:template match="tei:pb">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">pageNo-ch</xsl:attribute>
            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
        </xsl:element>
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">pageNo-ch-marker</xsl:attribute>  </xsl:element>
    </xsl:template>
    <xsl:template match="tei:cb">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">colNo-ch</xsl:attribute>
            <xsl:value-of select="substring-after(@xml:id,concat($wit,'.'))"/>
        </xsl:element>
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">colNo-ch-marker</xsl:attribute>  </xsl:element>
    </xsl:template>
    <xsl:template match="tei:surplus">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
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
            <xsl:when test="$mode='chapter'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'add'"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise><!-- next stage to fix: want to allow margin-right margin left, etc -->
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'add'"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:del">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'del'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:metamark[@function='transposition']">
        <xsl:choose>
            <xsl:when test="string-length(.)=0"><!-- For now do nothing. At some point refine handling of this --></xsl:when>
            <xsl:when test="string-length(.) &gt; 0">
                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                    <xsl:attribute name="class" select="'metamark'"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:listTranspose"><!-- For now, skip this element. --></xsl:template>
    <xsl:template match="tei:quote">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'quote'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'bibQuote'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:sic">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'sic'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:corr">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'corr'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template><!-- Process <damage> -->
    <xsl:template match="tei:unclear">
        <xsl:choose>
            <xsl:when test="not($mode='chapter')"><!-- In page and col mode --><!-- Represent unclear text as periods using extent--><!-- When text is present in <unclear> add difference between @extent and
            the number of characters present in the form of dots-->
                <xsl:variable name="adj-length"><!-- Removes spaces and geresh from string length -->
                    <xsl:value-of select="number(string-length(translate(normalize-space(.),'2׳                 ','')))"/>
                </xsl:variable>
                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                    <xsl:attribute name="class" select="'unclear'"/><!-- replacement string of thin-space/period/thin-space -->
                    <xsl:variable name="dots" as="xs:string">
                        <xsl:text> . </xsl:text>
                    </xsl:variable>
                    <xsl:choose><!-- converts node to text  and replaces ? with dots. Assumes that will not be
                        retaining child nodes of unclear. This may change.  -->
                        <xsl:when test="string(.)">
                            <xsl:value-of select="normalize-space(replace(. except tei:note,'\?',$dots))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="number(./@extent) - $adj-length &lt;= 0"><!-- If traces = extent then do not add dots --></xsl:when>
                        <xsl:when test="number(./@extent) - $adj-length &gt; 0"><!-- add dots -->
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
            </xsl:when><!-- in compact ch mode -->
            <xsl:when test="$mode='chapter'">
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
    <xsl:template match="tei:damage"><!-- based on a sample template at: http://www.w3.org/TR/xslt20/#grouping-examples -->
        <xsl:for-each-group select="node()" group-adjacent="self::tei:unclear or self::tei:gap">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates select="current-group()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
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
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'pointed'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:reg">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'unpointed'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:expan">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'expan'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:abbr">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'abbr'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:persName"><!-- ignore for now --><!--<xsl:element name="span" xmlns="http://www.w3.org/1999/xhtml"><xsl:attribute name="class" select="'persName'"/>
            <xsl:apply-templates/>
        </xsl:element>--></xsl:template>
    <xsl:template match="//tei:trailer">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'label'"/>
            <xsl:choose>
                <xsl:when test="not(string(.))">
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise> </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="//tei:label">
        <xsl:choose><!-- pg and col mode -->
            <xsl:when test="not($mode='chapter')">
                <xsl:choose>
                    <xsl:when test=".[contains(@rend,'margin-right')]">
                        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                            <xsl:attribute name="class" select="'marg-label-r'"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="not(string(.))and not(node())"> </xsl:when>
                            <xsl:otherwise>
                                <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
                                    <xsl:attribute name="class" select="'label'"/>
                                    <xsl:apply-templates select="node()"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode='chapter'">
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class" select="'label-ch'"/>
                    <xsl:choose>
                        <xsl:when test="not(string(.))and not(node())"> </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="//tei:head">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="span">
            <xsl:attribute name="class" select="'label'"/>
            <xsl:choose>
                <xsl:when test="not(string(.))"> </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*"/> 
                </xsl:otherwise>
            </xsl:choose>
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
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="a">
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$href"/>
            </xsl:attribute>
            <xsl:element name="span">
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
            <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="a">
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
                        <xsl:when test="contains(ancestor::tei:div[@type='column']/@n, 'A')">A</xsl:when>
                        <xsl:when test="contains(ancestor::tei:div[@type='column']/@n, 'B')">B</xsl:when>
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