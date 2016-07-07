<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:my="local-functions.uri" exclude-result-prefixes="xi xd xs its my tei" version="2.0">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:param name="tei-loc"/>
    <xsl:template match="/">
        <my:index>
            <listWit>
                <xsl:copy-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/*[//tei:witness/@corresp]"/>
            </listWit>
            <xsl:apply-templates/>
        </my:index>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]">
        <xsl:variable name="cur_doc">
            <xsl:copy-of select="document(concat($tei-loc, @xml:id, '.xml'))"/>
        </xsl:variable>
        <xsl:variable name="witName" as="xs:string" select="$cur_doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='local']"/>
        <my:witness name="{$witName}">
            <xsl:for-each select="$cur_doc//tei:div1//tei:ab">
                <xsl:element xmlns="http://www.digitalmishnah.org" name="my:mishnah">
                    <xsl:attribute name="n" select="substring-after(@xml:id,concat($witName,'.'))"/>
                    <xsl:attribute name="order" select="substring-after(ancestor::tei:div1/@xml:id,concat($witName,'.'))"/>
                    <xsl:attribute name="tractate" select="substring-after(ancestor::tei:div2/@xml:id,concat($witName,'.'))"/>
                    <xsl:attribute name="chapter" select="substring-after(parent::tei:div3/@xml:id,concat($witName,'.'))"/>
                    <xsl:attribute name="name" select="$witName"/>
                    <xsl:if test="$witName = 'ref'">
                        <xsl:attribute name="orderName" select="ancestor::tei:div1/@n"/>
                        <xsl:attribute name="tractateName" select="ancestor::tei:div2/@n"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:for-each>
        </my:witness>
    </xsl:template>
    <xsl:template match="tei:text|tei:back|tei:encodingDesc|tei:revisionDesc"/>
    <xsl:template match="tei:teiHeader">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:titleStmt|tei:publicationStmt|tei:notesStmt"/>
</xsl:stylesheet>