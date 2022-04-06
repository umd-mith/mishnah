<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:my="http://http://dev.digitalmishnah.org/local-functions.uri"
    xmlns:local="local-functions.uri" exclude-result-prefixes="xd xs its local my tei" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:param name="tei-loc"
        select="'file:///C:/Users/hlapin/Documents/GitHub/digitalmishnah-tei/mishnah/'"/>
    <xsl:param name="mode" select="'page'"></xsl:param>
    <xsl:variable name="wit"
        select="//tei:TEI/tei:teiHeader//tei:publicationStmt/tei:idno[@type = 'local']/text()"/>
    <xsl:variable name="sourceDoc" select="doc(concat($tei-loc, $wit, '.xml'))"/>
    <xsl:variable name="num" select="/tei:TEI/tei:text/tei:body/tei:div/@n/string()"></xsl:variable>
    
    <xsl:variable name="thisId" select="concat($wit, '.', $num)">
    </xsl:variable>
    <xsl:variable xmlns="http://www.tei-c.org/ns/1.0" name="thisPgColCh">
        <xsl:message select="$thisId"></xsl:message>
        <xsl:variable name="thisElement" select="$sourceDoc/id($thisId)">
            <!--<xsl:copy-of select="$sourceDoc/id($thisId)"></xsl:copy-of>-->
        </xsl:variable>
        <xsl:message select="$thisElement"></xsl:message>
        
        <xsl:variable name="name" select="$thisElement/*/name()" as="xs:string"/>
        <xsl:variable name="id" select="$thisElement/@xml:id"/>
        <this>
            <xsl:value-of select="$id"/>
        </this>
        <first>
            <xsl:value-of select="if ($thisElement/preceding::*[name() eq $thisElement/name()])
                then ($thisElement/preceding::*[name() eq $thisElement/name()])[1]
                else $thisElement/@xml:id"></xsl:value-of>
        </first>
        <last>
            <xsl:value-of select="if ($thisElement/following::*[name() eq $thisElement/name()])
                then ($thisElement/following::*[name() eq $thisElement/name()])[last()]/@xml:id
                else $thisElement/@xml:id"></xsl:value-of>
        </last>
        <prev>
            <xsl:copy-of select="if ($thisElement/preceding::*[name() eq $thisElement/name()])
                then $thisElement/preceding::*[name() eq $thisElement/name()][1]
                else 'null'"></xsl:copy-of>
        </prev>
        <next>
            <xsl:value-of select="if ($thisElement/following::*[name() eq $thisElement/name()])
                then ($thisElement/following::*[name() eq $thisElement/name()])[1]/@xml:id
                else 'null'"></xsl:value-of>
        </next>
    </xsl:variable>
    <xsl:template match="/">
        <out>
            <!--<xsl:message select="concat($wit, '.', /tei:TEI/tei:text/tei:body/tei:div/@n)"/>
            <!-\- why does this work -\->
            <xsl:variable name="id"
                select="concat($wit, '.', /tei:TEI/tei:text/tei:body/tei:div/@n)"/>
            <xsl:message select="$id"/>
            <xsl:message select="$sourceDoc/id($id)"/>
            <xsl:copy-of select="$sourceDoc/id($id)"/>
            <!-\- but not this -\->
            <xsl:message
                select="$sourceDoc/id(concat($wit, '.', /tei:TEI/tei:text/tei:body/tei:div/@n))"/>
            <xsl:copy-of
                select="$sourceDoc/id(concat($wit, '.', /tei:TEI/tei:text/tei:body/tei:div/@n))"/>-->

           <xsl:copy-of select="$thisPgColCh"></xsl:copy-of>
            
            <!-- <out>
   <this xmlns="http://www.tei-c.org/ns/1.0">P00001.151r</this>
   <first xmlns="http://www.tei-c.org/ns/1.0">P00001.151r</first>
   <last xmlns="http://www.tei-c.org/ns/1.0">P00001.170r</last>
   <prev xmlns="http://www.tei-c.org/ns/1.0">null</prev>
   <next xmlns="http://www.tei-c.org/ns/1.0">P00001.151v</next>
</out> -->
        </out>
    </xsl:template>
</xsl:stylesheet>