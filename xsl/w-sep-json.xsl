<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">

    <xsl:output indent="yes" encoding="UTF-8" media-type="txt/json" omit-xml-declaration="yes"/>
    <xsl:param name="mcite" select="'4.1.8.6'"/>
    <xsl:param name="wits" select="''" as="xs:string"/>

    <xsl:strip-space elements="*"/>
    <xsl:variable name="files" select="collection('../tei/w-sep/?select=*.xml')"/>
    <xsl:template match="/">
        <!-- first construct xml that will map to json -->
        <xsl:variable name="xml-for-json">
            <witnesses>
            <xsl:for-each select="$files/*[*/*/*/*/*/tei:ab[matches(@xml:id, concat($mcite, '$'))]]">
                <wit id="{//tei:idno[@type = 'local']}">
                    <!-- flatten to one level -->
                    <xsl:variable name="flattened">
                        <!-- preprocess all elements, leaving only milestone [for w start], -->
                        <!-- text, expan|orig, and delSpan|anchor addSpan|anchor -->
                        <wit id="{//tei:idno[@type='local']}">
                            <xsl:apply-templates select="//tei:ab[matches(@xml:id, concat($mcite, '$'))]/*"/>
                        </wit>
                    </xsl:variable>

                    <!-- create string of tokens that represents specific hand + additions to be unspliced -->
                    <!-- Can do this in multiple modes, for each embedded "witness"  -->
                    <!-- for now: one "witness" per document = h1, retaining original readings, rejecting additions -->
                    <xsl:variable name="to-unsplice">
                        <xsl:apply-templates mode="new-wit-h1" select="$flattened/node()"/>
                    </xsl:variable>

                    <!-- Remove unincluded hands -->
                    <!-- Here removing all text between addSpan and corresponding anchor -->
                    <xsl:variable name="unspliced">
                        <xsl:apply-templates mode="unsplice" select="$to-unsplice">
                            <!-- $hand can be used to disambiguate various "levels" in text -->
                            <xsl:with-param name="hand"/>
                        </xsl:apply-templates>
                    </xsl:variable>

                    <!-- Build json -->
                    <xsl:apply-templates select="$unspliced/*" mode="xml-for-json"/>
                </wit>
            </xsl:for-each>
        </witnesses>
        </xsl:variable>
        <xsl:apply-templates select="$xml-for-json" mode="build-json"/>
    </xsl:template>
    <xsl:template match="tei:lb | tei:cb | tei:pb | tei:note | tei:label | tei:pc | tei:surplus | tei:fw"/>
    <xsl:template match="tei:damageSpan | tei:anchor[@type = 'damage']"/>
    <xsl:template match="tei:choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:w">
        <xsl:text>
