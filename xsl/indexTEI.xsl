<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xi xd xs its tei" version="2.0">
   <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
   <xsl:param name="tei-loc" select="'../../../digitalmishnah-tei/mishnah/'"/>
   <xsl:strip-space elements="*"/>



   <xsl:key name="mIndex" match="//tei:key" use="string(@id)"/>

   <xsl:variable name="witList" select="tei:TEI//tei:witness/@corresp"/>
   <!-- iterate through documents -->
   <!-- create key-value pairs of ids and witness IDs for matching -->
   <xsl:variable name="index">
      <index>
         <xsl:for-each select="$witList">
            <xsl:for-each select="doc(concat($tei-loc,.))//*[self::tei:head|self::tei:trailer|self::tei:ab][.//text()]/@xml:id">
            <key id="{.}">
                        <xsl:value-of select="substring-before(.,'.')"/>
                    </key>
         </xsl:for-each>
         </xsl:for-each> </index>
   </xsl:variable>
   <xsl:template match="/">
      <TEI>
         <teiHeader>
            <fileDesc>
               <titleStmt>
                  <title>Index File for Digital Mishnah Project</title>
               </titleStmt>
               <publicationStmt>
                  <p>Copies listWits and witness elements from ref.xml, and, following the structure
                     of the Mishnah lists the witnesses that have text at that head, trailer or
                     ab</p>
               </publicationStmt>
               <sourceDesc>
                  <listWit>
                     <xsl:apply-templates select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/*"/>
                  </listWit>
               </sourceDesc>
            </fileDesc>
         </teiHeader>
         <text>
            <body>
               <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div1"/>
            </body>
         </text>
      </TEI>
   </xsl:template>

 
   <!-- Witness Lists in Header-->
   <xsl:template match="tei:witness | tei:listWit">
      <xsl:element name="{name()}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="text()[parent::tei:witness]">
      <xsl:value-of select="normalize-space(.)"/>
   </xsl:template>
   <xsl:template match="tei:desc"/>

   <!-- body; generate index of witnesses -->
   <xsl:template match="tei:div1 | tei:div2">
      <xsl:element name="{name()}">
         <xsl:attribute name="xml:id" select="concat('index-m.', substring-after(@xml:id, '.'))"/>
         <xsl:call-template name="doHeadTrailer">
            <xsl:with-param name="elem" select="'.H'"/>
         </xsl:call-template>
         <xsl:apply-templates/>
         <xsl:call-template name="doHeadTrailer">
            <xsl:with-param name="elem" select="'.T'"/>
         </xsl:call-template>
      </xsl:element>
   </xsl:template>

   <xsl:template match="tei:div3">
      <div3>
         <xsl:attribute name="xml:id" select="concat('index-m.', substring-after(@xml:id, '.'))"/>
         <xsl:call-template name="doHeadTrailer">
            <xsl:with-param name="elem" select="'.H'"/>
         </xsl:call-template>
         <xsl:for-each select="tei:ab[.//text()]">
            <xsl:variable name="abNum" select="substring-after(@xml:id, '.')"/>

            <ab>
               <xsl:attribute name="xml:id" select="concat('index-m.', $abNum)"/>
               <xsl:for-each select="$witList">
                  <xsl:variable name="abExists" select="key('mIndex', concat(substring-before(., '.'), '.', $abNum), $index)"/>
                  <xsl:if test="$abExists">
                     <ptr n="{$abExists}" target="{concat($abExists,'.xml#',$abExists,'.' ,$abNum,' ',$abExists,'-w-sep.xml#',$abExists,'.' ,$abNum)}"/>
                  </xsl:if>
               </xsl:for-each>
            </ab>
         </xsl:for-each>
         <xsl:call-template name="doHeadTrailer">
            <xsl:with-param name="elem" select="'.T'"/>
         </xsl:call-template>
      </div3>
   </xsl:template>
   <xsl:template match="node()">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template name="doHeadTrailer">
      <xsl:param name="elem"/>
      <xsl:element name="{if ($elem = '.H') then 'head' else if ($elem = '.T') then 'trailer' else          ()}">
         <xsl:variable name="headTrailNum" select="substring-after(@xml:id, '.')"/>
         <xsl:attribute name="xml:id" select="concat('index-m.', $headTrailNum, $elem)"/>
         <xsl:for-each select="$witList">
            <xsl:variable name="headTrailerExists" select="key('mIndex', concat(substring-before(., '.'), '.', $headTrailNum, $elem), $index)"/>
            <xsl:if test="$headTrailerExists">
               <!--<xsl:for-each select="$headTrailerExists">-->
               <ptr n="{$headTrailerExists}" target="{concat($headTrailerExists,'.xml#',$headTrailerExists,'.',$headTrailNum,$elem,' ',$headTrailerExists,'-w-sep.xml#',$headTrailerExists,'.',$headTrailNum,$elem)}"/>
               <!--</xsl:for-each>-->

            </xsl:if>
         </xsl:for-each>
      </xsl:element>

   </xsl:template>


</xsl:stylesheet>