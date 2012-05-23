<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
    exclude-result-prefixes="xs cx xd my xsl" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Get data from form output: to be modified following Travis's changes-->
   <xsl:param name="rqs">mcite=4.2.2.1&amp;Kauf=6&amp;ParmA=5&amp;Camb=4&amp;Maim=3&amp;Paris=2&amp;Nap=1&amp;Vilna=&amp;Mun=&amp;Hamb=&amp;Leid=&amp;G2=&amp;G4=&amp;G6=&amp;G7=&amp;G1=&amp;G3=&amp;G5=&amp;G8=</xsl:param>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:variable name="cite" select="if (string-length($mcite) = 0) then '4.2.2.1' else $mcite"/>
    
    <xsl:variable name="witlist">
        <xsl:variable name="params">
            <xsl:call-template name="tokenize-params">
                <xsl:with-param name="src" select="$rqs"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$params/tei:sortWit[text()]">
            <xsl:sort select="@sortOrder"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    

    <!-- Copy collatex output into variable for easy reference -->
    <xsl:variable name="collation-output">
        <xsl:copy-of select="site/*/cx:alignment"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
   <!-- Do not copy collatex output to result document -->
    <xsl:template match="/site/collatex"></xsl:template>
    <!-- Copy only children of site and of site/tokens, not the nodes themselves -->
     <xsl:template match="/site/tokens | /site"><xsl:apply-templates/></xsl:template>
    <xsl:template match="/site/tokens/tei:TEI/tei:text/tei:body/tei:div">
        <div xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n" select="@n"/>
            <xsl:for-each select="tei:ab">
                <xsl:variable name="tokens">
                    <xsl:copy-of select="."/>
                </xsl:variable>
                <ab>
                    <xsl:attribute name="n" select="@n"/>
                    <xsl:variable name="merged">
                        <xsl:variable name="n" select="@n"> </xsl:variable>
                        <!-- Variables for merging rich tokenization collatex output -->
                        <!-- Rich tokenization output -->
                        <xsl:variable name="tokens">
                            <xsl:sequence select="."/>
                        </xsl:variable>
                        <!-- For each empty cell in collation output that is single
                    or first in a series ... [Should be moved to a template]-->
                        <xsl:for-each
                            select="$collation-output/cx:alignment/cx:row[@sigil =
                    $n]/cx:cell[. = '' and preceding-sibling::element()[1] != '']">
                            <!-- position in rich-tokenization: should equal number of 
                        non-empty preceding cells -->
                            <xsl:variable name="rich-pos" as="xs:integer">
                                <xsl:sequence
                                    select="count(preceding-sibling::cx:cell[not(. =
                        '')])"
                                />
                            </xsl:variable>
                           
                            <!-- number of all preceding cells: should equal position in
                        collation output -->
                            <xsl:variable name="coll-pos" select="count(preceding-sibling::cx:cell)"
                                as="xs:integer"/>
                            <!-- Starting position of of a string of tei:w, corresponding to a string of
                        uninterrupted non-empty cx:cells in collation output  -->
                            <xsl:variable name="start-str" as="xs:integer">
                                <!-- Uses Michael Kay's node set intersection: 
                                    $set1[count($set2|.)=count($set2)]  -->
                                <xsl:choose>
                                    <!-- If starting position is not first node-->
                                    <xsl:when test="preceding-sibling::cx:cell = ''">
                                        <!-- set1: all the nodes following the first 
                                            preceding empty node -->
                                        <xsl:variable name="set1"
                                            select="preceding-sibling::cx:cell[not(. !=
                                '')][1]/following-sibling::cx:cell"/>
                                        <!-- set2: all the nodes preceding current 
                                            that are not empty -->
                                        <xsl:variable name="set2"
                                            select="preceding-sibling::cx:cell[. != '']"/>
                                        <xsl:sequence
                                            select="$rich-pos -
                                    count($set1[count($set2|.)=count($set2)]) + 1"/>
                                        <!-- NB add 1 to correct -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- If it is the first node -->
                                        <xsl:sequence select="1"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <!--  Number of empty cells singly or in series-->
                            <xsl:variable name="null-str" as="xs:integer">
                                <!-- Uses same method as $start-str -->
                                <xsl:choose>
                                    <!-- If the null is a singleton -->
                                    <xsl:when
                                        test="not(count(following-sibling::cx:cell[. = '']) =
                                count(following-sibling::cx:cell)) and
                                following-sibling::cx:cell[1] != ''">
                                        <xsl:sequence select="1"/>
                                    </xsl:when>
                                    <!-- When the empty cell is the last empty cell in collation output-->
                                    <xsl:when
                                        test="count(following-sibling::cx:cell[. = '']) =
                                count(following-sibling::cx:cell)">
                                        <xsl:sequence select="count(following-sibling::cx:cell)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- set1: all the nodes preceding the next non-empty node
                                -->
                                        <xsl:variable name="set1"
                                            select="following-sibling::cx:cell[not(. =
                                    '')][1]/preceding-sibling::cx:cell"/>
                                        <!-- set2: all the nodes following the current that are empty -->
                                        <xsl:variable name="set2"
                                            select="following-sibling::cx:cell[. = '']"/>
                                        <xsl:sequence
                                            select="
                                    count($set1[count($set2|.)=count($set2)]) +1 "/>
                                        <!-- NB add 1 to correct -->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:if test="$start-str = 1">
                                <xsl:copy-of
                                    select="$tokens/tei:ab/tei:w[$start-str]/preceding-sibling::element()"
                                />
                            </xsl:if>
                            <xsl:copy-of select="$tokens/tei:ab/tei:w[$start-str]"/>
                            <xsl:variable name="set1"
                                select="$tokens/tei:ab/tei:w[$start-str]/following-sibling::element()"/>
                            <xsl:variable name="set2"
                                select="$tokens/tei:ab/tei:w[$rich-pos]/preceding-sibling::element()"/>
                            <xsl:copy-of select="$set1[count($set2|.)=count($set2)]"/>
                            <xsl:if test="$rich-pos &gt; 1"><xsl:copy-of
                                select="$tokens/tei:ab/tei:w[$rich-pos]"/></xsl:if>
                            <xsl:for-each select="1 to $null-str">
                                <w/>
                            </xsl:for-each>
                        </xsl:for-each>
                        <!-- Starting position in rich output of final string of tei:w, corresponding
                        uninterrupted non-empty cx:cells in collation output  -->
                        <xsl:variable name="final-str-start">
                            <xsl:sequence
                                select="count($collation-output/cx:alignment/cx:row[@sigil =
                        $n]/cx:cell[. != '']) - count($collation-output/cx:alignment/cx:row[@sigil =
                        $n]/cx:cell[position() = last()]/preceding-sibling::cx:cell[. =
                        ''][1]/following-sibling::cx:cell) + 1"
                            />
                        </xsl:variable>
                        <xsl:sequence
                            select="$tokens/tei:ab[@n = $n]/tei:w[position() =
                    $final-str-start - 1]/following-sibling::element()"
                        />
                    </xsl:variable>
                    <xsl:variable name="sigil" select="@n"></xsl:variable>
                    
                    <xsl:apply-templates select="$merged/element()[1]"
                        mode="finalPass"><xsl:with-param name="sigil" select="$sigil"/></xsl:apply-templates>
                </ab>
            </xsl:for-each>
        </div>
    </xsl:template>
    <xsl:template match="element()" mode="finalPass">
        <xsl:param name="sigil"></xsl:param>

        <xsl:choose>
            <xsl:when test="self::tei:w">
                <xsl:variable name="position" select="count(preceding-sibling::tei:w) + 1"></xsl:variable>
                <w xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type" select="$collation-output/cx:alignment/cx:row[@sigil =
                        $sigil]/cx:cell[position() = $position]/@state"></xsl:attribute><xsl:value-of select="text()"/>
                    <xsl:for-each select="element()">
                        <xsl:element name="{name()}"><xsl:value-of select="text()"/></xsl:element>
                    </xsl:for-each></w>
                <xsl:apply-templates select="following-sibling::element()[1]"
                    mode="finalPass"><xsl:with-param name="sigil" select="$sigil"></xsl:with-param></xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
                <xsl:apply-templates select="following-sibling::element()[1]"
                    mode="finalPass"><xsl:with-param name="sigil" select="$sigil"></xsl:with-param></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="tokenize-params">
        <xsl:param name="src"/>
        <xsl:choose>
            <xsl:when test="contains($src,'&amp;')">
                <!-- build first token element -->
                <xsl:if test="not(contains(substring-before($src,'&amp;'),'mcite'))">
                    <sortWit>
                        <xsl:attribute name="sortOrder">
                            <xsl:choose>
                                <xsl:when
                                    test="substring-after(substring-before($src,'&amp;'),'=')
                                    =''">
                                    <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="substring-after(substring-before($src,'&amp;'),'=')"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="substring-before(substring-before($src,'&amp;'),'=')"
                        />
                    </sortWit>
                </xsl:if>
                <!-- recurse -->
                <xsl:call-template name="tokenize-params">
                    <xsl:with-param name="src" select="substring-after($src,'&amp;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- last token, end recursion -->
                <sortWit>
                    <xsl:attribute name="sortOrder">
                        <xsl:choose>
                            <xsl:when
                                test="substring-after($src,'=')
                                =''">
                                <xsl:value-of select="0"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after($src,'=')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before($src,'=')"/>
                </sortWit>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