</xsl:text>
       <!--<xsl:variable name="id" select="@xml:id" as="xs:string"/>-->
        <milestone type="w">
           <xsl:attribute name="xml:id" select="@xml:id"/>
            <xsl:choose>
                <xsl:when test="tei:choice/tei:abbr">
                    <xsl:attribute name="abbr" select="'yes'"/>
                </xsl:when>
            </xsl:choose>
        </milestone>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:abbr | tei:orig">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:expan">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:reg"/>
    <xsl:template match="tei:span | tei:addSpan | tei:delSpan | tei:anchor[@type = 'add'] | tei:anchor[@type = 'del']">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="tei:delSpan | tei:anchor[@type = 'del']" mode="new-wit-h1"/>
    <xsl:template match="element()" mode="new-wit-h1">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="new-wit-h1"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()" mode="new-wit-h1">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- keep original writing, reject additions -->
    <!-- need to be refined further with respect to  -->
    <xsl:template match="tei:wit" mode="unsplice">
        <xsl:param name="hand"/>
        <wit>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="node()" group-starting-with="tei:addSpan">
                <xsl:choose>
                    <xsl:when test="current-group()[1][self::tei:addSpan]">
                        <!-- addition begins in this ab -->
                        <xsl:variable name="matchTo" select="substring-after(current-group()[1]/@spanTo, '#')"/>
                        <xsl:for-each-group select="current-group()" group-ending-with="tei:anchor[@xml:id = $matchTo]">
                            <xsl:choose>
                                <!-- whole addition is in this ab -->
                                <xsl:when test="current-group()[last()][self::tei:anchor[@xml:id = $matchTo]]">
                                    <!-- omit these -->
                                    <!-- !!! requires adjustment for when addition is split over a word, so: -->
                                    <!-- <xsl:when test="current-group()[self::tei:milestone]"/> -->
                                </xsl:when>
                                <!-- addition that ends in a susbsequent ab -->
                                <!-- any group starting with addSpan that is not part of the preceding group -->
                                <!-- does not have matching anchor in this ab -->
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
                        <!-- By definition, this group does not start with addSpan, -->
                        <!-- so do not need to check subsequently -->
                        <xsl:for-each-group select="current-group()" group-ending-with="tei:anchor[@type = 'add']">
                            <xsl:choose>
                                <!-- addition that begins in a prior ab -->
                                <xsl:when test="current-group()[last()][self::tei:anchor[@type = 'add']]">
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

    <xsl:template match="tei:wit" mode="xml-for-json">
        <xsl:apply-templates mode="xml-for-json"/>
    </xsl:template>
    <xsl:template match="tei:milestone" mode="xml-for-json">
        <xsl:variable name="testToNext">
            <xsl:variable name="temp">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::tei:milestone) &gt; 0">
                        <xsl:apply-templates select="                                 following-sibling::node()                                 intersect                                 following-sibling::tei:milestone[1]/preceding-sibling::node()" mode="token-text"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="following-sibling::node()" mode="token-text"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="translate(normalize-space($temp), ' ', '')"/>
        </xsl:variable>
        <xsl:variable name="reg">
            <xsl:variable name="temp">
                <xsl:choose>
                    <xsl:when test="@abbr = 'yes'">
                        <xsl:value-of select="normalize-space(following-sibling::tei:expan[1])"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(replace(normalize-unicode($testToNext, 'NFKD'), '[֑-ׇװ-״]', ''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- regularize -->
            <xsl:value-of select="replace(translate($temp, 'ן?יו', 'ם*'), '([א-ת]+?)א$', '$1ה')"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(normalize-space($testToNext))"><!-- omit this as having no text --></xsl:when>
            <xsl:when test="normalize-space($testToNext)">
                <!-- Include: has text -->
                <w>
                   
                   <xsl:attribute name="xml:id" select="@xml:id"/>
                   
                   <surface>
                        <xsl:value-of select="normalize-space($testToNext)"/>
                    </surface>
                    <reg>
                        <xsl:value-of select="$reg"/>
                    </reg>
                </w>

            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    Nodes in source doc not processed properly
                    <xsl:copy-of select="."/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" mode="xml-for-json"/>
    <xsl:template match="tei:expan | tei:reg" mode="token-text"/>
    
    <xsl:template match="tei:witnesses" mode="build-json">
        <xsl:text>{
"witnesses" : [
</xsl:text>
        <xsl:apply-templates mode="build-json"/>
        <xsl:text>
]
}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:wit" mode="build-json">
        <xsl:text>{
"id" : "</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>",
"tokens" : [</xsl:text>
        <xsl:apply-templates mode="build-json"/>
        <xsl:text>
]
}</xsl:text>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
    <xsl:template match="tei:w" mode="build-json">
        <xsl:choose>
            <xsl:when test="tei:surface[not(normalize-space())]">
                <!-- skip empty <w>s -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- check for multi-word expansions -->
                    <xsl:when test="contains(tei:reg,' ')">
                        <xsl:variable name="token">
                            <xsl:copy-of select="."/>
                        </xsl:variable>
                        <xsl:for-each select="tokenize(normalize-space(tei:reg), ' ')">
                            <xsl:text>
{ "t" : "</xsl:text>
                            <xsl:value-of select="if (position()=1) then $token/tei:w/tei:surface else '-'"/>
                            <xsl:text>", "n" : "</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:if test="position()=1">
                                <xsl:text>", "id" : "</xsl:text>
                            <xsl:value-of select="$token/tei:w/@id"/>
                            </xsl:if>
                            <xsl:text>" }</xsl:text>
                            <xsl:if test="position()!=last()">,</xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>
{ "t" : "</xsl:text>
                        <xsl:value-of select="tei:surface"/>
                        <xsl:text>", "n" : "</xsl:text>
                        <xsl:value-of select="tei:reg"/>
                        <xsl:text>", "id" : "</xsl:text>
                        <xsl:value-of select="@id"/>
                        <xsl:text>" }</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:variable name="following-text">
                    <xsl:value-of select="following-sibling::tei:w/tei:reg"/>
                </xsl:variable>
                <xsl:if test="position()!= last() and normalize-space($following-text)">,</xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>