<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:my="local-functions.uri" exclude-result-prefixes="xi xd xs its my tei" version="2.0">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:template match="/">
        <my:index xmlns:my="local-functions.uri">
            <listWit xmlns:tei="http://www.tei-c.org/ns/1.0" ><xsl:copy-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/*[//tei:witness/@corresp]"/></listWit>
            <xsl:apply-templates/>
        </my:index>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]">
            
                <cinclude:include
                    src="cocoon:/{@xml:id}.index"/>
            
        
    </xsl:template>
    <xsl:template match="tei:text|tei:back|tei:encodingDesc|tei:revisionDesc"/>
<xsl:template match="tei:teiHeader">
    <xsl:apply-templates/>
</xsl:template>    
    <xsl:template match="tei:titleStmt|tei:publicationStmt|tei:notesStmt"></xsl:template>
</xsl:stylesheet>