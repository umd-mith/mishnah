<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:my="local-functions.uri" exclude-result-prefixes="xi xd xs its my tei" version="2.0">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
   <xsl:param name="tei-loc" select="'../../../digitalmishnah-tei/mishnah/'"/>
    <xsl:template match="/">
        <my:index>
            <listWit>
                <xsl:copy-of select="//tei:listWit/*[descendant-or-self::tei:witness/@corresp]"/>
            </listWit>
           <xsl:apply-templates select="//tei:listWit/descendant-or-self::tei:witness[@corresp]"/>
        </my:index>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]">
        <xsl:variable name="cur_doc">
            <xsl:copy-of select="document(concat($tei-loc, @xml:id, '.xml'))"/>
        </xsl:variable>
               <xsl:variable name="witName" as="xs:string" select="$cur_doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='local']"/>
          <my:witness name="{$witName}">
             <xsl:apply-templates select="$cur_doc/tei:TEI/tei:text/tei:body/tei:div1/tei:div2/tei:div3/tei:ab"/>
        </my:witness>
    </xsl:template>
   <xsl:template match="tei:ab">
      <xsl:variable name="witName" select="substring-before(@xml:id,'.')"/>
      <xsl:element xmlns="http://www.digitalmishnah.org" name="my:mishnah">
         <xsl:attribute name="n" select="substring-after(@xml:id,concat($witName,'.'))"/>
         <xsl:attribute name="order" select="substring-after(ancestor::tei:div1/@xml:id,'.')"/>
         <xsl:attribute name="tractate" select="substring-after(ancestor::tei:div2/@xml:id,'.')"/>
         <xsl:attribute name="chapter" select="substring-after(parent::tei:div3/@xml:id,'.')"/>
         <xsl:attribute name="name" select="$witName"/>
         <xsl:if test="$witName = 'ref'">
            <xsl:attribute name="orderName" select="ancestor::tei:div1/@n"/>
            <xsl:attribute name="tractateName" select="ancestor::tei:div2/@n"/>
         </xsl:if>
      </xsl:element>
   </xsl:template>
    
    <xsl:template match="element()"/>
   <xsl:template match="text()[not(ancestor::tei:witness)]"/>
    
</xsl:stylesheet>