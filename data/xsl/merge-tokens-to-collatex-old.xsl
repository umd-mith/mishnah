<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd cx tei my" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Get data from form output: to be modified following Travis's changes-->
    <xsl:variable name="sortlist">
        <tei:list>
            <xsl:copy-of
                select="document('../tei/test-reflist-for-tokenizing.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item"
            />
        </tei:list>
    </xsl:variable>
    <xsl:variable name="numb-of-wits">
        <xsl:value-of select="count($sortlist/tei:list/tei:item)"/>
    </xsl:variable>
    <!-- Copy collatex output into variable for easy reference -->
    <xsl:variable name="collation-output">
        <xsl:copy-of select="document('../tei/collate-demo-output.xml')"/>
    </xsl:variable>
    <xsl:variable name="numb-of-rdgs">
        <xsl:value-of
            select="count($collation-output/cx:alignment/cx:row[@sigil =
        $sortlist/tei:list/tei:item[1]]/cx:cell)"
        />
    </xsl:variable>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div">
        <xsl:for-each select="tei:ab">
            <xsl:variable name="tokens">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <!-- Template in merge mode: Compare $tokens and $collation-output at each position -->
            <!-- If the readings agree -->
            <!--    copy tei:w to result tree -->
            <!--    advance to next position -->
            <!-- If the readings do not [i.e., $collation-output has a null] -->
            <!--    write a new, empty <w> to tree -->
            <!--    check next $coll-position in $collation-output while holding position() in $tokens
                    constant -->
            <!--  -->
            <!--  -->
            <ab>
                <xsl:attribute name="n" select="@n"/>
                <xsl:call-template name="merge">
                    <xsl:with-param name="tokens" select="$tokens"/>
                    <xsl:with-param name="sigil" select="@n"/>
                </xsl:call-template>
            </ab>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="merge">
        <xsl:param name="sigil"/>
        <xsl:param name="position-cx" select="0"/>
        <xsl:param name="tokens"/>
        <xsl:for-each select="$tokens/tei:ab/node()">
            <xsl:choose>
                <xsl:when test="self::tei:w">
                    <xsl:call-template name="compare">
                        <xsl:with-param name="sigil" select="$sigil"/>
                        <xsl:with-param name="position-cx" select="1"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!--<xsl:value-of
            select="$collation-output/cx:alignment/cx:row[@sigil = $sigil]/cx:cell[
            $position-cx + 16]"/>:<xsl:value-of
                select="$tokens/tei:ab/tei:w[count(preceding-sibling::tei:w) + 16]/tei:reg"/>-->
    </xsl:template>
    <xsl:template name="compare">
        <xsl:param name="position-cx" as="xs:double"/>
        <xsl:param name="sigil"/>
<!--        <xsl:variable name="position-rich" select="count(preceding-sibling::tei:w) + 1"/>
            [<xsl:value-of select="$position-cx"/>] <xsl:if test="$position-cx &lt; $numb-of-rdgs">
            <xsl:choose>
                <xsl:when
                    test="$collation-output/cx:alignment/cx:row[@sigil = $sigil]/cx:cell[
                $position-cx] = tei:reg">
                    <YUP>
                        <xsl:value-of select="$sigil"/> Collatex-output: <xsl:value-of
                            select="$position-cx"/><xsl:value-of
                            select="$collation-output/cx:alignment/cx:row[@sigil = $sigil]/cx:cell[
                                $position-cx]"
                        /><xsl:text>
                            
                        </xsl:text>
                        Rich-tokens: <xsl:value-of select="$position-rich"/><xsl:value-of
                            select="tei:reg"
                        /><xsl:text>
                            
                        </xsl:text>
                    </YUP><xsl:text>
                        
                    </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <NOPE><xsl:value-of select="$position-cx"/><xsl:value-of select="$sigil"/>
                        Collatex-output: <xsl:value-of select="$position-cx"/><xsl:value-of
                            select="$collation-output/cx:alignment/cx:row[@sigil = $sigil]/cx:cell[
                            $position-cx]"
                        /><xsl:text>
                            
                        </xsl:text>
                        Rich-tokens: <xsl:value-of select="$position-rich"/><xsl:value-of
                            select="tei:reg"
                        /><xsl:text>
                            
                        </xsl:text></NOPE>
                    <xsl:call-template name="compare">
                        <xsl:with-param name="position-cx" select="number($position-cx) + 1"/>
                        <xsl:with-param name="sigil" select="$sigil"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>-->
    </xsl:template>
    <xsl:template name="add-one">
        <xsl:param name="count"> </xsl:param>
        <xsl:value-of select="$count + 1"/>
    </xsl:template>
</xsl:stylesheet>
