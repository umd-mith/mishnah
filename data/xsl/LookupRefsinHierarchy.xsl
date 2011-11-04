<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0"
    xmlns:local="local-functions.uri">
    <xsl:output indent="no" omit-xml-declaration="no" method="xml" encoding="UTF-8"
        media-type="text/x-json"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 4, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="//tei:list">
        <!-- Copy witness list into temporary node for reference -->
        <xsl:variable name="mcite">
            <xsl:value-of select="./@n"/>
        </xsl:variable>
        <xsl:variable name="witlist">
            <xsl:copy-of
                select="document('../tei/mishnahhierarchy.xml',
                document(''))//tei:listWit except ."
            />
        </xsl:variable>
        <results>
            <!-- build URI for each reference to variable mref -->
            <xsl:for-each select="./tei:item">
                <xsl:variable name="Wit">
                    <xsl:value-of select="."/>
                </xsl:variable>
                <xsl:variable name="buildURI">
                    <!-- This condition is temporary. M. and G. etc. indicators on xml:ids are going
                    to be removed-->
                    <xsl:choose>
                        <xsl:when test="substring($Wit,1,1)!='G'">
                            <xsl:value-of
                                select="$witlist//tei:witness[@xml:id=$Wit]/tei:ptr/@target"/>
                            <xsl:text>#M.</xsl:text>
                            <xsl:value-of select="$Wit"/>
                            <xsl:text>.</xsl:text>
                            <xsl:value-of select="$mcite"/>
                        </xsl:when>
                        <xsl:when test="substring($Wit,1,1)='G'">
                            <xsl:value-of
                                select="$witlist//tei:witness[@xml:id=$Wit]/tei:ptr/@target"/>
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="$Wit"/>
                            <xsl:text>.</xsl:text>
                            <xsl:value-of select="$mcite"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="mRef">
                    <xsl:value-of select="resolve-uri($buildURI,document-uri(/))"/>
                </xsl:variable>
                <xsl:variable name="mExtract">
                    <xsl:copy-of select="document($mRef)/node()|@*"/>
                </xsl:variable>
            </xsl:for-each>
        </results>
    </xsl:template>
</xsl:stylesheet>
