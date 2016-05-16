<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0" >
    
    <xsl:output indent="yes" encoding="UTF-8" media-type="txt/json" omit-xml-declaration="yes"/>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:param name="wits" select="''" as="xs:string"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="files" select="collection('../tei/w-sep/?select=*.xml')"/>
    <xsl:template match="/">
        <xsl:text>{&#xa;"witnesses": [&#xa;</xsl:text>
            <xsl:for-each select="$files/*">
                <xsl:if test="position()!=1">,</xsl:if>
                <!-- flatten to one level -->
                <xsl:variable name="flattened">
                    <xsl:if test="//tei:ab[matches(@xml:id, concat($mcite, '$'))]">
                        <wit id="{//tei:idno[@type='local']}">
                            <xsl:apply-templates
                                select="//tei:ab[matches(@xml:id, concat($mcite, '$'))]/*"/>
                        </wit>
                    </xsl:if>
                </xsl:variable>
                <!-- for now: one "witness" per document, retaining original readings, rejecting additions -->
                <xsl:variable name="group-on-w">
                    <xsl:apply-templates select="$flattened/tei:wit" mode="wit-h1"/>
                </xsl:variable>
                <xsl:text>{&#xa;"id" : "</xsl:text><xsl:value-of select="//tei:idno[@type='local']"/><xsl:text>",</xsl:text>
                <xsl:text>&#xa;"tokens" :[</xsl:text>
                <xsl:apply-templates select="$group-on-w/tei:wit/node()" mode="wit-h1"/>
                <xsl:text>&#xa;]&#xa;}&#xa;</xsl:text>
            </xsl:for-each>
        <xsl:text>]&#xa;}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:lb | tei:cb | tei:pb"/>
    <xsl:template match="tei:damageSpan | tei:anchor[@type = 'damage']"/>
    <xsl:template match="tei:w">
        <xsl:text>&#xa;</xsl:text>
        <milestone type="w" xml:id="{@xml:id}">
            <xsl:choose>
                <xsl:when test="tei:abbr">
                    <xsl:attribute name="abbr" select="'yes'"/>
                </xsl:when>
                <xsl:when test="tei:orig">
                    <xsl:attribute name="orig" select="'yes'"/>
                </xsl:when>
            </xsl:choose>
        </milestone>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:abbr | tei:orig">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:expan | tei:reg">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="tei:span | tei:addSpan | tei:delSpan | tei:anchor[@type = 'add'] | tei:anchor[@type = 'del']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- witness h1: keep original writing, reject additions -->
    <xsl:template match="tei:wit" mode="wit-h1">
        <wit>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="node()" group-starting-with="tei:addSpan">
                <xsl:choose>
                    <xsl:when test="current-group()[1][self::tei:addSpan]">
                        <!-- addition begins in this ab -->
                        <xsl:variable name="matchTo"
                            select="substring-after(current-group()[1]/@spanTo, '#')"/>
                        <xsl:for-each-group select="current-group()"
                            group-ending-with="tei:anchor[@xml:id = $matchTo]">
                            <xsl:choose>
                                <!-- whole addition is in this ab -->
                                <xsl:when
                                    test="current-group()[last()][self::tei:anchor[@xml:id = $matchTo]]">
                                    <!-- omit these -->
                                </xsl:when>
                                <!-- addition that ends in a susbsequent ab -->
                                <xsl:when test="current-group()[1][self::tei:addSpan]">
                                    <!-- omit these -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- group on words -->
                                    <xsl:copy-of select="current-group()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </xsl:when>

                    <xsl:otherwise>
                        <!-- this group does not start with addSpan, do not need to check subsequently -->
                        <xsl:for-each-group select="current-group()"
                            group-ending-with="tei:anchor[@type = 'add']">
                            <xsl:choose>
                                <!-- addition that begins in a prior ab -->
                                <xsl:when
                                    test="current-group()[last()][self::tei:anchor[@type = 'add']]">
                                    <!-- omit these -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="current-group()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </wit>
    </xsl:template>

    <xsl:template match="tei:delSpan | tei:anchor[@type = 'del']" mode="wit-h1"/>
    <xsl:template match="tei:milestone" mode="wit-h1">

        <xsl:variable name="testToNext">
            <xsl:variable name="temp">
                <xsl:apply-templates
                    select="
                        following-sibling::node()
                        intersect
                        following-sibling::tei:milestone[1]/preceding-sibling::node()"
                    mode="token-text"/>
            </xsl:variable>
            <xsl:value-of select="translate(normalize-space($temp),' ','')"/>
        </xsl:variable>
        <xsl:variable name="testToLast">
            <xsl:variable name="temp">
                <xsl:apply-templates
                    select="
                        (((.[not(following-sibling::tei:milestone)] | following-sibling::node()[last()])
                        intersect
                        (.[not(following-sibling::tei:milestone)]/following-sibling::node()[last()] | following-sibling::node()[last()]/preceding-sibling::node())))"
                />
            </xsl:variable>
            <xsl:value-of select="translate(normalize-space($temp),' ','')"/>
        </xsl:variable>
        <xsl:variable name="reg">
            <xsl:variable name="temp">
                <xsl:choose>
                    <xsl:when test="@abbr = 'yes'">
                        <xsl:value-of select="normalize-space(following-sibling::tei:expan[1])"/>
                    </xsl:when>
                    <xsl:when test="@orig = 'yes'">
                        <xsl:value-of select="normalize-space(following-sibling::tei:reg[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="
                                if (normalize-space($testToNext)) then
                                    normalize-space($testToNext)
                                else
                                    normalize-space($testToLast)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- regularize -->
            <xsl:value-of select="replace(translate($temp, 'ן?יו', 'ם*'),'([א-ת]+?)א$','$1ה')"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(normalize-space($testToNext)) and not(normalize-space($testToLast))"
                ><!-- omit this as having no text --></xsl:when>
            <xsl:when test="normalize-space($testToNext) or normalize-space($testToLast)">
                <!-- Include: has text -->
                <xsl:text>&#xa;{"t": "</xsl:text>
                <xsl:value-of
                    select="
                        if (normalize-space($testToNext)) then
                            (normalize-space($testToNext))
                        else
                            normalize-space($testToLast)"/>
                <xsl:text>", "n": "</xsl:text>
                <xsl:value-of select="$reg"/>
                <xsl:text>", "id": "</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>"}</xsl:text>
                <!-- look to the end -->
                <xsl:variable name="lookToEnd">
                    <xsl:variable name="temp"><xsl:apply-templates select="following-sibling::tei:milestone[1]/following-sibling::node()
                        intersect
                        following-sibling::tei:milestone[1]/following-sibling::node()[last()]/preceding-sibling::node()" mode="token-text"/></xsl:variable>
                    <xsl:value-of select="normalize-space($temp)"/>
                </xsl:variable>
                    <!-- determine if this is the last word  -->
                    <xsl:if test="normalize-space($lookToEnd)">,</xsl:if>
                
                <xsl:apply-templates mode="wit-h1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:expan | tei:reg" mode="wit-h1 token-text"/>
    <xsl:template match="element()" mode="wit-h1">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()" mode="wit-h1"/>
    <xsl:template match="text()" mode="token-text">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
