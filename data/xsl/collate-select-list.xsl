<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="html" indent="yes" encoding="UTF-8"
        omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- Receives from a pipeline a list of chapters and/or mishnayot that have text in the database, and the witnesses that are represented-->
    <!-- Parameters-->
    <xsl:param name="unit" select="'ch'">
        <!-- Whether collating by Mishnah (m) or Chapter (ch) -->
        <!-- When the value is "all we populate an inactive selection list -->
    </xsl:param>
    <xsl:param name="mcite" select="'4.2.2.3'">
        <!-- The selected Mishnah or Chapter -->
    </xsl:param>
    <xsl:param name="tractName" select="'Bava_Metsia'">
        <!-- Tractate Name, passed from drowpdown. This seems faster but less elegant than looking up the name from ref.xml. -->
    </xsl:param>
    <xsl:param name="rqs"
        select="'Kauf=1&amp;ParmA=&amp;Camb=&amp;S00651=&amp;S08174=5&amp;P00001=&amp;Vilna=&amp;Mun=&amp;Hamb=&amp;Vat115=&amp;Vat117=&amp;Leid=&amp;S03524=4&amp;S04589=3&amp;S01715=2'">
        <!-- String of witnesses requested -->
    </xsl:param>
    <xsl:param name="alignType" select="'apparatus'">
        <!-- type of alignment requested in form -->
    </xsl:param>
    <xsl:variable name="witsWithText" xmlns="local-functions.uri">
        <xsl:choose>
            <xsl:when test="$unit='ch'">
                <xsl:copy-of select="//my:ch-compos"/>
            </xsl:when>
            <xsl:when test="$unit='m'">
                <xsl:copy-of select="//my:m-active-compos"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fieldVals">
        <xsl:call-template name="tokenizeRqs">
            <xsl:with-param name="text" select="$rqs"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:template match="/">
        <div class="about" stye="clear:both" style="width:75%;direction:ltr" xmlns="http://www.w3.org/1999/xhtml">
                    <h2>Compare Witnesses
                        <span class="tractate">
                            <xsl:value-of select="replace($tractName,'_',' ')"/>
                        </span>
                        <xsl:analyze-string select="$mcite" regex="\d\.\d\.(.*)">
                            <xsl:matching-substring>
                                <xsl:text> </xsl:text><xsl:value-of select="regex-group(1)"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </h2>
            <div id="shown">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">About this Page</a>
                </p>
            </div>
            <div id="hidden" style="display:none;">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
                <p>This page allows users to select passages to compare witnesses. As the texts in the database expand functionalities will as well.</p> <p >Use the dropdown menu on the left to select passages. All passages where the database currently have text have active links. Bava Metsia (fourth order, second tractate), Chapter 2 has the most encoded witnesses, and is a good place for exploring the functions of the site.</p><p>After selecting witnesses, the selection list in the middle area will refresh with only those witnesses that have text for the selected passage, and the input fields and buttons will be active. Select a witness by entering a <hi style="font-weight:bold; text-style:italic;">numeral</hi> in the input field. This allows the user to choose the order that the witnesses are presented in output.</p><p>Use the buttons in the righthand area to specify whether comparison is done by chapter ("div3" in TEI speak) or mishnah ("ab") and the type of output requested.</p><p>Output types are as follows: 
                    <ul><li><hi style="font-weight:bold; text-style:italic;">Alignment table</hi>, in which each each witness is presented horizontally, and each token (word) is aligned with its corresponding element in the other witnesses. Alignment is done using <a
                        href="http://www.collatex.net/">CollateX</a>.</li>
                        <li><hi style="font-weight:bold; text-style:italic;">Text with Apparatus</hi>. The witness selected with the lowest selection number (typically 1) is the default base text. The apparatus coordinates the alignment output from CollateX to the base text.</li>
                        <li><hi style="font-weight:bold; text-style:italic;">Parallel-Column Synopsis</hi>. Using the order from the selection list, this section of the output page presents the selected text in parallel columns.</li></ul></p><p>This is a demo. Much work remains to be done, especially on processing fragmentary texts, and feedback is requested.</p>
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
            </div>
            
                </div>
                <div class="selectionList">

                    <form action="compare" method="get">
                        <div class="formDescr">
                            <h3>Select Witnesses<a class="tooltip">[?]<span class="help"><em>Select Witnesses</em>Use numerals, starting with 1, in the input fields to select witnesses. This will determine the order of output. In "Text/Apparatus" mode the text labeled "1" will be the base text.</span></a></h3>
                            <!-- following is a fudge to get parameters into form output. 
                                Has got to be a less devious way of doing this. -->
                            <input type="text" name="mcite" value="{$mcite}"
                                style="display:none;"/>
                            <input type="text" name="unit" value="{$unit}"
                                style="display:none;"/>
                            <input type="text" name="tractName"
                                value="{$tractName}" style="display:none;"/>
                        </div>

                       
                        <div class="tableContainer"><table class="selectionTable">
                            <xsl:choose>
                                <xsl:when test="$unit='all' or $unit = ''">
                                    <xsl:apply-templates mode="noSelected"/>
                                </xsl:when>
                                <xsl:otherwise>

                                    <xsl:apply-templates mode="selected"/>

                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                        </div>
                        <div class="buttons">
                            <xsl:call-template name="buttons"/>
                        </div>
                    </form>
