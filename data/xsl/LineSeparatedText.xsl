<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   version="2.0">
   <xsl:output encoding="UTF-8" method="text" indent="no"/>
   <xsl:template match="teiHeader"></xsl:template>
   <xsl:template match="text ">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="/TEI/text/body">
      <xsl:apply-templates></xsl:apply-templates>
   </xsl:template>
   <xsl:template match="text()|element()|@*">
      <xsl:copy>
         <xsl:apply-templates select="text()|element()|@*"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="lb">
      <xsl:text>&#xd;</xsl:text>
   </xsl:template>
   <xsl:template match="pb|cb|fw">
      <xsl:text>&#xd;</xsl:text>
      <xsl:if test="self::pb or self::cb">
         <xsl:value-of select="substring-after(@xml:id,'.')"/>
      </xsl:if>
      <xsl:apply-templates></xsl:apply-templates>
      <xsl:text>&#xd;</xsl:text>
   </xsl:template>
   <!-- go over next two to adjust whitespace -->
   <xsl:template match="div1|div2|div3|ab|head|trailer|w|pc|seg|choice|del|abbr|label">
      <!-- includes text of dels  -->
      <xsl:text> </xsl:text><xsl:apply-templates/><xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template match="surplus">
      <xsl:text> </xsl:text><xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="damage|c|am|metamark">
      <xsl:apply-templates></xsl:apply-templates>
   </xsl:template>
   <xsl:template match="add|expan|listTranspose|milestone|note">
      <!-- excludes all adds, both commentary and textual correction. -->
   </xsl:template>
   <xsl:template match="gap|space|unclear[@extent]">
      <xsl:value-of select=" for $i in 1 to @extent return if (@unit = 'lines') then '&#xd;' else ' ' "/>
   </xsl:template>
   <xsl:template match="text()" priority="-0.25">
      <xsl:value-of select="normalize-space(.)"/>
   </xsl:template>
</xsl:stylesheet>