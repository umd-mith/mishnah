<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
    
    <xsl:variable name="categName">
        <xsl:for-each select="/worksheet/sheetData/row[@r='1']/c">
            <xsl:element name="{translate(@r,'0123459789','')}">
                <xsl:call-template name="cellValue">
                    <xsl:with-param name="c" select="."/>
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <!--<xsl:variable name="sharedStrings" select="document('../sharedStrings.xml',.)"/>-->
    
    <xsl:template match="/">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="sheetData/row">
        <xsl:variable name="cells">
            <xsl:apply-templates select="*"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::row)">
                <!-- skip first row -->
            </xsl:when>
            <xsl:otherwise>
                <seg>
                    <xsl:analyze-string select="$cells/*:ana_id"
                        regex="ref\.([1-6])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,3}})\-ana([0-9]{{1,3}})">
                        <xsl:matching-substring>
                            <xsl:attribute name="x-s" select="regex-group(1)"/>
                            <xsl:attribute name="x-m" select="regex-group(2)"/>
                            <xsl:attribute name="x-p" select="regex-group(3)"/>
                            <xsl:attribute name="x-h" select="regex-group(4)"/>
                            <xsl:attribute name="x-w" select="regex-group(5)"/>
                            <xsl:attribute name="n" select="regex-group(6)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <!-- id removed for shortening file -->
                    <!--                    <xsl:attribute name="xml:id"
                        select="concat('m-',(substring-before($cells/*:ana_id,'-')),'.ana-',substring-after($cells/*:ana_id,'ana'))"/>-->
                    
                    <xsl:attribute name="type" select="concat('s-',$cells/*:score)"/>
                    
                    <xsl:call-template name="segments">
                        <xsl:with-param name="cells" select="$cells"/>
                    </xsl:call-template>
                </seg>
            </xsl:otherwise>
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
    
    <xsl:template match="*:seg">
        <seg>
            <xsl:copy-of select="*|@* except attribute::*[contains(name(),'x-')]"/>
        </seg>
    </xsl:template>
    
        <xsl:template name="cellValue">
        <xsl:param name="c" select="'null'"/>
        <xsl:choose>
            <!-- borrowed from oxygen sample -->
            <xsl:when test="$c/@t='s'">
                <!-- this is an excel shared string, requires lookup in sharedStrings.xml -->
                <xsl:variable name="string-index" select="number(normalize-space($c/*:v)) + 1"/>
                <!--<xsl:value-of
                    select="normalize-space($sharedStrings/*:sst/*:si[position() =  $string-index]/*:t)"
                />-->
                <xsl:value-of
                    select="normalize-space(document('../sharedStrings.xml',.)/*:sst/*:si[position() =  $string-index]/*:t)"/>

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
    <!-- build segments for inclusion in m elements -->
    <xsl:template name="segments">
        <xsl:param name="cells"/>

        <xsl:variable name="id" select="$cells/*[name()='ana_id']"/>
        <xsl:for-each select="$cells/*[matches(name(),'pref\d-id')]">
            <xsl:variable name="lengths">
                <xsl:call-template name="lengths">
                    <xsl:with-param name="thisCell" select="following-sibling::*[matches(name(),'pref\d-surface')][1]"/>
                </xsl:call-template>
            </xsl:variable>
            <span type="pref">

                <xsl:attribute name="n" select="substring-before(substring-after(name(),'pref'),'-')"/>
                <!-- Commenting out pointing to keep file size to minimum -->
                <!--<xsl:attribute
                    +name="from">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + 1))"
                    />
                </xsl:attribute>
                <xsl:attribute name="to">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + $lengths/*:this))"
                    />-->
                <!--</xsl:attribute>-->
                <xsl:attribute name="ana">
                    <xsl:call-template name="ana-links">
                        <xsl:with-param name="mType" select="'pref'"/>
                        <xsl:with-param name="cells" select="following-sibling::*[matches(name(),'pref\d-function')][1]"
                            as="element()"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:value-of select="following-sibling::*[matches(name(),'pref\d-surface')][1]"/>
            </span>
        </xsl:for-each>
        <xsl:for-each select="$cells/*:lexiconItem">

            <xsl:variable name="lengths">
                <xsl:call-template name="lengths">
                    <xsl:with-param name="thisCell">
                        <xsl:choose>
                            <xsl:when test="$cells/*:middle">
                                <xsl:value-of select="$cells/*:middle"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <span type="base">
                <!-- commenting out pointing to keep file size short -->
                <!--                <xsl:attribute name="from">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + 1))"
                    />
                </xsl:attribute>
                <xsl:attribute name="to">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + $lengths/*:this))"
                    />
                </xsl:attribute>-->
                <xsl:attribute name="ana">
                    <xsl:call-template name="ana-links">
                        <xsl:with-param name="cells"
                            select="for $i in $cells/*[not(contains(name(),'suff')) and not(contains(name(),'pref'))] return $i"
                            as="element()+"/>
                        <xsl:with-param name="mType" select="'base'"/>
                    </xsl:call-template>
                </xsl:attribute>

                <xsl:value-of select="if ($cells/*:middle) then $cells/*:middle else $cells/*:lexiconItem"/>
                <span type="lemma">
                    <xsl:value-of select="$cells/*:lexiconItem"/>
                </span>
                <!-- to retain dummy value where no root is present use commented version below -->
                <span type="root">
                    <xsl:value-of select="if ($cells/*:root) then $cells/*:root else '???'"/>
                </span>
            </span>
        </xsl:for-each>
        <xsl:for-each select="$cells/*:suffix-surface-including-infix">
            <xsl:variable name="lengths">
                <xsl:call-template name="lengths">
                    <xsl:with-param name="thisCell" select="."/>
                </xsl:call-template>
            </xsl:variable>
            <span type="suff">
                <!-- commenting out linking to keep working file size short -->
                <!--                <xsl:attribute name="from">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + 1))"
                    />
                </xsl:attribute>
                <xsl:attribute name="to">
                    <xsl:value-of
                        select="concat('r:',substring-before($id,'-ana'),'.',($lengths/*:preceding + $lengths/*:this))"
                    />
                </xsl:attribute>-->
                <xsl:attribute name="ana">
                    <xsl:call-template name="ana-links">
                        <xsl:with-param name="cells" select="for $i in $cells/*[contains(name(),'suff')] return $i"/>
                        <xsl:with-param name="mType" select="'suff'"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </span>
        </xsl:for-each>

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
    <xsl:template name="ana-links">
        <xsl:param name="cells"/>
        <xsl:param name="mType"/>

        <xsl:choose>
            <xsl:when test="$mType = 'pref'">


                <xsl:choose>
                    <xsl:when test="$cells = 'adverb'">
                        <xsl:text>m:adv</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells = 'conjunction'">
                        <xsl:text>m:conj</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells = 'preposition'">
                        <xsl:text>m:prep</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells = 'relativizer/subordinatingConjunction'">
                        <xsl:text>m:relOrSubord</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells = 'temporalSubConj'">
                        <xsl:text>m:tempSubord</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="$cells = 'preposition' or contains($cells,'conj')">
                    <xsl:text> m:att</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$mType = 'base'">
                <!-- POS -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'POS'] = 'adjective'">
                        <xsl:text>m:adj</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'adverb'">
                        <xsl:text>m:adv</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'conjunction'">
                        <xsl:text>m:adv m:unatt</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'copula'">
                        <xsl:text>m:v m:copul</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'existential'">
                        <xsl:text>m:v m:exist</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'copula'">
                        <xsl:text>m:v</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'interjection'">
                        <xsl:text>m:interj</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'interrogative'">
                        <xsl:text>m:interr</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'modal'">
                        <xsl:text>m:v m:modal</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'negation'">
                        <xsl:text>m:ptcl m:neg</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'noun'">
                        <xsl:text>m:n</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'numeral'">
                        <xsl:text>m:numer</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'participle'">
                        <xsl:text>m:ptcpl</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'preposition'">
                        <xsl:text>m:prep m:unatt</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'pronoun'">
                        <xsl:text>m:pron</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'properName'">
                        <xsl:text>m:pNoun</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'punctuation'">
                        <xsl:text>m:punct</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'quantifier'">
                        <xsl:text>m:other m:quant</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'title'">
                        <xsl:text>m:pNoun m:title</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'verb'">
                        <xsl:text>m:v</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'POS'] = 'wPrefix'">
                        <xsl:text>m:pref m:unatt</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>pos-ERROR</xsl:otherwise>
                </xsl:choose>

                <!-- binyan-->
                <xsl:if test="$cells[name() = 'binyan']">
                    <xsl:value-of select="translate(lower-case(concat(' m:',$cells[name() = 'binyan'])),'&apos;&apos;','')"/>
                </xsl:if>

                <!-- definiteness -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'definiteness'] = 'TRUE'">
                        <xsl:text> m:def</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'definiteness'] ='singular' or $cells[name() = 'definiteness'] ='plural'">
                        <xsl:text> def-ERROR</xsl:text>
                    </xsl:when>
                </xsl:choose>

                <!-- gender -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'gender'] = 'masculine'">
                        <xsl:text> m:M</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'gender'] = 'feminine'">
                        <xsl:text> m:F</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'gender'] = 'masculine_and_feminine'">
                        <xsl:text> m:MorF</xsl:text>
                    </xsl:when>
                </xsl:choose>

                <!-- number -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'number'] = 'singular'">
                        <xsl:text> m:S</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'number'] = 'dual'">
                        <xsl:text> m:D</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'number'] = 'plural'">
                        <xsl:text> m:P</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'number'] = 'singular_and_plural'">
                        <xsl:text> m:SandP</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'number'] = 'dual_and_plural'">
                        <xsl:text> m:DandP</xsl:text>
                    </xsl:when>
                    <xsl:when test="string($cells[name() = 'number'])">
                        <xsl:text> num-ERROR</xsl:text>
                    </xsl:when>
                </xsl:choose>


                <!-- person -->
                <xsl:choose>
                    <!-- test if a number -->
                    <xsl:when
                        test="(number($cells[name() = 'person']) = number($cells[name() = 'person'])) or ($cells[name() = 'person'] = 'any')">
                        <xsl:value-of select="concat(' m:p_',$cells[name() = 'person'])"/>
                    </xsl:when>
                    <xsl:when test="string($cells[name() = 'person'])">
                        <xsl:text> pers-ERROR</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>

                <!-- polarity -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'polarity'] = 'positive'">
                        <xsl:text> m:posit</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'polarity'] = 'negative'">
                        <xsl:text> m:neg</xsl:text>
                    </xsl:when>
                </xsl:choose>

                <!-- status -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'status'] = 'absolute'">
                        <xsl:text> m:abs</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'status'] = 'construct'">
                        <xsl:text> m:constr</xsl:text>
                    </xsl:when>
                    <xsl:when test="string($cells[name() = 'status'])">
                        <xsl:text> stat-ERROR</xsl:text>
                    </xsl:when>
                </xsl:choose>

                <!-- tense [and mood]  -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'tense'] = 'beinoni'">
                        <xsl:text> m:pres</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'tense'] = 'past'">
                        <xsl:text> m:perf</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'tense'] = 'future'">
                        <xsl:text> m:impf</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'tense'] = 'imperative'">
                        <xsl:text> m:imptv</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'tense'] = 'infinitive'">
                        <xsl:text> m:infin</xsl:text>
                    </xsl:when>
                </xsl:choose>

                <!-- type -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'type'] = 'amount'">
                        <xsl:text> m:amt</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'coordinating'">
                        <xsl:text> m:coord</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'demonstrative'">
                        <xsl:text> m:demonst</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'determiner'">
                        <xsl:text> m:determ</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'gematria'">
                        <xsl:text> m:gemat</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'gematria'">
                        <xsl:text> m:gemat</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'impersonal'">
                        <xsl:text> m:impers</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'noun/adjective'">
                        <xsl:text> m:substant</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'numeral_cardinal'">
                        <xsl:text> m:card</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'numeral_fractional'">
                        <xsl:text> m:fract</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'numeral_ordinal'">
                        <xsl:text> m:ord</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'partitive'">
                        <xsl:text> m:partit</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'personal'">
                        <xsl:text> m:pers</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'proadverb'">
                        <xsl:text> m:proadv</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'prodet'">
                        <xsl:text> m:prodet</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'reflexive'">
                        <xsl:text> m:reflex</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'relativizing'">
                        <xsl:text> m:relat</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'subordinating'">
                        <xsl:text> m:subord</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'verb'">
                        <xsl:text> m:verbal</xsl:text>
                    </xsl:when>
                    <xsl:when test="$cells[name() = 'type'] = 'yesno'">
                        <xsl:text> m:yesNo</xsl:text>
                    </xsl:when>

                    <xsl:when test="string($cells[name() = 'type'])">
                        <xsl:text> type-ERROR</xsl:text>
                    </xsl:when>
                </xsl:choose>

            </xsl:when>
            <xsl:when test="$mType = 'suff'">
                <!-- suff-function -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'suff-function']">
                        <xsl:choose>
                            <xsl:when test="$cells[name() = 'suff-function'] = 'accusative or nominative'">
                                <xsl:text> m:accus_or_nom</xsl:text>
                            </xsl:when>
                            <xsl:when test="$cells[name() = 'suff-function'] = 'possessive'">
                                <xsl:text> m:poss</xsl:text>
                            </xsl:when>
                            <xsl:when test="$cells[name() = 'suff-function'] = 'pronomial'">
                                <xsl:text> m:pronom</xsl:text>
                            </xsl:when>

                            <xsl:when test="string($cells[name() = 'suff-function'])">
                                <xsl:text> suff-funct-ERROR</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <!-- suff-person -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'suff-person']">
                        <!-- test if a number -->
                        <xsl:choose>
                            <xsl:when
                                test="(number($cells[name() = 'suff-person']) = number($cells[name() = 'suff-person'])) or ($cells[name() = 'suff-person'] = 'any')">
                                <xsl:value-of select="concat(' m:p_',$cells[name() = 'suff-person'])"/>
                            </xsl:when>
                            <xsl:when test="string($cells[name() = 'suff-person'])">
                                <xsl:text> suff-pers-ERROR</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>

                <!-- suff-number -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'suff-number']">
                        <xsl:choose>
                            <xsl:when test="$cells[name() = 'suff-number'] ='singular'">
                                <xsl:text> m:S</xsl:text>
                            </xsl:when>
                            <xsl:when test="$cells[name() = 'suff-number'] ='plural'">
                                <xsl:text> m:P</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>

                <!-- suff-gender -->
                <xsl:choose>
                    <xsl:when test="$cells[name() = 'suff-gender']">
                        <xsl:choose>
                            <xsl:when test="$cells[name() = 'suff-gender'] ='masculine'">
                                <xsl:text> m:M</xsl:text>
                            </xsl:when>
                            <xsl:when test="$cells[name() = 'suff-gender'] ='feminine'">
                                <xsl:text> m:F</xsl:text>
                            </xsl:when>
                            <xsl:when test="$cells[name() = 'suff-gender'] = 'masculine and feminine'">
                                <xsl:text> m:MorF</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>

            </xsl:when>
        </xsl:choose>

    </xsl:template>
    
</xsl:stylesheet>