<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="local-functions.uri" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="*:div">
        <div class="text" dir="rtl">
            <xsl:for-each select="tei:ab[1]/*">
                <xsl:choose>
                    <xsl:when test="self::tei:w and text() != ''">
                        <xsl:sequence select="text()"/>
                        <xsl:if test="not(following-sibling::element()[1][self::tei:pc])">
                            <xsl:text xml:space="preserve"> </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::tei:label">
                        <span class="label">
                            <xsl:value-of select="."/>
                            <xsl:text xml:space="preserve"> </xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:lb and @n mod 5 = 0">
                        <xsl:text> | </xsl:text>
                        <span xmlns="http://www.w3.org/1999/xhtml" class="lb">
                            <xsl:value-of select="@n"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:pb">
                        <xsl:text> ¶ </xsl:text>
                        <span class="page">
                            <xsl:value-of select="@n"/>
                            <xsl:if test="following-sibling::element()[1][self::tei:cb]">
                                <xsl:analyze-string select="following-sibling::tei:cb/@n" regex="^([0-9]{{1,3}})[rv]([AB])$">
                                    <xsl:matching-substring>
                                        <xsl:text xml:space="preserve"> </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:if>
                        </span>
                    </xsl:when>
                    <xsl:when test="self::tei:cb">
                        <xsl:if test="preceding-sibling::element()[1][not(self::tei:pb)]">
                            <xsl:text> | </xsl:text>
                            <span class="col">
                                <xsl:analyze-string select="@n" regex="^([0-9]{{1,3}}[rv])([AB])$">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)"/>
                                        <xsl:text xml:space="preserve"> </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </span>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::tei:pc[@type = 'unitEnd']">
                        <xsl:text>: </xsl:text>
                    </xsl:when>
                    <xsl:when test="self::tei:pc[@type = 'stop']">
                        <xsl:text>. </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>
    <xsl:template match="//tei:c | //tei:am | //tei:pc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="tei:teiHeader | tei:alignType | tei:unit | tei:mcite | tei:tractName | tei:rqs"/>
</xsl:stylesheet>