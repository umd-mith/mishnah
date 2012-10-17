<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/TestMishnahStyleSheet.css"
                    title="Documentary"/>
                <title>Mishnah Citations From Commentaries</title>
            </head>
            <body dir="rtl" lang="he">
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:ab">
        <table style="border:1px solid;border-collapse:collapse;width:750px">
            <xsl:variable name="M"
                select="concat('../tei/ref.xml#ref.',substring-after(@xml:id,'comcit.'))"/>
            <xsl:for-each select="@xml:id">
                <tr>
                    <td>
                        <xsl:value-of select="substring-after(.,'comcit.')"/>
                    </td>
                </tr>
            </xsl:for-each>
            <xsl:for-each select="tei:app">
                <xsl:variable name="from" select="@from"/>
                <xsl:variable name="to" select="@to"/>
                <xsl:choose>
                    <xsl:when test="not(string($to))">
                        <tr>
                            <td>
                                <xsl:value-of select="document(../$from)"/>
                                <ul>
                                    <xsl:for-each select="./tei:rdg">
                                        <li>
                                            <xsl:value-of select="./@wit"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="not(@type)">
                                                  <xsl:value-of select="./text()"/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'transp'">חילוף סדר משניות
                                                  עם <xsl:value-of
                                                  select="substring-after(@corresp, 'ref.xml#ref.')"
                                                  /></xsl:when>
                                            </xsl:choose>
                                            <span style="color: 	#808080"> (<xsl:value-of
                                                  select="./tei:bibl/tei:ref/text()"
                                                  /><xsl:text>, </xsl:text><xsl:if
                                                  test="./tei:bibl/tei:ref/@target"><xsl:value-of
                                                  select="substring-after(./tei:bibl/tei:ref/@target, 'comcit.')"
                                                  /><xsl:text>, </xsl:text></xsl:if><xsl:value-of
                                                  select="./tei:bibl/tei:ref/@corresp"/>)</span>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </td>
                        </tr>
                    </xsl:when>
                    <xsl:when test="string($to)">

                        <xsl:variable name="start" as="xs:integer">
                            <xsl:analyze-string select="substring-after($from,'#')"
                                regex="^(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,3}})$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(6)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:variable name="end" as="xs:integer">
                            <xsl:analyze-string select="substring-after($to,'#')"
                                regex="^(\c+?)\.([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,3}})$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(6)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <tr>
                            <td>
                                <xsl:value-of
                                    select="for $i in $start to $end return document($M)//tei:w[$i]"/>
                                <ul>
                                    <xsl:for-each select="./tei:rdg">
                                        <li>
                                            <xsl:value-of select="./@wit"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="not(@type)">
                                                  <xsl:value-of select="./text()"/>
                                                </xsl:when>
                                                <!-- Needs to be modified for transposed words/clauses -->
                                                <xsl:when test="@type = 'transp'">חילוף סדר משניות
                                                  עם <xsl:value-of
                                                  select="substring-after(@corresp, 'ref.xml#ref.')"
                                                  /></xsl:when>
                                            </xsl:choose>
                                            <span style="color: #808080"> (<xsl:value-of
                                                  select="./tei:bibl/tei:ref/text()"
                                                  /><xsl:text>, </xsl:text><xsl:if
                                                  test="./tei:bibl/tei:ref/@target"><xsl:value-of
                                                  select="substring-after(./tei:bibl/tei:ref/@target, 'comcit.')"
                                                  /><xsl:text>, </xsl:text></xsl:if><xsl:value-of
                                                  select="./tei:bibl/tei:ref/@corresp"/>)</span>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </td>
                        </tr>

                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </table>
    </xsl:template>

</xsl:stylesheet>
