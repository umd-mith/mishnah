<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:import href="tei-to-wSeparated.xsl"/>
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="tei-loc" select="'../../../digitalmishnah-tei/mishnah/'"/>
    <xsl:param name="mcite" select="'4.1.1.1'"/>
    <xsl:param name="wits" select="'S00483,S07326'"/>
    <xsl:template match="/">
        <xsl:text>{
</xsl:text><!-- Add options here -->
        <xsl:text>"joined":false,</xsl:text><!-- Witnesses -->
        <xsl:text>"witnesses" : [</xsl:text>
        <xsl:variable name="tokenizedM">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:apply-templates select="$tokenizedM" mode="toJSON"/>
        <xsl:text>
]
}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]">
       <xsl:variable name="id" select="@xml:id"/>
        <xsl:if test="$wits = 'all' or contains($wits, substring-before(@corresp,'.xml'))">
           <xsl:message>
                <xsl:value-of select="@corresp"/>
            </xsl:message>
           <xsl:message>has id <xsl:value-of select="concat($id,'.',$mcite)"/>, <xsl:value-of select="if (document(concat($tei-loc,@corresp))//tei:ab[@xml:id = (concat($id,'.',$mcite))]) then 'yes' else 'no'"/>
            </xsl:message>
            <xsl:variable name="uri" select="concat($tei-loc,@corresp)"/>
            <xsl:if test="doc-available($uri)">
                <xsl:variable name="ab" select="concat(substring-before(@corresp,'.'),'.',$mcite)"/>
                <xsl:variable name="doc" select="document($uri)"/>
                <xsl:variable name="extracts" select="$doc//tei:ab[@xml:id=$ab]"/>
                <xsl:if test="not(empty($extracts))">
                    <xsl:if test="preceding::tei:witness[@corresp] and                         (some $c in preceding::tei:witness/@corresp satisfies contains($wits, substring-before($c,'.xml')) or                         $wits = 'all')">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:text>
                {
                "id" : "</xsl:text>
                    <xsl:value-of select="@corresp"/>
                    <xsl:text>",
                "tokens" : [</xsl:text>
                    <xsl:apply-templates select="$extracts"/>
                    <xsl:text>
                ]
                }</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:TEI|tei:teiHeader|tei:sourceDesc|tei:fileDesc|tei:listWit">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:encodingDesc|tei:revisionDesc|tei:titleStmt|tei:notesStmt|tei:publicationStmt|tei:witness[not(@corresp)]"/>
    <xsl:template match="tei:text"/><!-- provisional process for now: pass text as written by first scribe --><!-- override imported templates to remove deletion indicators or added text -->
    <xsl:template match="tei:del">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:add"/><!-- remove annotation of format etc -->
    <xsl:template match="tei:c">
        <xsl:apply-templates/>
    </xsl:template><!-- create JSON -->
    <xsl:template match="tei:w" mode="toJSON">
        <xsl:choose>
            <xsl:when test="tei:abbr">
                <xsl:variable name="id" select="@xml:id"/>
                <xsl:variable name="abbrStr"><!-- just in case there are residual apostrophes/quotes in abbreviations --><!-- NB, should at this point be geresh or double geresh -->
                    <xsl:variable name="targetStr">
                        <xsl:text>'"</xsl:text>
                    </xsl:variable>
                    <xsl:value-of select="translate(tei:abbr,$targetStr,'׳״')"/>
                </xsl:variable>
                <xsl:variable name="expanStr">
                    <xsl:for-each select="tokenize(tei:expan, ' ')">
                        <tkn>
                            <xsl:call-template name="regularize">
                                <xsl:with-param name="str" select="."/>
                            </xsl:call-template>
                        </tkn>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$expanStr/tkn">
                    <xsl:text>
{</xsl:text>
                    <xsl:text>"t" : "</xsl:text>
                    <xsl:choose>
                        <xsl:when test="not(preceding-sibling::tkn)">
                            <xsl:value-of select="$abbrStr"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>-</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>", "n" : "</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="not(preceding-sibling::tkn)">
                        <xsl:text>, "id" : "</xsl:text>
                        <xsl:value-of select="$id"/>
                        <xsl:text>"</xsl:text>
                    </xsl:if>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="following-sibling::tkn">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>
{</xsl:text>
                <xsl:text>"t" : "</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text>
                <xsl:text>, "n" : "</xsl:text>
                <xsl:call-template name="regularize">
                    <xsl:with-param name="str" select="."/>
                </xsl:call-template>
                <xsl:text>"</xsl:text>
                <xsl:text>, "id" : "</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>"</xsl:text>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="following-sibling::*[text()]">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template name="regularize">
        <xsl:param name="str"/>
        <xsl:variable name="testStr">
            <xsl:value-of select="translate(translate(replace($str, 'א$','ה'),'ם','ן'),'יו?', '')"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($testStr) &gt; 1">
                <xsl:value-of select="$testStr"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>