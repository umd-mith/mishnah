<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its tei" version="2.0">

    <xsl:output encoding="UTF-8" indent="no"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 24, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:body">
        <!-- Wraps whole body in div and p to create valid tei/xml on output -->
        <body>
            <div class="container">
                <p class="temp">
                    <xsl:apply-templates/>
                </p>
            </div>
        </body>
    </xsl:template>
    <!-- Moves pb and cb to first position -->
    <!-- Not sure this is the best way to do this -->
    <xsl:template match="tei:div1[position()=1]">
        <pb>
            <xsl:attribute name="n">
                <xsl:value-of select=" descendant-or-self::tei:pb[1]/@n"/>
            </xsl:attribute>
        </pb>
        <xsl:if test="//tei:cb">
            <cb>
                <xsl:attribute name="n">
                    <xsl:value-of select=" descendant-or-self::tei:cb[1]/@n"/>
                </xsl:attribute>
            </cb>
        </xsl:if>
        <milestone unit="Order">
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
        </milestone>
        <xsl:text>1&#160;&#160;&#160;&#160;&#160;</xsl:text>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:pb[not(preceding::tei:pb)]"> </xsl:template>
    <xsl:template match="tei:cb[not(preceding::tei:cb)]"> </xsl:template>
    <xsl:template match="tei:pb[preceding::tei:pb]">
        <xsl:if test="not(following::tei:cb)">
            <xsl:copy-of select="."/>
            <xsl:text>1&#160;&#160;&#160;&#160;&#160;</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:cb[preceding::tei:cb]">
        <xsl:copy-of select="."/>
        <xsl:text>1&#160;&#160;&#160;&#160;&#160;</xsl:text>
    </xsl:template>
    <xsl:template match="tei:div1[not(position()=1)]">
        <milestone unit="Order">
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
        </milestone>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:div2">
        <milestone unit="Tractate">
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
        </milestone>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:div3">
        <milestone unit="Chapter">
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
        </milestone>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:ab">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>]</xsl:text>
        <milestone unit="ab">
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
        </milestone>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:head">
        <label>
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
            <xsl:copy-of select="node()"/>
        </label>
    </xsl:template>
    <xsl:template match="tei:trailer">
        <label>
            <xsl:attribute name="xml:id">P_<xsl:value-of select="@xml:id"/></xsl:attribute>
            <xsl:copy-of select="node()"/>
        </label>
    </xsl:template>
    <xsl:template match="tei:add">
        <xsl:variable name="count">
            <xsl:number/>
        </xsl:variable>
        <xsl:choose>

            <xsl:when test="@place='margin-right'">
                <above>
                    <xsl:value-of select="$count"/>
                </above>
                <right>
                    <above>
                        <xsl:value-of select="$count"/>
                    </above>
                    <xsl:apply-templates/>
                </right>
            </xsl:when>
            <xsl:when test="@place='margin-left'">
                <above>
                    <xsl:value-of select="$count"/>
                </above>
                <left>
                    <above>
                        <xsl:value-of select="$count"/>
                    </above>
                    <xsl:apply-templates/>
                </left>
            </xsl:when>
            <xsl:when test="@place='above'">
                <above>
                    <xsl:apply-templates/>
                </above>
            </xsl:when>
            <xsl:otherwise>
                <add>
                    <xsl:apply-templates/>
                </add>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:gap[@reason='Maimonides']">
        <xsl:if test="@unit='chars'">
            <span dir="lro">[char <xsl:value-of select="@extent"/>]</span>
        </xsl:if>
        <xsl:if test="@unit='lines'">
            <span dir="lro">[<xsl:value-of select="@extent"/> ln]</span>
            <lb/>
        </xsl:if>

    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:if test="@break">-</xsl:if>
        <xsl:choose>
            <xsl:when test="@n">
                <xsl:copy-of select="."/>
                <xsl:variable name="n" as="xs:integer" select="@n"/>
                <xsl:if test="following::tei:lb[@n][1]/@n != 1">
                    <xsl:value-of select="$n + 1"/>
                    <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <lb/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:milestone">*</xsl:template>
    <xsl:template match="tei:space">&#160;[vac <xsl:value-of select="@extent"
        />]&#160;</xsl:template>
    <xsl:template match="tei:listTranspose"/>
    <xsl:template match="tei:metamark[following-sibling::tei:listTranspose]">
        <above>
            <xsl:choose>
                <xsl:when test="text()">(<xsl:value-of select="."/>)</xsl:when>
                <xsl:otherwise>(<xsl:number/>)</xsl:otherwise>
            </xsl:choose>
        </above>
    </xsl:template>

</xsl:stylesheet>
