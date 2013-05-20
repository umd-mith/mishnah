<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
    exclude-result-prefixes="xs cx xd my xsl" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Get data from form output: to be modified following Travis's changes-->
    <xsl:param name="rqs"
        >mcite=4.2.2.1&amp;Kauf=6&amp;ParmA=5&amp;Camb=4&amp;Maim=3&amp;Paris=2&amp;Nap=1&amp;Vilna=&amp;Mun=&amp;Hamb=&amp;Leid=&amp;G2=&amp;G4=&amp;G6=&amp;G7=&amp;G1=&amp;G3=&amp;G5=&amp;G8=</xsl:param>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:variable name="cite" select="if (string-length($mcite) = 0) then '4.2.2.1' else $mcite"/>
    <xsl:template match="/site/tokens/tei:TEI/tei:text/tei:body/tei:div">
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:svg="http://www.w3.org/2000/svg"
            xmlns:math="http://www.w3.org/1998/Math/MathML"
            xmlns:xi="http://www.w3.org/2001/XInclude">
            <xsl:copy-of select="/site/tokens//tei:teiHeader"/>
            <text>
                <body>
                    <div>
                        <xsl:attribute name="n" select="@n"/>
                        <xsl:apply-templates/>
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="tei:ab">
        <xsl:variable name="n" select="@n"/>
        <xsl:variable name="coll-tokens" select="/site/collatex/cx:alignment/cx:row[@sigil = $n]"/>
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n" select="$n"/>
            <!-- copy non-<w> nodes at the begining of the rich tokens -->
            <xsl:copy-of
                select="/site/tokens/tei:TEI/tei:text/tei:body/tei:div/tei:ab[@n
                =$n]/tei:w[1]/preceding-sibling::node()"/>
            <xsl:for-each select="$coll-tokens/cx:cell">
                <!-- variables track position in $coll-tokens corresponding to the rich tokens
                    ($rich-pos) and actual position ($coll-pos) -->
                <xsl:variable name="rich-pos"
                    select="count(preceding-sibling::cx:cell[text() != '']) + 1"/>
                <xsl:variable name="coll-pos" select="count(preceding-sibling::cx:cell) +1"/>
                <xsl:choose>
                    <!-- Tests for empty cx:cell nodes empty, create an empty <w> in output -->
                    <!-- If not empty, copy existing <w> and add attribute @type -->
                    <xsl:when test="text() != ''">
                        
                        
                        <!-- But first, insert non-<w> nodes from rich tokens between current <w> and
                        preceding <w> -->
                        <!-- Uses Michael Kay's node set intersection: -->
                        <!--   $set1[count($set2|.)=count($set2)]  -->
                        <!-- set1: All the nodes following the preceding <w>-->
                        <xsl:variable name="set1"
                            select="/site/tokens/tei:TEI/tei:text/tei:body/tei:div/tei:ab[@n
                            = $n]/tei:w[$rich-pos - 1]/following-sibling::node()"/>
                        <!-- set2: All the nodes preceding the current <w> node -->
                        <xsl:variable name="set2"
                            select="/site/tokens/tei:TEI/tei:text/tei:body/tei:div/tei:ab[@n
                            = $n]/tei:w[$rich-pos]/preceding-sibling::node()"/>
                        <xsl:sequence select="$set1[count($set2|.)=count($set2)]"/>
                        
                        <!-- Now copy/transform the <w> nodes -->
                        <w>
                            <xsl:attribute name="n" select="$coll-pos"/>
                            <xsl:attribute name="type" select="./@state"/>
                            <xsl:copy-of
                                select="/site/tokens/tei:TEI/tei:text/tei:body/tei:div/tei:ab[@n
                            =$n]/tei:w[count(preceding-sibling::tei:w) + 1 = $rich-pos]/node() except ."
                            />
                        </w>
                    </xsl:when>
                    <xsl:when test="not(text() != '')">
                        <w>
                            <xsl:attribute name="n" select="$coll-pos"/>
                            <xsl:attribute name="type" select="./@state"/>
                            <xsl:copy-of select="./text()"/>
                        </w>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!-- copy non-<w> nodes at the end of the rich tokens -->
            <xsl:copy-of
                select="/site/tokens/tei:TEI/tei:text/tei:body/tei:div/tei:ab[@n
                =$n]/tei:w[last()]/following-sibling::node()"
            />
        </ab>
    </xsl:template>
    <!-- Templates to control limit what goes to output -->
    <xsl:template match="/site/tokens//tei:teiHeader"/>
    <xsl:template match="/site/collatex"/>
    <xsl:variable name="witlist">
        <xsl:variable name="params" select="my:parse-rqs($rqs)"/>
        <xsl:for-each select="$params/tei:sortWit[text()]">
            <xsl:sort select="@sortOrder"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
</xsl:stylesheet>
