<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd its tei local" version="2.0" xmlns:local="local-functions.uri">

    <xsl:param name="ch" select="''"/>
    <xsl:param name="pg" select="''"/>
    <xsl:param name="col" select="''"/>
    <xsl:param name="mode" select="'pg'"/>
    <xsl:variable name="wit"
        select="tei:TEI/tei:teiHeader//tei:publicationStmt/tei:idno[@type='local']/text()"/>

    <xsl:param name="start">
        <!-- Select start node based on selected paramenters. On non-existant chs, pages, cols, goes to first in witness file. -->
        <xsl:choose>
            <xsl:when test="$mode = 'pg'">

                <xsl:choose>
                    <xsl:when test="//tei:pb[@xml:id = concat($wit,'.',$pg)]">
                        <xsl:value-of select="//tei:pb[@xml:id = concat($wit,'.',$pg)]/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="(//tei:pb)[1]/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'col'">
                <xsl:choose>
                    <xsl:when test="//tei:cb[@xml:id = concat($wit,'.',$col)]">
                        <xsl:value-of select="//tei:cb[@xml:id = concat($wit,'.',$col)]/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="(//tei:cb)[1]/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'ch' and //tei:div3[@xml:id = concat($wit,'.',$ch)]">
                <xsl:value-of select="//tei:div3[@xml:id = concat($wit,'.',$ch)]/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:param name="end">
        <!-- Assign end node as following pb or cb for page or column -->
        <xsl:choose>
            <xsl:when test="$mode = 'pg'">
                <xsl:choose>
                    <xsl:when test="//tei:pb[@xml:id = $start]/following::tei:pb[1]">
                        <xsl:value-of
                            select="//tei:pb[@xml:id = $start]/following::tei:pb[1]/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>null</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'col'">
                <xsl:choose>
                    <xsl:when
                        test="//tei:cb[@xml:id = $start]/following::tei:cb[1] &lt;&lt; //tei:cb[@xml:id = $start]/following::tei:pb[1]">
                        <xsl:value-of
                            select="//tei:cb[@xml:id = $start]/following::tei:cb[1]/@xml:id"/>
                    </xsl:when>
                    <xsl:when
                        test="//tei:cb[@xml:id = $start]/following::tei:cb[1] &gt;&gt; //tei:cb[@xml:id = $start]/following::tei:pb[1]">
                        <xsl:value-of
                            select="//descendant-or-self::tei:cb[@xml:id = $start]/following::tei:pb[1]/@xml:id"
                        />
                    </xsl:when>
                    <xsl:when
                        test="//tei:cb[@xml:id = $start]/following::tei:cb[1] and not(//tei:cb[@xml:id = $start]/following::tei:pb[1])">
                        <xsl:value-of
                            select="//tei:pb[@xml:id = $start]/following::tei:cb[1]/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>null</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'ch'">
                <xsl:value-of select="//div3[@xml:id = $start]/following-sibling::div3[1]"/>
            </xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:template match="/">
        <xsl:variable name="extract">
            <xsl:apply-templates mode="extract"/>
        </xsl:variable>
        <xsl:variable name="flat">
            <xsl:choose>
                <xsl:when test="$mode='col' or $mode='pg'">
                    <xsl:element name="div">
                        <xsl:attribute name="type">page</xsl:attribute>
                        <xsl:attribute name="n">
                            <xsl:if test="$mode='pg'"><xsl:value-of select="substring-after($start,concat($wit,'.'))"></xsl:value-of></xsl:if>
                            <xsl:if test="$mode='col'"><xsl:value-of select="substring-after(*/*/*//tei:cb[@xml:id=$start]/preceding-sibling::tei:pb[1]/@xml:id,concat($wit,'.'))"></xsl:value-of></xsl:if>
                        </xsl:attribute>
                        <xsl:apply-templates select="$extract/*" mode="flatten"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$mode='ch'">
                    <xsl:element name="div">
                        <xsl:attribute name="type">chap</xsl:attribute>
                        <xsl:attribute name="n" select="$start"/>
                        <xsl:copy-of
                            select="*/*/*/*/*/tei:div3[@xml:id = $start]/preceding::tei:pb[1]"/>
                        <xsl:copy-of
                            select="*/*/*/*/*/tei:div3[@xml:id = $start]/preceding::tei:cb[1]"/>
                        <xsl:copy-of select="*/*/*/*/*/tei:div3[@xml:id = $start]/*"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <TEI>

            <xsl:copy-of select="processing-instruction()"/>
            <xsl:copy-of select="tei:TEI/tei:teiHeader"/>
            <text>
                <body>
                    <xsl:choose>
                        <xsl:when test="$mode='pg' and $flat//tei:cb">
                            <!-- Chunked by page, original has multiple columns -->
                            <xsl:apply-templates select="$flat/tei:div" mode="two-cols"/>
                        </xsl:when>
                        <xsl:when test="$mode='pg' and not($flat//tei:cb)">
                            <!-- chunked by page, original has single column -->
                            <!-- Page is a single column page -->
                            <xsl:apply-templates select="$flat/tei:div" mode="one-col"/>
                        </xsl:when>
                        <xsl:when test="$mode='col'">
                            <!-- chunked by page, original has single column -->
                            <!-- Page is a single column page -->
                            <xsl:apply-templates select="$flat/tei:div" mode="sing-col"/>
                        </xsl:when>
                        <xsl:when test="$mode='ch'">
                            <!-- chunked by extracted chapter, presented in "compact" view-->
                            <xsl:copy-of select="$flat"></xsl:copy-of>
                        </xsl:when>
                    </xsl:choose>
                </body>
            </text>
        </TEI>
    </xsl:template>

    <!-- process the pages between endpoints in extract mode -->
    <!-- modifies a stylesheet written by Sebastian Rahtz -->
    <xsl:template match="text()" mode="extract">
        <xsl:choose>
            <xsl:when test="preceding::element()[@xml:id=$end]"> </xsl:when>
            <xsl:when test="following::element()[@xml:id=$start]"> </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="extract">
        <xsl:choose>
            <xsl:when test=".//element()[@xml:id=$start or @xml:id=$end]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="extract"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when
                test="following::element()[@xml:id=$end] and
                preceding::element()[@xml:id=$start]">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="preceding::element()[@xml:id=$start] and $end = 'null'">
                <xsl:copy-of select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Flatten mode: Convert numbered divs heads and trailers to milestones -->

    <xsl:template match="tei:div1" mode="flatten">

        <milestone>
            <xsl:attribute name="unit" select="name()"/>
            <xsl:attribute name="xml:id" select="concat('P_',@xml:id)"/>
        </milestone>
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="self::tei:div2|self::tei:head|self::tei:trailer">
                    <xsl:apply-templates select="." mode="flatten"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:div2" mode="flatten">
        <milestone>
            <xsl:attribute name="unit" select="name()"/>
            <xsl:attribute name="xml:id" select="concat('P_',@xml:id)"/>
        </milestone>
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="self::tei:div3|self::tei:head|self::tei:trailer">
                    <xsl:apply-templates select="." mode="flatten"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:div3" mode="flatten">
        <milestone>
            <xsl:attribute name="unit" select="name()"/>
            <xsl:attribute name="xml:id" select="concat('P_',@xml:id)"/>
        </milestone>
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="self::tei:ab|self::tei:head|self::tei:trailer">
                    <xsl:apply-templates select="." mode="flatten"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:ab" mode="flatten">
        <xsl:choose>
            <xsl:when test="preceding::element()[@xml:id=$end]"> </xsl:when>
            <xsl:when test="following::element()[@xml:id=$start]"> </xsl:when>
            <xsl:otherwise>
                <milestone>
                    <xsl:attribute name="unit" select="'ab'"/>
                    <xsl:attribute name="xml:id" select="concat('P_',@xml:id)"> </xsl:attribute>
                </milestone>
                <xsl:copy-of select="*|text()|comment()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:head|tei:trailer" mode="flatten">
        <xsl:choose>
            <xsl:when test="preceding::element()[@xml:id=$end]"> </xsl:when>
            <xsl:when test="following::element()[@xml:id=$start]"> </xsl:when>
            <xsl:otherwise>
                <label>
                    <xsl:copy-of select="node()"/>
                </label>
                
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Adjustments for pages with two columns -->
    <xsl:template match="tei:div" mode="two-cols">
        <!-- There has got to be a way not to copy element and attributes AGAIN -->
        <div>
            <xsl:copy-of select="@*"/>

            <xsl:for-each-group select="node()|text()" group-starting-with="tei:cb">
                <xsl:choose>
                    <xsl:when test="current-group()[self::tei:cb]">
                        <xsl:apply-templates select="." mode="two-cols"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Leaves fw and (perhaps) other nodes, except the milestones that correspond to order, tractate and chapter divisions outside the div organized by column-->
                        <xsl:copy-of select="current-group()[not(self::tei:milestone)]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    <xsl:template match="tei:cb" mode="two-cols">
        <div>
            <xsl:attribute name="type">column</xsl:attribute>
            <xsl:attribute name="n" select="substring-after(@xml:id,concat($wit,'.'))"/>
            <ab>
                <!-- Move the milestones that appear at the begining of the node sequence/page into the appropriate column. -->
                <xsl:if test="following::tei:cb">
                    <xsl:copy-of select="preceding::tei:milestone"/>
                </xsl:if>
                <xsl:copy-of select="current-group() except ."/>
            </ab>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:div" mode="sing-col">
        <!-- Original has multiple columns,view is chunked by single column -->
        <!-- Adjustment for single-column view of page with 2 columns -->
        <!-- There has got to be a way not to copy element and attributes AGAIN -->

        <div>
            <xsl:copy-of select="@*"/>
            <div>
                <xsl:attribute name="type">singCol</xsl:attribute>
                <xsl:attribute name="n" select="$col"></xsl:attribute>
                <ab>
                    <xsl:copy-of select="node()|text()"/>
                </ab>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:div" mode="one-col">
        <!-- original is a single column text -->
        <!-- There has got to be a way not to copy element and attributes AGAIN -->
        <div>
            <xsl:copy-of select="@*"/>
            <ab>
                <xsl:copy-of select="node()|text()"/>
            </ab>
        </div>
    </xsl:template>
</xsl:stylesheet>