</div>
    </xsl:template>
    <!-- named template "buttons" creates buttons for the form; and determines whether they are enabled based on $unit -->
    <xsl:template name="buttons">
        <xsl:choose>
            <xsl:when test="$unit = 'all' or $unit = ''">
                <div class="submit">
                    <input class="submit" type="submit" value="Collate"
                        disabled="disabled"/>
                    <!--<br> </br>
                    <input id="reset" class="submit" type="reset" value="Reset"
                        disabled="disabled"/>
                    Reason for deletion: see below where button would be active -->
                </div>
                <div class="radio">
                    <span><input id="align" class="radio" type="radio"
                        disabled="disabled" name="alignType"/>
                    <label for="align">Alignment</label></span>
                    <span><input id="apparatus" class="radio" type="radio"
                        disabled="disabled" name="alignType" value="apparatus"/>
                    <label for="apparatus">Text/Apparatus</label></span>
                    <span><input id="synopsis" class="radio" type="radio"
                        disabled="disabled" name="alignType" value="synopsis"/>
                    <label for="synopsis">Synopsis</label></span>
                    <h3 class="buttonsHead">Compare<a class="tooltip">[?]<span class="help"><em>Compare Texts</em>Select alignment type: Alignment: a word-by-word alignment ("partitur"); Text/Apparatus: text and apparatus (text designated 1 is the base text); Synopsis: selected texts presented in parallel-columns.</span></a></h3>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="submit">
                    <input class="submit" type="submit" value="Compare"/>
                    <!--<br> </br>
                    <input id="reset" class="submit" type="reset" value="Reset"
                    />
                    <!-\- Not working when values in the form are set by params.
                    Also, this does not work, due to xhtml vs html serialization issues that are not fixed easily.
                     <br/><form action="compare" method="get"><input id="reset" class="submit" type="button" value="Reset"/></form>
                    Can try a version of js at http://stackoverflow.com/questions/10629464/clear-html-form-that-has-its-reset-value -\->-->
                </div>
                <div class="radio">
                    <span><input id="align" class="radio" type="radio" value="align"
                        name="alignType">
                        <xsl:if test="$alignType='align' or $alignType = ''">
                            <xsl:attribute name="checked" select="'checked'"/>
                        </xsl:if>
                    </input>
                    <label for="align">Alignment</label></span>
                    <span><input id="apparatus" class="radio" type="radio"
                        name="alignType" value="apparatus">
                        <xsl:if test="$alignType='apparatus'">
                            <xsl:attribute name="checked" select="'checked'"/>
                        </xsl:if>
                    </input>
                    <label for="apparatus">Text/Apparatus</label></span>
                    <span><input id="synopsis" class="radio" type="radio"
                        name="alignType" value="synopsis">
                        <xsl:if test="$alignType='synopsis'">
                            <xsl:attribute name="checked" select="'checked'"/>
                        </xsl:if>
                    </input>
                    <label for="synopsis">Synopsis</label></span>
                    <h3 class="buttonsHead">Compare<a class="tooltip">[?]<span class="help"><em>Compare Texts</em>Select alignment type: Word-by-word alignment ("partitur"); text and apparatus (text designated 1 is the base text); parallel-column synopsis.</span></a></h3>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Templates in "selected" mode handle cases when user has selected text ($unit = "ch" or "m") -->
    <xsl:template match="tei:listWit[parent::tei:listWit]" mode="selected">
        <xsl:variable name="categDesc">
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:value-of select="@n"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="refWits">
            <xsl:for-each select="descendant::tei:witness">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if
            test="some $s in $refWits//tei:witness/@xml:id satisfies some $p in $witsWithText//my:wit-compos/text() satisfies $p = $s">

            <tr>
                <td class="categ" colspan="3">
                    <xsl:value-of select="$categDesc"/>
                </td>
            </tr>

        </xsl:if>

        <xsl:apply-templates mode="selected"/>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]" mode="selected">
        <xsl:variable name="checkMe" select="normalize-space(@xml:id)"/>
        <xsl:if
            test="some $p in $witsWithText//my:wit-compos/text() satisfies $p = $checkMe">
            <tr>
                <td class="selField">
                    <input name="{@xml:id}" type="text"
                        value="{$fieldVals/my:rqsWit[my:fieldName[text()=$checkMe]]/my:fieldVal}"
                        size="3" maxlength="3"/>
                </td>
                <td class="siglum">
                    <xsl:value-of select="@xml:id"/>
                </td>
                <td class="desc">
                    <xsl:value-of select="text()"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <!-- Templates in "noSelected" mode treat the initial case when no text has been selected ($unit = "''" or "'all'"). -->
    <xsl:template match="tei:listWit[parent::tei:listWit]" mode="noSelected">
        <tr>
            <td class="categ" colspan="3">
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
        <xsl:apply-templates mode="noSelected"/>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]" mode="noSelected">
        <tr>
            <td class="selField">
                <input type="text" value="" size="3" maxlength="3"
                    disabled="disabled"/>
            </td>
            <td class="siglum">
                <xsl:value-of select="@xml:id"/>
            </td>
            <td class="desc">
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template name="tokenizeRqs">
        <!-- modifies a template from M. Kay, XSLT 2.0, p. 887 -->
        <xsl:param name="text"> </xsl:param>
        <xsl:variable name="str" select="$text"/>
        <xsl:variable name="first" select="substring-before($str, '&amp;')"/>
        <xsl:variable name="rest" select="substring-after($str, '&amp;')"/>
        <xsl:element name="my:rqsWit" xmlns="local-functions.uri">
            <my:fieldName>
                <xsl:value-of select="substring-before($first,'=')"/>
            </my:fieldName>
            <my:fieldVal>
                <xsl:value-of select="substring-after($first,'=')"/>
            </my:fieldVal>
        </xsl:element>
        <xsl:if test="$rest">
            <xsl:choose>
                <xsl:when test="contains($rest,'&amp;')">
                    <!-- not last token -->
                    <xsl:call-template name="tokenizeRqs">
                        <xsl:with-param name="text" select="$rest"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- last token -->
                    <xsl:element name="my:rqsWit" xmlns="local-functions.uri">
                        <my:fieldName>
                            <xsl:value-of select="substring-before($rest,'=')"/>
                        </my:fieldName>
                        <my:fieldVal>
                            <xsl:value-of select="substring-after($rest,'=')"/>
                        </my:fieldVal>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="my:m-active-compos | my:ch-compos | my:ord-compos" mode="selected noSelected"/>
</xsl:stylesheet>
