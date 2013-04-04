<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:my="local-functions.uri" version="2.0">
    <xsl:output indent="yes" encoding="UTF-8"/>
    <!-- Creates an index of nodes that mark structure of Mishnah within a given witness. -->
    <!-- Used to create a lookup list for drop down windows and catalogues, etc. -->

    <xsl:variable name="witName" as="xs:string"
        select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='local']"/>
    <xsl:template match="/">
        <xsl:element name="my:witness" xmlns="http://www.digitalmishnah.org">
            <xsl:attribute name="name" select="$witName"> </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:div1">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:ab">
        <xsl:element name="my:mishnah" xmlns="http://www.digitalmishnah.org">
            <xsl:attribute name="n" select="substring-after(@xml:id,concat($witName,'.'))"/>
            <xsl:attribute name="order"
                select="substring-after(ancestor::tei:div1/@xml:id,concat($witName,'.'))"/>
            <xsl:attribute name="tractate"
                select="substring-after(ancestor::tei:div2/@xml:id,concat($witName,'.'))"/>
            <xsl:attribute name="chapter"
                select="substring-after(parent::tei:div3/@xml:id,concat($witName,'.'))"/>
            <xsl:attribute name="name" select="$witName"/>
            <xsl:if test="$witName = 'ref'">
                <xsl:attribute name="orderName" select="ancestor::tei:div1/@n"/>
                <xsl:attribute name="tractateName" select="ancestor::tei:div2/@n"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()"/>

</xsl:stylesheet>
