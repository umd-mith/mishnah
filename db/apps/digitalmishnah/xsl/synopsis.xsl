<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
<xsl:template match="tei:ab">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:w">
        <xsl:if test="preceding-sibling::tei:w">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
<!--        <xsl:for-each select="node()">-->
<!--            <xsl:choose>-->
<!--                <xsl:when test="self::text()">-->
<!--                    <xsl:value-of select="normalize-space(.)"/>-->
<!--                </xsl:when>-->
<!--                <xsl:when test="self::tei:lb">-->
<!--                    <xsl:choose>-->
<!--                        <xsl:when test="@n mod 10 = 0">-->
<!--                            <span xmlns="http://www.w3.org/1999/xhtml" class="lb10-intra"/>-->
<!--                        </xsl:when>-->
<!--                        <xsl:otherwise>-->
<!--                            <span xmlns="http://www.w3.org/1999/xhtml" class="lb-intra"/>-->
<!--                        </xsl:otherwise>-->
<!--                    </xsl:choose>-->
<!--                </xsl:when>-->
<!--                <xsl:when test="self::tei:pb">-->
<!--                    <span class="{name(.)}">-->
<!--                        <xsl:value-of select="@xml:id"/>-->
<!--                    </span>-->
<!--                </xsl:when>-->
<!--            </xsl:choose>-->
<!--        </xsl:for-each>-->
    </xsl:template>
    <xsl:template match="tei:label">
        <span xmlns="http://www.w3.org/1999/xhtml" class="label">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
<!--    <xsl:template match="//tei:del">-->
<!--        <span xmlns="http://www.w3.org/1999/xhtml" class="del">-->
<!--            <xsl:value-of select="."/>-->
<!--        </span>-->
<!--    </xsl:template>-->
<!--    <xsl:template match="tei:add">-->
<!--        <span xmlns="http://www.w3.org/1999/xhtml" class="add">-->
<!--            <xsl:value-of select="."/>-->
<!--        </span>-->
<!--    </xsl:template>-->
    <xsl:template match="delSpan">
        <span xmlns="http://www.w3.org/1999/xhtml" class="del-synops" dir="rtl">
            <xsl:text>(</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="tei:addSpan">
        <span xmlns="http://www.w3.org/1999/xhtml" class="add-synops" dir="rtl">
            <xsl:text>[</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="tei:anchor">
        <xsl:choose>
            <xsl:when test="@type='add'">
                <span xmlns="http://www.w3.org/1999/xhtml" class="add-synops" dir="rtl">
                    <xsl:text>]</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@type='del'">
                <span xmlns="http://www.w3.org/1999/xhtml" class="del-synops" dir="rtl">
                    <xsl:text>)</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@type='damage'">
                <span xmlns="http://www.w3.org/1999/xhtml" class="dam-synops" dir="rtl">
                    <xsl:text>&gt;</xsl:text>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:cb">
        <span xmlns="http://www.w3.org/1999/xhtml" class="cb">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:pb">
        <span xmlns="http://www.w3.org/1999/xhtml" class="pb">
            <xsl:value-of select="translate(substring-after(@xml:id,'.'),'_', ':')"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:choice">
        <xsl:value-of select="tei:abbr"/>
    </xsl:template>
<!--    <xsl:template match="tei:lb[not(parent::tei:w)]">-->
<!--        <xsl:choose>-->
<!--            <xsl:when test="@n mod 10 = 0">-->
<!--                <span xmlns="http://www.w3.org/1999/xhtml" class="lb10"/>-->
<!--            </xsl:when>-->
<!--            <xsl:otherwise>-->
<!--                <span xmlns="http://www.w3.org/1999/xhtml" class="lb"> </span>-->
<!--            </xsl:otherwise>-->
<!--        </xsl:choose>-->
<!--    </xsl:template>-->
    <xsl:template match="tei:lb">
        <xsl:choose>
            <xsl:when test="@n mod 10 = 0">
                <span xmlns="http://www.w3.org/1999/xhtml" class="lb10"/>
            </xsl:when>
            <xsl:otherwise>
                <span xmlns="http://www.w3.org/1999/xhtml" class="lb"> </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:surplus">
        <span xmlns="http://www.w3.org/1999/xhtml" class="surplus">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <xsl:template match="tei:c | tei:am">
        <xsl:apply-templates/>
    </xsl:template>
     <xsl:template match="tei:pc">
        <xsl:value-of select="if (@unit = 'stop') then '. ' else if (@unit='unitEnd') then ': ' else ' '"/>
    </xsl:template>
    <xsl:template match="tei:damageSpan">
        <span xmlns="http://www.w3.org/1999/xhtml" class="damage-synops" dir="rtl">
            <xsl:text>&lt;</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="//tei:unclear">
        <span xmlns="http://www.w3.org/1999/xhtml" class="unclear-synops" dir="rtl">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:note"/>
    <xsl:template match="tei:addSpan[@type='comm']"/>
    <xsl:template match="tei:teiHeader | tei:alignType | tei:unit | tei:mcite | tei:tractName | tei:rqs"/>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
</xsl:stylesheet>