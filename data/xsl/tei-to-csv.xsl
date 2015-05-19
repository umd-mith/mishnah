<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://localhost.uri" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:unclear tei:gap"/>

    <xsl:output indent="yes"/>
    <xsl:param name="docName" select="'ref'"/>
    <xsl:param name="tag" select="'psV'"/>
    <xsl:param name="range" select="'4.1,4.2,4.3'"/>
    <xsl:variable name="sqlEquiv" xmlns="http://localhost.uri">
        <my:equiv>
            <my:teiName>div1</my:teiName>
            <my:sql>ms_text_structure_order</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>div2</my:teiName>
            <my:sql>ms_text_structure_treatise</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>div3</my:teiName>
            <my:sql>ms_text_structure_chapter</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>ab</my:teiName>
            <my:sql>milestone</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>head</my:teiName>
            <my:sql>paratext</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>trailer</my:teiName>
            <my:sql>paratext</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>pb</my:teiName>
            <my:sql>ms_structure_new_page</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>cb</my:teiName>
            <my:sql>ms_structure_new_column</my:sql>
        </my:equiv>
        <my:equiv>
            <my:teiName>lb</my:teiName>
            <my:sql>ms_layout_line_break</my:sql>
        </my:equiv>
    </xsl:variable>
    <xsl:variable name="URItoGet" xmlns="http://localhost.uri">
        <xsl:for-each select="tokenize($range,',')">
            <my:lookup>
                <xsl:value-of select="concat('../tei/',$docName,'.xml','#',$docName,'.',.)"/>
            </my:lookup>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="*|text()|@*">
        <!-- Identity transform ignores comments and processing instructions -->
        <xsl:copy>
            <xsl:apply-templates select="*|text()|@*"/>
        </xsl:copy>
    </xsl:template>


    <!-- build csv -->
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:div1|tei:div2|tei:div3|tei:head|tei:trailer|tei:ab">
        <xsl:variable name="elemName" select="name()"/>
        <xsl:text>&#xd;</xsl:text>
        <xsl:value-of select="substring-after(@xml:id,'.')"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$elemName"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$sqlEquiv/my:equiv[my:teiName =
            $elemName]/my:sql"></xsl:value-of><xsl:text>,</xsl:text><xsl:value-of select="$tag"/>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- needs review with more complex use cases -->
    <xsl:template match="tei:label|tei:num"/>

    <xsl:template match="tei:w">
        <xsl:text>&#xd;</xsl:text>
        <xsl:value-of select="substring-after(@xml:id,'.')"/>
        <xsl:text>,</xsl:text>
        <!-- temporary typographical kludge for damage, add, del outside of w element -->
        <!-- tests if not damage, add, del with no string.-->
        <xsl:if
            test="preceding-sibling::*[self::tei:damageSpan|self::tei:addSpan|self::tei:delSpan]
            and preceding-sibling::*[self::tei:damageSpan|self::tei:addSpan|self::tei:delSpan]/@spanTo !=
            preceding-sibling::*[self::tei:damageSpan|self::tei:addSpan|self::tei:delSpan]/following-sibling::*[1]/@xml:id">
            <xsl:variable name="wPos" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="not(preceding-sibling::tei:w)">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="count(preceding-sibling::tei:w[1]/preceding-sibling::*)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each
                select="preceding-sibling::*[self::tei:damageSpan|self::tei:addSpan|self::tei:delSpan][count(preceding-sibling::*) &gt; $wPos]">
                <xsl:if test="self::tei:damageSpan">
                    <xsl:text>&lt;</xsl:text>
                </xsl:if>
                <xsl:if test="self::tei:addSpan">
                    <xsl:text>[</xsl:text>
                </xsl:if>
                <xsl:if test="self::tei:delSpan">
                    <xsl:text>(</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:apply-templates/>
        <!-- temporary typographical kludge for damage, add, del outside of w element -->
        <!-- tests if not self-enclosed damage, add, del -->
        <xsl:if
            test="following-sibling::tei:anchor and
            following-sibling::tei:anchor/@xml:id != following-sibling::tei:anchor/preceding-sibling::*[1]/@spanTo">
            <xsl:variable name="nextWPos" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="not(following-sibling::tei:w)">
                        <xsl:value-of select="9999"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="count(following-sibling::tei:w[1]/preceding-sibling::*)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each
                select="following-sibling::tei:anchor[count(preceding-sibling::*) &lt; $nextWPos]">
                <xsl:if test="@type='unclear'">
                    <xsl:text>&gt;</xsl:text>
                </xsl:if>
                <xsl:if test="@type='add'">
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:if test="@type='del'">
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="parent::*[self::tei:head|self::tei:trailer]">
                <xsl:text>,paratext,</xsl:text>
                <xsl:value-of select="$tag"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>,word,</xsl:text>
                <xsl:value-of select="$tag"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:c">
        <xsl:if test="@type='altChar' and preceding-sibling::*[1][self::tei:c[@type='altChar']]">
            <xsl:text>|</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:cb|tei:cb">
        <xsl:variable name="elemName" select="name()"></xsl:variable>
        <xsl:text>&#xd;</xsl:text>
        <xsl:value-of select="substring-after(@xml:id,'.')"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$elemName"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$sqlEquiv/my:equiv[my:teiName =
            $elemName]/my:sql"></xsl:value-of><xsl:text>,</xsl:text><xsl:value-of select="$tag"/>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:variable name="elemName" select="name()"></xsl:variable>
        <xsl:variable name="pageColNo">
            <xsl:choose>
                <xsl:when
                    test="count(preceding::tei:cb[1]/preceding::*) &gt; count(preceding::tei:pb[1]/preceding::*)">
                    <xsl:value-of select="preceding::tei:cb[1]/@xml:id"/>
                </xsl:when>
                <xsl:when
                    test="count(preceding-sibling::tei:cb[1]/preceding::*) &gt; count(preceding-sibling::tei:pb[1]/preceding::*)">
                    <xsl:value-of select="preceding-sibling::tei:cb[1]/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="preceding-sibling::pb[1]/@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>&#xd;</xsl:text>
        <xsl:value-of select="substring-after($pageColNo,'.')"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$elemName"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$sqlEquiv/my:equiv[my:teiName =
            $elemName]/my:sql"></xsl:value-of><xsl:text>,</xsl:text><xsl:value-of select="$tag"/>
    </xsl:template>
    <xsl:template match="tei:addSpan">
        <xsl:if test="ancestor::tei:w">
            <xsl:text>[</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:delSpan">
        <xsl:if test="ancestor::tei:w">
            <xsl:text>(</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:damageSpan">
        <xsl:if test="ancestor::tei:w">
            <xsl:choose>
                <xsl:when test="@type='unclear' and not(@extent)">
                    <xsl:text>&lt;</xsl:text>
                </xsl:when>
                <xsl:when test="@type='unclear' and @extent">
                    <xsl:text>&lt;±</xsl:text>
                    <xsl:value-of select="@extent"/>
                </xsl:when>
                <xsl:otherwise><!-- don't process generic damage --></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:gap[@reason='damage']">
        <xsl:text>{±</xsl:text>
        <xsl:value-of select="@extent"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:anchor">
        <xsl:if test="ancestor::tei:w">
            <xsl:choose>
                <xsl:when test="@type='add'">
                    <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:when test="@type='del'">
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="@type='unclear'">
                    <xsl:text>&gt;</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/">
        <xsl:result-document href="{concat('../tei/',$docName,'-to-CSV.csv')}" encoding="utf-8"
            omit-xml-declaration="yes" method="text" byte-order-mark="yes">
            <xsl:text>order,contents,kind,manuscript</xsl:text>
            <xsl:for-each select="$URItoGet/my:lookup">
                <xsl:apply-templates select="document(.)"/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
