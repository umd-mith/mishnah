<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:its="http://www.w3.org/2005/11/its"
    xmlns:dm="http://mith.umd.edu/mishnah/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its tei" version="2.0">
    <xsl:output encoding="UTF-8" indent="no"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> tbrown</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:function name="dm:extract-ab-ids">
      <xsl:param name="abs"/>
      <xsl:sequence select="for $ab in $abs return $ab/@xml:id"/>
    </xsl:function>
    <xsl:template match="/tei:TEI">
      <dm:ab-ids>
        <xsl:for-each select="dm:extract-ab-ids(//tei:ab)">
          <dm:ab-id>
            <xsl:value-of select="."/>
          </dm:ab-id>
        </xsl:for-each>
      </dm:ab-ids>
    </xsl:template>
</xsl:stylesheet>

