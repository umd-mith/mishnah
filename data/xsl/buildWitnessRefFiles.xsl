<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="local-functions.uri"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs my tei" version="2.0">
    <xsl:output encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="path2T" select="'tei/t/'"/>
    <xsl:param name="wit" select="'P00005'"/>
    <xsl:variable name="root" select="/"/>
    <xsl:variable name="path2Div2"
        select="concat('../', $path2T, $wit, '/?select=', $wit, '*.xml;on-error=warning')"/>

    <xsl:variable name="tracts" select="collection($path2Div2)"/>
    <xsl:template match="my:struct">
        <TEI>
            <teiHeader>
                <xsl:comment>Place holder header for the Tosefta Files</xsl:comment>
                <fileDesc>
                    <titleStmt>
                        <title>Text of Tosefta from <xsl:choose><xsl:when test="$wit = 'S00040'">
                                    the Vienna MS (<xsl:value-of select="$wit"
                                    />)</xsl:when><xsl:when test="$wit = 'S01068'"> the London MS
                                        (<xsl:value-of select="$wit"/>)</xsl:when><xsl:when
                                    test="$wit = 'S07055'"> the Erfurt MS (<xsl:value-of
                                        select="$wit"/>)</xsl:when><xsl:when test="$wit = 'P0005'">
                                    the editio Princeps (<xsl:value-of select="$wit"
                                />)</xsl:when></xsl:choose></title>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>TBA</publisher>
                        <pubPlace>
                            <address>
                                <addrLine/>
                            </address>
                        </pubPlace>
                        <idno type="local">
                            <xsl:value-of select="$wit"/>
                        </idno>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <xsl:apply-templates/>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="my:order">
        <xsl:variable name="chkOrd" select="substring-after(@xml:id, '.')"/>
        <xsl:if test="$tracts/tei:div2[starts-with(@xml:id, concat($wit, '.', $chkOrd))]">
            <div1 xml:id="{$wit}.{$chkOrd}" n="{@n}">
                <xsl:for-each
                    select="$tracts/tei:div2[starts-with(@xml:id, concat($wit, '.', $chkOrd))]">
                    <xsl:variable name="thisId" select="substring-after(@xml:id, '.')"/>
                    <xsl:variable name="fileEnd">
                        <xsl:value-of select="$wit"/>
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="$chkOrd"/>
                        <xsl:if test="string-length(substring-after($thisId, $chkOrd)) = 2">
                            <xsl:text>0</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="translate(substring-after($thisId, $chkOrd),'.','')"/>
                    </xsl:variable>
                    <xsl:comment><xsl:text> </xsl:text><xsl:value-of select="$root/my:struct/my:order/my:tract[matches(@xml:id, concat('^ref-t.', $thisId, '$'))]/@n"/><xsl:text> </xsl:text></xsl:comment>
                    <xsl:element name="xi:include">
                        <xsl:attribute name="href" select="concat($wit, '/', $fileEnd,'.xml')"/>
                    </xsl:element>
                </xsl:for-each>
            </div1>
        </xsl:if>
    </xsl:template>
    <xsl:template match="my:chapter | my:tract">
        <!-- ignore -->
    </xsl:template>
</xsl:stylesheet>
