<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">
   <xsl:strip-space elements="*"/>
   <!--<xsl:strip-space elements="tei:damage tei:unclear tei:gap"/>-->

   <xsl:output indent="yes"/>
   <xsl:param name="iterate" select="'yes'"/>
   <xsl:param name="csv">no</xsl:param>
   <xsl:param name="path" select="'../tei/w-sep'"/>

   <xsl:variable name="files"
      select="collection(iri-to-uri(concat($path, '?select=(ref|[PS][0-9]{5})-w-sep.xml;recurse=no')))"/>

   <xsl:template match="/">
      <xsl:variable name="elems">
         <xsl:for-each select="$files">
            <xsl:for-each-group select="/tei:TEI/tei:text/tei:body//*[ancestor-or-self::tei:w]" group-by="name()">
               <xsl:sort select="name()"/>
               <xsl:element name="{name()}"/>
            </xsl:for-each-group>
         </xsl:for-each>
      </xsl:variable>
      <xsl:for-each select="$elems/distinct-values(*/name())">
         <xsl:sort select="."></xsl:sort>
         <xsl:copy-of select="."/>
      </xsl:for-each>
         
   </xsl:template>




</xsl:stylesheet>
