<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cx="http://interedition.eu/collatex/ns/1.0"
  version="2.0"
>
  <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
  <xsl:strip-space elements="cx:cell"/>
  <xsl:template match="/cx:alignment">
    <cx:alignment>
      <xsl:for-each select="cx:row[1]/cx:cell">
        <xsl:variable name="sigil" select="@sigil"/>
        <cx:row sigil="{$sigil}">
          <xsl:for-each select="../../cx:row">
            <xsl:variable name="text" select="cx:cell[@sigil = $sigil]/text()"/> 
            <cx:cell>
              <xsl:attribute name="state">
                <xsl:choose>
                  <xsl:when test="cx:cell/text() != $text">
                    <xsl:text>variant</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>invariant</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="normalize-space($text)"/>
            </cx:cell>
          </xsl:for-each>
        </cx:row>
      </xsl:for-each>
    </cx:alignment>
  </xsl:template>
</xsl:stylesheet>

