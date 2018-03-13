<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- Converts excel table based on Meni Adler's analysis of text of Mishnah into a preliminary TEI and MAF format. -->
    <!-- See http://www.tei-c.org/release/doc/tei-p5-doc/en/html/FS.html and -->
    <!-- ISO 24611:2012 Language resource management - Morpho-syntactic annotation framework (MAF)-->
    <!-- A skeleton stylesheet; does not create a valid TEI document -->
    <xsl:variable name="categName">
        <xsl:for-each select="/worksheet/sheetData/row[@r='1']/c">
            <xsl:element name="{translate(@r,'0123459789','')}">
                <xsl:call-template name="cellValue">
                    <xsl:with-param name="c" select="."/>
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="sheetData/row">
        <!-- "sibling recursion" to group alternate analyses of the same token -->
        <xsl:variable name="testRows" as="element(*)">
            <xsl:call-template name="returnThisNext"/>
        </xsl:variable>
        <xsl:variable name="cells">
            <xsl:apply-templates select="*"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::row)">
                <!-- skip first row --> </xsl:when>
            <xsl:when test="substring-after($testRows/*:thisRow,'ana')='1'">
                <xsl:choose>
                    <xsl:when test="substring-after($testRows/*:nextRow,'ana')!='1'">
                        <!-- Next row does not start a new word  -->
                        <seg type="analysisGroup">
                            <xsl:attribute name="corresp"
                                select="concat('r:',substring-before($testRows/*:thisRow,'-ana'))"/>
                            <w type="token"
                                xml:id="{concat('m-',substring-before($testRows/*:thisRow,'-ana'))}"
                                corresp="{concat('r:',substring-before($testRows/*:thisRow,'-ana'))}">
                                <xsl:value-of select="$cells/*:surface"/>
                            </w>
                            <seg n="{substring-after($testRows/*:thisRow,'ana')}" type="analysis"
                                xml:id="{concat('m-',($testRows/*:thisRow))}">
                                <xsl:attribute name="subtype" select="concat('s-',$cells/*:score)"/>
                                <xsl:variable name="buildSpanGroup">
                                    <xsl:call-template name="spanGroup">
                                        <xsl:with-param name="cells" select="$cells"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:copy-of select="$buildSpanGroup"/>
                                <xsl:call-template name="buildFeatureStructure">
                                    <xsl:with-param name="cells" select="$cells"/>
                                    <xsl:with-param name="spanGroup" select="$buildSpanGroup"/>
                                </xsl:call-template>
                            </seg>
                            <xsl:apply-templates select="following-sibling::row[1]" mode="groupRows"
                            />
                        </seg>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- next row is a new word -->
                        <seg type="analysisGroup"
                            corresp="{concat('r:',substring-before($testRows/*:thisRow,'-ana'))}">
                            <w type="token"
                                xml:id="{concat('m-',substring-before($testRows/*:thisRow,'-ana'))}"
                                corresp="{concat('r:',substring-before($testRows/*:thisRow,'-ana'))}">
                                <xsl:value-of select="$cells/*:surface"/>
                            </w>
                            <seg n="{substring-after($testRows/*:thisRow,'ana')}" type="analysis"
                                xml:id="{concat('m-',($testRows/*:thisRow))}">
                                <xsl:attribute name="subtype" select="concat('s-',$cells/*:score)"/>
                                <xsl:variable name="buildSpanGroup">
                                    <xsl:call-template name="spanGroup">
                                        <xsl:with-param name="cells" select="$cells"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:copy-of select="$buildSpanGroup"/>
                                <xsl:call-template name="buildFeatureStructure">
                                    <xsl:with-param name="cells" select="$cells"/>
                                    <xsl:with-param name="spanGroup" select="$buildSpanGroup"/>
                                </xsl:call-template>
                            </seg>
                        </seg>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="row" mode="groupRows">
        <!-- iterates through siblings and adds rows -->
        <xsl:variable name="testRows" as="element(*)">
            <xsl:call-template name="returnThisNext"/>
        </xsl:variable>
        <xsl:variable name="cells">
            <xsl:apply-templates select="*"/>
        </xsl:variable>
        <seg n="{substring-after($testRows/*:thisRow,'ana')}" type="analysis"
            xml:id="{$testRows/*:thisRow}">
            <xsl:attribute name="subtype" select="concat('s-',$cells/*:score)"/>
            <xsl:variable name="buildSpanGroup">
                <xsl:call-template name="spanGroup">
                    <xsl:with-param name="cells" select="$cells"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:copy-of select="$buildSpanGroup"/>
            <xsl:call-template name="buildFeatureStructure">
                <xsl:with-param name="cells" select="$cells"/>
                <xsl:with-param name="spanGroup" select="$buildSpanGroup"/>
            </xsl:call-template>
        </seg>
        <xsl:choose>
            <xsl:when test="substring-after($testRows/*:nextRow,'ana')!='1'">
                <!-- Next row does not begin new word -->
                <xsl:apply-templates select="following-sibling::row[1]" mode="groupRows"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="c">
        <xsl:variable name="coll" as="xs:string">
            <xsl:variable name="matchColl" select="translate(@r,'0123456789','')"/>
            <xsl:value-of select="$categName/*[name()=$matchColl]"/>
        </xsl:variable>
        <xsl:element name="{$coll}">
            <xsl:call-template name="cellValue">
                <xsl:with-param name="c" select="."/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <xsl:template match="/">
        <test>
            <xsl:apply-templates/>
        </test>
    </xsl:template>
    <xsl:template name="cellValue">
        <xsl:param name="c" select="'null'"/>
        <xsl:choose>
            <!-- borrowed from oxygen sample -->
            <xsl:when test="$c/@t='s'">
                <!-- this is an excel shared string, requires lookup in sharedStrings.xml -->
                <xsl:variable name="string-index" select="number(normalize-space($c/v)) + 1"/>
                <xsl:value-of
                    select="normalize-space(document('../sharedStrings.xml',.)/sst/si[position() =  $string-index]/t)"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- can copy the text in child v element -->
                <xsl:value-of select="normalize-space($c/v)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="returnThisNext">
        <!-- Extracts ids for current row and next row. -->
        <rows>
            <thisRow>
                <xsl:call-template name="cellValue">
                    <xsl:with-param name="c" select="c[2]"/>
                </xsl:call-template>
            </thisRow>
            <nextRow>
                <xsl:call-template name="cellValue">
                    <xsl:with-param name="c" select="following-sibling::row[1]/c[2]"/>
                </xsl:call-template>
            </nextRow>
        </rows>
    </xsl:template>
    <!-- build span groups and spans for segmentation of token -->
    <xsl:template name="spanGroup">
        <xsl:param name="cells"/>
        <xsl:variable name="id" select="$cells/*[name()='ana_id']"/>
        <spanGrp>
            <xsl:for-each select="$cells/*[matches(name(),'pref\d-id')]">
                <xsl:variable name="lengths">
                    <xsl:call-template name="lengths">
                        <xsl:with-param name="thisCell"
                            select="following-sibling::*[matches(name(),'pref\d-surface')][1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <span type="pref" xml:id="{concat('m-',replace($id,'-ana','.ana-'),'.pref-',.)}">
                    <xsl:attribute name="target">
                        <xsl:text>string-range(</xsl:text>
                        <xsl:value-of
                            select="concat('r:',substring-before($id,'-ana'),',',$lengths/*:preceding,',',$lengths/*:this)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="following-sibling::*[matches(name(),'pref\d-surface')][1]"
                    />
                </span>
            </xsl:for-each>
            <xsl:for-each select="$cells/*:middle">
                <xsl:variable name="lengths">
                    <xsl:call-template name="lengths">
                        <xsl:with-param name="thisCell" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <span type="base" xml:id="{concat('m-',replace($id,'-ana','.ana-'),'.base')}">
                    <xsl:attribute name="target">
                        <xsl:text>string-range(</xsl:text>
                        <xsl:value-of
                            select="concat('r:',substring-before($id,'-ana'),',',$lengths/*:preceding,',',$lengths/*:this)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </span>
            </xsl:for-each>
            <xsl:for-each select="$cells/*:suffix-surface-including-infix">
                <xsl:variable name="lengths">
                    <xsl:call-template name="lengths">
                        <xsl:with-param name="thisCell" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <span type="suff" xml:id="{concat('m-',replace($id,'-ana','.ana-'),'.suff')}">
                    <xsl:attribute name="target">
                        <xsl:text>string-range(</xsl:text>
                        <xsl:value-of
                            select="concat('r:',substring-before($id,'-ana'),',',$lengths/*:preceding,',',$lengths/*:this)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </span>
            </xsl:for-each>
        </spanGrp>
    </xsl:template>
    <xsl:template name="lengths">
        <xsl:param name="thisCell"/>
        <this>
            <xsl:value-of select="string-length($thisCell)"/>
        </this>
        <preceding>
            <xsl:value-of
                select="string-length(string-join((preceding-sibling::*[matches(name(),'pref\d-surface')], preceding-sibling::*:middle,preceding-sibling::*:suffix-surface-including-infix),''))"
            />
        </preceding>
    </xsl:template>
    <xsl:template name="buildFeatureStructure">
        <xsl:param name="cells"/>
        <xsl:param name="spanGroup"/>
        <fs>
            <f name="lemma">
                <symbol value="{$cells/*:lexiconItem}"/>
            </f>
            <f name="root">
                <symbol value="{$cells/*:root}"/>
            </f>
            <xsl:for-each select="$spanGroup/*:spanGrp/*:span">
                <f>
                    <xsl:attribute name="n">
                        <xsl:number/>
                    </xsl:attribute>
                    <xsl:attribute name="corresp" select="concat('#',@xml:id)"/>
                    <xsl:choose>
                        <xsl:when test="@type='pref'">
                            <xsl:variable name="nameTest"
                                select="concat('pref',substring-after(@xml:id,'pref-'),'-function')"/>
                            <xsl:attribute name="name" select="'prefix'"/>
                            <xsl:attribute name="fVal">
                                <xsl:choose>
                                    <xsl:when test="$cells/*[name()=$nameTest]='adverb'">
                                        <xsl:text>m:adv</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*[name()=$nameTest]='conjunction'">
                                        <xsl:text>m:conj</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*[name()=$nameTest]='preposition'">
                                        <xsl:text>m:prep</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="$cells/*[name()=$nameTest]='relativizer/subordinatingConjunction'">
                                        <xsl:text>m:relOrSubord</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*[name()=$nameTest]='temporalSubConj'">
                                        <xsl:text>m:tempSubord</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:if
                                test="$cells/*[name()=$nameTest]='preposition' or contains($cells/*[name()=$nameTest],'onj')">
                                <fs feats="m:att"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="@type='base'">
                            <xsl:attribute name="name" select="'base'"/>
                            <xsl:attribute name="feats">

                                <!-- POS -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:POS = 'adjective'">
                                        <xsl:text>m:adj</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'adverb'">
                                        <xsl:text>m:adv</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'conjunction'">
                                        <xsl:text>m:adv m:unatt</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'copula'">
                                        <xsl:text>m:v m:copul</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'existential'">
                                        <xsl:text>m:v m:exist</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'copula'">
                                        <xsl:text>m:v</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'interjection'">
                                        <xsl:text>m:interj</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'interrogative'">
                                        <xsl:text>m:interr</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'modal'">
                                        <xsl:text>m:v m:modal</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'negation'">
                                        <xsl:text>m:ptcl m:neg</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'noun'">
                                        <xsl:text>m:n</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'numeral'">
                                        <xsl:text>m:numer</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'participle'">
                                        <xsl:text>m:ptcpl</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'preposition'">
                                        <xsl:text>m:prep m:unatt</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'pronoun'">
                                        <xsl:text>m:pron</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'properName'">
                                        <xsl:text>m:pNoun</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'punctuation'">
                                        <xsl:text>m:punct</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'quantifier'">
                                        <xsl:text>m:other m:quant</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'title'">
                                        <xsl:text>m:pNoun m:title</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'verb'">
                                        <xsl:text>m:v</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:POS = 'wPrefix'">
                                        <xsl:text>m:pref m:unatt</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>pos-ERROR</xsl:otherwise>
                                </xsl:choose>

                                <!-- binyan-->
                                <xsl:if test="$cells/*:binyan">
                                    <xsl:value-of
                                        select="translate(lower-case(concat(' m:',$cells//*:binyan)),'&apos;&apos;','')"
                                    />
                                </xsl:if>

                                <!-- definiteness -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:definiteness='TRUE'">
                                        <xsl:text> m:def</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="$cells/*:definiteness ='singular' or$cells/*:definiteness ='plural'">
                                        <xsl:text> def-ERROR</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- gender -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:gender='masculine'">
                                        <xsl:text> m:M</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:gender='feminine'">
                                        <xsl:text> m:F</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:gender='masculine_and_feminine'">
                                        <xsl:text> m:MorF</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- number -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:number='singular'">
                                        <xsl:text> m:S</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:number='dual'">
                                        <xsl:text> m:D</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:number='plural'">
                                        <xsl:text> m:P</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:number='singular_and_plural'">
                                        <xsl:text> m:SandP</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:number='dual_and_plural'">
                                        <xsl:text> m:DandP</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string($cells/*:number)">
                                        <xsl:text> num-ERROR</xsl:text>
                                    </xsl:when>
                                </xsl:choose>


                                <!-- person -->
                                <xsl:choose>
                                    <!-- test if a number -->
                                    <xsl:when
                                        test="(number($cells/*:person) = number($cells/*:person)) or ($cells/*:person = 'any')">
                                        <xsl:value-of select="concat(' m:p_',$cells/*:person)"/>
                                    </xsl:when>
                                    <xsl:when test="string($cells/*:person)">
                                        <xsl:text> pers-ERROR</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>

                                <!-- polarity -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:polarity = 'positive'">
                                        <xsl:text> m:posit</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:polarity = 'negative'">
                                        <xsl:text> m:neg</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- status -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:status = 'absolute'">
                                        <xsl:text> m:abs</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:status = 'construct'">
                                        <xsl:text> m:constr</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string($cells/*:status)">
                                        <xsl:text> stat-ERROR</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- tense [and mood]  -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:tense = 'beinoni'">
                                        <xsl:text> m:pres</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:tense = 'past'">
                                        <xsl:text> m:perf</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:tense = 'future'">
                                        <xsl:text> m:impf</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:tense = 'imperative'">
                                        <xsl:text> m:imptv</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:tense = 'infinitive'">
                                        <xsl:text> m:infin</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- type -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:type = 'amount'">
                                        <xsl:text> m:amt</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'coordinating'">
                                        <xsl:text> m:coord</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'demonstrative'">
                                        <xsl:text> m:demonst</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'determiner'">
                                        <xsl:text> m:determ</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'gematria'">
                                        <xsl:text> m:gemat</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'gematria'">
                                        <xsl:text> m:gemat</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'impersonal'">
                                        <xsl:text> m:impers</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'noun/adjective'">
                                        <xsl:text> m:substant</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'numeral_cardinal'">
                                        <xsl:text> m:card</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'numeral_fractional'">
                                        <xsl:text> m:fract</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'numeral_ordinal'">
                                        <xsl:text> m:ord</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'partitive'">
                                        <xsl:text> m:partit</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'personal'">
                                        <xsl:text> m:pers</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'proadverb'">
                                        <xsl:text> m:proadv</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'prodet'">
                                        <xsl:text> m:prodet</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'reflexive'">
                                        <xsl:text> m:reflex</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'relativizing'">
                                        <xsl:text> m:relat</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'subordinating'">
                                        <xsl:text> m:subord</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'verb'">
                                        <xsl:text> m:verbal</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$cells/*:type = 'yesno'">
                                        <xsl:text> m:yesNo</xsl:text>
                                    </xsl:when>

                                    <xsl:when test="string($cells/*:type)">
                                        <xsl:text> type-ERROR</xsl:text>
                                    </xsl:when>
                                </xsl:choose>

                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@type='suff'">
                            <xsl:attribute name="name" select="'suffix'"/>
                            <xsl:attribute name="feats">
                                <!-- suff-function -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:suff-function">
                                        <xsl:choose>
                                            <xsl:when
                                                test="$cells/*:suff-function = 'accusative or nominative'">
                                                <xsl:text> m:accus_or_nom</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$cells/*:suff-function = 'possessive'">
                                                <xsl:text> m:poss</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$cells/*:suff-function = 'pronomial'">
                                                <xsl:text> m:pronom</xsl:text>
                                            </xsl:when>

                                            <xsl:when test="string($cells/*:suff-function)">
                                                <xsl:text> suff-funct-ERROR</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                                <!-- suff-person -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:suff-person">
                                        <!-- test if a number -->
                                        <xsl:choose>
                                            <xsl:when
                                                test="(number($cells/*:suff-person) = number($cells/*:suff-person)) or ($cells/*:suff-person = 'any')">
                                                <xsl:value-of
                                                  select="concat(' m:p_',$cells/*:suff-person)"/>
                                            </xsl:when>
                                            <xsl:when test="string($cells/*:suff-person)">
                                                <xsl:text> suff-pers-ERROR</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- suff-number -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:suff-number">
                                        <xsl:choose>
                                            <xsl:when test="$cells/*:suff-number ='singular'">
                                                <xsl:text> m:S</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$cells/*:suff-number ='plural'">
                                                <xsl:text> m:P</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>

                                <!-- suff-gender -->
                                <xsl:choose>
                                    <xsl:when test="$cells/*:suff-gender">
                                        <xsl:choose>
                                            <xsl:when test="$cells/*:suff-gender ='masculine'">
                                                <xsl:text> m:M</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$cells/*:suff-gender ='feminine'">
                                                <xsl:text> m:F</xsl:text>
                                            </xsl:when>
                                            <xsl:when
                                                test="$cells/*:suff-gender = 'masculine and feminine'">
                                                <xsl:text> m:MorF</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </f>
            </xsl:for-each>
        </fs>
    </xsl:template>
</xsl:stylesheet>
