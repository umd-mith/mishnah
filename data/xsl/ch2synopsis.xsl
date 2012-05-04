<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output method="html" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 1, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- Creates Synopsis for Ch2 of Bava Metsi'a from pointers on witness list in
    ref.xml tests if text exists. then builds table. -->
    <!-- create a list of URIs first checking whether there is text at Ch2 -->
    <!-- Copy names and URIs to lookup list -->
    <xsl:strip-space elements="*"/>
    <xsl:variable name="URIlist">
        <xsl:for-each
            select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit//tei:witness[@corresp]">
            <xsl:variable name="checkURI">
                <xsl:value-of select="./@corresp"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="./@xml:id"/>
                <xsl:text>.4.2.2</xsl:text>
            </xsl:variable>
            <xsl:if test="(document($checkURI, .))">
                <xsl:element name="item">
                    <xsl:element name="mURI">
                        <xsl:value-of select="./@corresp"/>
                    </xsl:element>
                    <xsl:element name="witName">
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                    <xsl:element name="siglum">
                        <xsl:value-of select="normalize-space(./@xml:id)"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/">
       <html>
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/ParColumnStylesheet.css"
                    title="Mishnah Style Sheet" alternate="no"/>
                <link rel="stylesheet" type="text/css"
                    href="/Users/hlapin/Sites/JewishStudies/faculty/Lapin/MishnahProject/ParColumnStylesheet.css"
                    alternate="yes"/>
            </head>
            <title>Sample Synoptic Text</title>
            <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            <div>
                <body lang="he" dir="rtl">
                    <h1 lang="en" dir="ltr" align="center">Mishnah Text Bava Metsi'a Ch2</h1>
                    <h2 lang="en" dir="ltr" align="center">Synopsis</h2>
                    <xsl:apply-templates
                        select="tei:TEI/tei:text/tei:body/tei:div1/tei:div2/tei:div3[@xml:id='ref.4.2.2']"
                    />
                </body>
            </div>
        </html>
    </xsl:template>
    <xsl:template match="tei:div3">
        <table dir="rtl" align="right">
            <tr>
                <xsl:for-each select="$URIlist/tei:item">
                    <td dir="ltr" align="center" lang="en">
                        <xsl:value-of select="./tei:witName"/>
                    </td>
                </xsl:for-each>
            </tr>
            <xsl:for-each select="child::element()">
                <xsl:variable name="temp" as="text()">
                    <xsl:value-of select="translate(current()/@xml:id,'ref', '')"/>
                </xsl:variable>
                <tr padding-bottom="2em">
                    <xsl:for-each select="$URIlist/tei:item">
                        <td>
                            <xsl:variable name="mURI">
                                <xsl:value-of select="tei:mURI"/>
                            </xsl:variable>
                            <xsl:variable name="lookup">

                                <xsl:value-of select="concat('../tei/',$mURI,'#',tei:siglum,$temp)"
                                />
                            </xsl:variable>
                            <xsl:copy-of select="document($lookup)"/>
                        </td>
                    </xsl:for-each>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    <xsl:template match="tei:choice">
        <xsl:value-of select="*"></xsl:value-of>
    </xsl:template>
</xsl:stylesheet>
