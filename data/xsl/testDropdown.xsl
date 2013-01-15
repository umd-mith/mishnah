<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its local tei"
    version="2.0" xmlns:local="local-functions.uri">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:variable name="list">
        <xsl:for-each select="document('../tei/ref.xml',(document('')))/*/*/*/tei:div1">
            <order>
                <xsl:copy-of select="@xml:id"/>
                <xsl:copy-of select="@n"/>
                <xsl:for-each select="tei:div2">
                    <tract>
                        <xsl:copy-of select="@xml:id"/>
                        <xsl:copy-of select="@n"/>

                        <xsl:for-each select="tei:div3">
                            <chapter>
                                <xsl:copy-of select="@xml:id"/>
                                <xsl:copy-of select="@n"/>
                            </chapter>
                        </xsl:for-each>
                    </tract>
                </xsl:for-each>


            </order>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                    <title>Test Dropdown</title><style type="text/css">
                        .sub2{color:black;}
                        .sub3{padding-left:3em; font-style:italic;}
                    </style>
            </head>
            <body>
                <div class="menu">
                    <select>
                        <option xmlns="http://www.w3.org/1999/xhtml">
                            Select from the following list
                        </option>
                        <xsl:apply-templates select="$list/tei:order"/>
                    </select>
                </div>
            </body>

        </html>
    </xsl:template>
    <xsl:template match="tei:order">
        <optgroup class="menu sub1" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="title" select="substring-after(@xml:id,'ref.')"/>
            <xsl:attribute name="label" select="@n"/>
            <xsl:if test="tei:tract">
                <xsl:apply-templates select="tei:tract"/>
            </xsl:if>
        </optgroup>
    </xsl:template>
    <xsl:template match="tei:tract">
                <option xmlns="http://www.w3.org/1999/xhtml" class="menu sub2" disabled="disabled">
                    <xsl:value-of select="translate(@n,'_', ' ')"/>
                </option>
        <xsl:choose>
            <xsl:when test="tei:chapter">
                <xsl:apply-templates select="tei:chapter">
                    <xsl:with-param name="substr" select="@xml:id"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="tei:chapter">
        <xsl:param name="substr"/>
        <option class="menu sub3" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="title" select="substring-after(@xml:id,'ref.')"/>
            <xsl:value-of select="concat('Chapter ',substring-after(@xml:id,concat($substr,'.')))"/>
        </option>
    </xsl:template>

</xsl:stylesheet>
