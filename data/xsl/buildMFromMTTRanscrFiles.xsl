<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://my.local-functions.uri"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs my tei" version="2.0">
  <xsl:output indent="yes"/>
  <xsl:param name="id" select="'S00483'"/>
  <!--<xsl:key name="tract" match="/my:collection/my:file/my:index" use="my:chapter"></xsl:key>-->

  <xsl:template match="/">
    <!--<xsl:copy-of select="//my:name"></xsl:copy-of>-->
    <!--   matches(/my:collection/my:file/my:file,concat('^',$id,'\.[1-6]\.[0-9]{1,2}\.[0-1]{1,2}\-mtTranscr.xml$')) -->
    <xsl:for-each select="/collection/file">
      <xsl:sort select="number(index)"/>
      <xsl:if
        test="matches(name, concat('^', $id, '\.[1-6]\.[0-9]{1,2}\.[0-9]{1,2}\-mtTranscr.xml$'))">
        <xsl:copy-of select="document("></xsl:copy-of>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
