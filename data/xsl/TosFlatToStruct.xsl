<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
   xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="xs tei saxon" version="2.0">
   <xsl:param name="pathOut" select="'../tei/t/P00005/'"/>
   <xsl:variable name="files">
      <xsl:for-each select="collection('../tei/t/P00005/?select=*TESTflat.xml')">
         <xsl:variable name="docName" select="tokenize(base-uri(.), '/')[last()]"/>
         <tract>
            <wit>
               <xsl:value-of select="tokenize($docName, '-')[1]"/>
            </wit>
            <div2Id>
               <xsl:value-of select="tei:div2/@xml:id"/>
            </div2Id>
            <div1Id>
               <xsl:analyze-string select="tei:div2/@xml:id" regex="(.*)\.\d{{1,2}}">
                  <xsl:matching-substring>
                     <xsl:value-of select="regex-group(1)"/>
                  </xsl:matching-substring>
               </xsl:analyze-string>
            </div1Id>
            <outName>
               <xsl:value-of select="replace($docName, 'flat', '')"/>
            </outName>
            <contents>
               <xsl:apply-templates select="*"/>
            </contents>
         </tract>
      </xsl:for-each>
   </xsl:variable>
   <xsl:template match="/">
      <xsl:for-each select="$files/tei:tract">
         <xsl:result-document encoding="utf-8" href="{$pathOut}{tei:outName}" indent="yes">

            <xsl:if test="tei:contents/tei:milestone[@unit = 'head-ord']">
               <xsl:message> Add to main doc
                  <addThis><head xml:id="{tei:div1Id}.H">
                     <xsl:apply-templates mode="reNum"
                        select="(tei:contents/tei:milestone[@unit = 'head-ord']/following-sibling::* intersect tei:contents/tei:milestone[@unit = 'head-ord']/following-sibling::tei:milestone[1]/preceding-sibling::*) except self::tei:milestone"
                           ><xsl:with-param name="idStr" select="concat(tei:div1Id, '.H')"
                        /></xsl:apply-templates>
                  </head></addThis>
               </xsl:message>
            </xsl:if>
            <div2 xml:id="{tei:div2Id}" xmlns:xi="http://www.w3.org/2001/XInclude">
               <head xml:id="{tei:div2Id}.H">
                  <xsl:apply-templates mode="reNum"
                     select="(tei:contents/tei:milestone[@unit = 'head-tract']/following-sibling::* intersect tei:contents/tei:milestone[@unit = 'head-tract']/following-sibling::tei:milestone[1]/preceding-sibling::*) except self::tei:milestone">
                     <xsl:with-param name="idStr" select="concat(tei:div2Id, '.H')"/>
                  </xsl:apply-templates>
               </head>
               <xsl:for-each-group select="tei:contents/*"
                  group-starting-with="tei:milestone[@unit='ch']">
                  <xsl:variable name="div3Id" select="@n"> </xsl:variable>
                  <div3 xml:id="{$div3Id}">
                     <xsl:for-each-group group-starting-with="tei:milestone"
                        select="current-group() except .">

                        <xsl:if test="current-group()[1][self::tei:milestone[@unit = 'head-ch']]">
                           <head xml:id="{$div3Id}.H">
                              <xsl:copy-of select="current-group() except ."/>
                           </head>
                        </xsl:if>
                        <xsl:if test="current-group()[1][self::tei:milestone[@unit = 'ab']]">
                           <ab xml:id="{$div3Id}.{current-group()[1]/@n}">
                              <xsl:copy-of select="current-group() except ."/>
                           </ab>
                        </xsl:if>
                        <xsl:if test="current-group()[1][self::tei:milestone[@unit = 'trailer-ch']]">
                           <trailer xml:id="{$div3Id}.T">
                              <xsl:copy-of select="current-group() except ."/>
                           </trailer>
                        </xsl:if>
                     </xsl:for-each-group>
                  </div3>
               </xsl:for-each-group>
               <xsl:choose>
                  <xsl:when
                     test="tei:contents/tei:milestone[@unit = 'trailer-tract'] and tei:contents/tei:milestone[@unit = 'trailer-tract']/following-sibling::tei:milestone">
                     <trailer xml:id="{tei:div2Id}.T">
                        <xsl:apply-templates mode="reNum"
                           select="(tei:contents/tei:milestone[@unit = 'trailer-tract']/following-sibling::* intersect tei:contents/tei:milestone[@unit = 'trailer-tract']/following-sibling::tei:milestone[1]/preceding-sibling::*) except self::tei:milestone">
                           <xsl:with-param name="idStr" select="concat(tei:div2Id, '.T')"/>
                        </xsl:apply-templates>
                     </trailer>
                  </xsl:when>
                  <xsl:otherwise>
                     <trailer xml:id="{tei:div2Id}.T">
                        <xsl:apply-templates mode="reNum"
                           select="tei:contents/tei:milestone[@unit = 'trailer-tract']/following-sibling::*">
                           <xsl:with-param name="idStr" select="concat(tei:div2Id, '.T')"/>
                        </xsl:apply-templates>
                     </trailer>
                  </xsl:otherwise>
               </xsl:choose>
            </div2>
            <xsl:if test="tei:contents/tei:milestone[@unit = 'trailer-ord']">
               <xsl:message>
                  Add to main doc:
                  <addThis ><trailer xml:id="{tei:div1Id}.T">
                  <xsl:apply-templates mode="reNum"
                     select="tei:contents/tei:milestone[@unit = 'trailer-ord']/following-sibling::*">
                     <xsl:with-param name="idStr" select="concat(tei:div1Id, '.T')"/>
                  </xsl:apply-templates>
               </trailer></addThis></xsl:message>
            </xsl:if>

         </xsl:result-document>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="tei:div2">
      <xsl:apply-templates select="*"/>
   </xsl:template>
   <xsl:template match="tei:div3">
      <milestone unit="ch" n="{@xml:id}"/>
      <xsl:apply-templates select="*"/>
   </xsl:template>
   <xsl:template match="tei:ab">
      <xsl:apply-templates select="*"/>
   </xsl:template>
   <xsl:template match="tei:milestone[@unit = 'ab']">
      <milestone>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="n" select="count(preceding-sibling::tei:milestone[@unit = 'ab']) + 1"
         />
      </milestone>
   </xsl:template>
   <xsl:template match="tei:w">
      <w>
         <xsl:copy-of select="@*"/>
         <xsl:if test="not(@xml:id)">
            <xsl:attribute name="n">
               <xsl:value-of
                  select="count(preceding-sibling::tei:w intersect preceding-sibling::tei:milestone[1]/following-sibling::tei:w) + 1"
               />
            </xsl:attribute>
         </xsl:if>
         <xsl:value-of select="."/>
      </w>
   </xsl:template>
   <xsl:template mode="reNum" match="*">
      <xsl:param name="idStr"/>
      <xsl:choose>
         <xsl:when test="self::tei:w[@n]">
            <w xml:id="{$idStr}.{@n}">
               <xsl:value-of select="."/>
            </w>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
