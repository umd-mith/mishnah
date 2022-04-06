<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:my="local-functions.uri" exclude-result-prefixes="xi xd xs its my tei xi" version="2.0">
   <xsl:output method="html" indent="yes" encoding="UTF-8"/>
   <xsl:param name="tei-loc" select="'../../digitalmishnah-tei/mishnah/'"/>
   <xsl:strip-space elements="*"/>
   
   <xsl:variable name="witList" select="tei:TEI//tei:witness/@corresp"/>
   <xsl:template match="/">
      <my:composList>
         <listWit>
            <xsl:copy-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/*[descendant-or-self::tei:witness/@corresp]"/>
         </listWit>
         <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div1"/>
      </my:composList>
   </xsl:template>

   <!--<xsl:template match="tei:body/node()">
      <xsl:copy>
         <xsl:apply-templates select="node()"/>
      </xsl:copy>
   </xsl:template>-->
   <xsl:template match="tei:div1">
      <my:ord-compos n="{substring-after(@xml:id,'.')}">
         <xsl:attribute name="xml:id" select="@n"/>
         <xsl:apply-templates/>
      </my:ord-compos>   
   </xsl:template>
   <xsl:template match="tei:div2">
      <my:tract-compos n="{substring-after(@xml:id,'.')}">
         <xsl:attribute name="xml:id" select="@n"/>
         <xsl:apply-templates/>
      </my:tract-compos>
   </xsl:template>
   <xsl:template match="tei:div3">
      <my:ch-compos n="{substring-after(@xml:id,'.')}">
         <xsl:for-each select="tei:ab">
            <xsl:variable name="abNum" select="substring-after(@xml:id, '.')"/>
               <my:m-compos n="{$abNum}">
                  <xsl:for-each select="$witList">
                  <xsl:variable name="witID" select="substring-before(.,'.xml')"/>
                  <xsl:if test="doc(concat($tei-loc,.))/id(concat($witID,'.',$abNum))">
                     <my:wit-compos>
                                <xsl:value-of select="$witID"/>
                            </my:wit-compos>
                  </xsl:if>
               </xsl:for-each>
                </my:m-compos>
         </xsl:for-each>
      </my:ch-compos>
   </xsl:template>
   
   <xsl:template match="node()">
      <xsl:apply-templates/>
   </xsl:template>
</xsl:stylesheet>