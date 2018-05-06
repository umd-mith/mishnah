<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs tei xhtml" version="2.0">
<xsl:param name="mcite"/>
<xsl:param name="wits"/>
<xsl:param name="tei-loc"/>   
   
   <xsl:variable name="collation" select="*/*[1]"/>
   <xsl:variable name="w-data" select="*/*[self::tei:ab]"/>   
   
<!--<xsl:variable name="ref" select="doc('/db/digitalmishnah-tei/mishnah/ref.xml')"/>-->
  
    <xsl:template match="/">
       <xsl:copy-of select="$w-data[1]"/>
    
    
<!--    <xsl:apply-templates/>-->
<!--      <xsl:variable name="data" select="          -->
   
   </xsl:template>
<!--   <xsl:template match="element() | @* | text()" mode="#all">-->
<!--      <xsl:copy>-->
<!--         <xsl:apply-templates select="element() | text() | @*" mode="#current"/>-->
<!--      </xsl:copy>-->
<!--   </xsl:template>-->

</xsl:stylesheet>