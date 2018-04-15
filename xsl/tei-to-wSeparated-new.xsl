<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei"
   version="2.0">
   <xsl:strip-space elements="*"/>
   
   <!--<xsl:strip-space elements="tei:damage tei:unclear tei:gap"/>-->

   <xsl:output indent="yes"/>
   <xsl:param name="iterate" select="'no'"/>
   <xsl:param name="csv">no</xsl:param>
   <xsl:param name="to_TEI" select="'../../../digitalmishnah-tei/mishnah/'"/>

   <!--<xsl:variable name="files" select="collection((concat($to_TEI, '?select=P179204.xml;recurse=no')))"></xsl:variable>-->
   <xsl:variable name="files" select="doc(concat($to_TEI, 'P179204.xml'))"/>

   <xsl:template match="* | text() | @* | comment()" mode="#all">
      <xsl:copy>
         <xsl:apply-templates select="* | text() | @* | comment()" mode="#current"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="/">
      <xsl:choose>
         <xsl:when test="$iterate = 'yes'">
            <xsl:for-each select="$files/*">
               <xsl:result-document href="{concat($to_TEI,'/w-sep/',/*/*/*/*/tei:idno[@type='local'],'-w-sep.xml')}"
                  method="xml" indent="yes" encoding="utf-8">
                  <TEI>
                     <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                <xsl:text>schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
            </xsl:processing-instruction>
                     <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                 <xsl:text>schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
            </xsl:processing-instruction>
                     <xsl:call-template name="doText"/>
                  </TEI>
               </xsl:result-document>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="$iterate = 'no'">
            <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" </xsl:text>
                <xsl:text>schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
            </xsl:processing-instruction>
            <xsl:processing-instruction name="xml-model">
                <xsl:text>type="application/xml" </xsl:text>
  <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"</xsl:text>
                 <xsl:text>schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
            </xsl:processing-instruction>
            <xsl:call-template name="doText"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="doText">
      <xsl:variable name="segment">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:variable name="cleanup">
         <xsl:apply-templates mode="group" select="$segment"/>
      </xsl:variable>
      <xsl:apply-templates select="$cleanup" mode="cleanup"/>
   </xsl:template>

   <!-- Flatten every relevant descendant of head, trailer, ab -->
   <!-- damage and unclear to spans -->
   <xsl:template match="tei:damage | tei:unclear | tei:gap[@reason = 'damage']">
      <!-- NB on revision, gap should just be passed through -->
      <damageSpan type="{name()}" spanTo="#{generate-id()}">
         <xsl:if test="@reason">
            <xsl:attribute name="subtype" select="@reason"/>
         </xsl:if>
         <xsl:copy-of select="@* except @reason"/>
      </damageSpan>
      <xsl:apply-templates/>
      <anchor type="{name()}"><xsl:attribute name="xml:id" select="generate-id()"/></anchor>
   </xsl:template>
   <xsl:template match="tei:add | tei:del">

      <!-- ifs to force start-of-word spans to be outside w elements -->
      <xsl:if
         test="not(parent::*[self::tei:pc | self::tei:am]) and (matches(text()[1], '^\s') or matches(preceding::text()[1], '\s$') or preceding-sibling::node()[1][self::tei:lb | self::tei:pb | self::tei:cb | self::tei:label | self::tei:surplus] or not(preceding-sibling::node()))">
         <sep xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:if>
      <xsl:element name="{concat(name(),'Span')}">
         <xsl:attribute name="spanTo" select="concat('#', generate-id())"/>
         <xsl:copy-of select="@*"/>
      </xsl:element>
      <xsl:if
         test="not(parent::*[self::tei:pc | self::tei:am]) and (matches(text()[1], '^\s') or matches(preceding::text()[1], '\s$') or preceding-sibling::node()[1][self::tei:lb | self::tei:pb | self::tei:cb | self::tei:label | self::tei:surplus] or not(preceding-sibling::node()))">
         <sep xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if
         test="matches(text()[last()], '\s$') or matches(following::text()[1], '^\s') or following-sibling::node()[1][self::tei:lb | self::tei:pb | self::tei:cb | self::tei:label | self::tei:surplus] or not(following-sibling::node())">
         <sep xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:if>
      <xsl:element name="anchor">
         <xsl:attribute name="xml:id" select="generate-id()"/>
         <xsl:attribute name="type"
            select="
               if (@type) then
                  @type
               else
                  name()"
         />
      </xsl:element>
      <xsl:if
         test="matches(text()[last()], '\s$') or matches(following::text()[1], '^\s') or following-sibling::node()[1][self::tei:lb | self::tei:pb | self::tei:cb | self::tei:label | tei:surplus] or not(following-sibling::node())">
         <sep xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:if>
   </xsl:template>

   <!-- segments to spans -->
   <xsl:template match="tei:seg">
      <xsl:choose>
         <xsl:when test="@function = 'CHECK-ME'"><!-- do nothing --></xsl:when>
         <xsl:otherwise>
            <sep xmlns="http://www.tei-c.org/ns/1.0"/>
            <span type="seg">
               <xsl:copy-of select="@*"/>
               <xsl:attribute name="to" select="concat('#', generate-id())"/>
            </span>
            <sep xmlns="http://www.tei-c.org/ns/1.0"/>
            <xsl:apply-templates/>
            <sep xmlns="http://www.tei-c.org/ns/1.0"/>
            <xsl:element name="anchor">
               <xsl:attribute name="xml:id" select="generate-id()"/>
               <xsl:attribute name="type" select="'seg'"/>
            </xsl:element>
            <sep xmlns="http://www.tei-c.org/ns/1.0"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--<xsl:template match="tei:label">
      <label>
         <xsl:copy-of select="@*"></xsl:copy-of>
         <xsl:apply-templates/>
      </label>
   </xsl:template>-->

   <xsl:template
      match="tei:w | tei:surplus | tei:gap | (: tei:fw |:) tei:lb[not(@break = 'no')] | tei:pb | tei:cb | tei:pc | tei:label | tei:milestone | tei:metamark[not(parent::tei:w)] | tei:listTranspose">

      <xsl:choose>
         <xsl:when test="self::tei:w">
            <sep xmlns="http://www.tei-c.org/ns/1.0">
               <w>
                  <xsl:copy-of select="@*"/>
                  <xsl:if test="@xml:id">
                     <xsl:attribute name="n" select="@xml:id"/>
                  </xsl:if>
                  <xsl:apply-templates/>
               </w>
            </sep>
         </xsl:when>
         <xsl:when test="parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | self::label | self::tei:milestone">
            <xsl:element name="{name()}">
               <xsl:copy-of select="@*"/>
               <xsl:apply-templates/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <sep xmlns="http://www.tei-c.org/ns/1.0">
               <xsl:element name="{name()}">
                  <xsl:copy-of select="@*"/>
                  <xsl:apply-templates/>
               </xsl:element>
            </sep>
         </xsl:otherwise>
      </xsl:choose>


   </xsl:template>

   <xsl:template match="tei:choice[tei:abbr | tei:expan] | tei:choice[not(ancestor::tei:w)][tei:orig | tei:reg]">

      <xsl:choose>
         <xsl:when test="ancestor::tei:w">
            <choice>
               <xsl:apply-templates/>
            </choice>
         </xsl:when>
         <xsl:otherwise>
            <sep xmlns="http://www.tei-c.org/ns/1.0">
               <w>
                  <choice>
                     <xsl:apply-templates/>
                  </choice>
               </w>
            </sep>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>
   <xsl:template match="tei:choice[tei:sic]">
      <sep xmlns="http://www.tei-c.org/ns/1.0">
         <w>
            <xsl:apply-templates select="tei:sic"/>
         </w>
      </sep>
   </xsl:template>
   <xsl:template match="tei:abbr | tei:orig">
      <xsl:element name="{name()}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>

   <!-- removing elements not used currently -->
   <xsl:template match="tei:supplied | tei:damageSpan | tei:link | tei:anchor | tei:ref"> </xsl:template>
   <xsl:template match="tei:num | tei:persName[ancestor-or-self::tei:text]">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:trnsp-seg">
      <!-- element marks areas that need manual correction, from word transcriptions ...-->
      <sep mlns="http://www.tei-c.org/ns/1.0"/>
      <xsl:apply-templates/>
   </xsl:template>


   <xsl:template match="text()[ancestor::tei:ab or ancestor::tei:head or ancestor::tei:trailer]">
      <xsl:variable name="curr" select="parent::*/name()"/>
      <xsl:choose>
         <xsl:when
            test="not(ancestor::tei:surplus | ancestor::tei:fw | ancestor::tei:note | ancestor::tei:surplus | ancestor::tei:w | ancestor::tei:label | ancestor::tei:pc | ancestor::tei:abbr)">
            <xsl:analyze-string select="." regex="\s+">
               <xsl:matching-substring>
                  <xsl:choose>
                     <xsl:when test="not($curr = 'expan')">
                        <sep xmlns="http://www.tei-c.org/ns/1.0"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="."/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:matching-substring>
               <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
               </xsl:non-matching-substring>
            </xsl:analyze-string>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- grouping -->
   <xsl:template match="tei:ab | tei:head | tei:trailer" mode="group">
      <xsl:element name="{name()}">
         <xsl:copy-of select="@*"/>
         <!-- namespace problem I can't sort out -->
         <xsl:for-each-group select="node()" group-adjacent="not(self::tei:sep)">
            <xsl:choose>
               <xsl:when test="current-grouping-key()">
                  <w>
                     <xsl:copy-of select="current-group()"/>
                  </w>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="current-group()/self::tei:sep/node()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each-group>
      </xsl:element>
   </xsl:template>

   <xsl:template match="tei:w[normalize-space()]" mode="cleanup">
      <xsl:choose>
         <!--    Kludge: found ws in output that consisted solely of note.    -->
         <xsl:when test="not(tei:note[not(following-sibling::node() | preceding-sibling::node())])">
            <w>
               <xsl:copy-of select="@*[not(name() = 'xml:id' or name() = 'n')]"/>
               <xsl:attribute name="xml:id"
                  select="concat(ancestor-or-self::*[self::tei:ab | self::tei:head | self::tei:trailer]/@xml:id, '.', count(preceding-sibling::tei:w[normalize-space()]) + 1)"/>
               <!--<xsl:apply-templates mode="cleanup"/>-->
               <xsl:apply-templates mode="cleanup"/>
            </w>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="tei:note"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:w[not(normalize-space())]" mode="cleanup">
      <!-- this may remove w that are place holders for unreadable text. -->
      <xsl:copy-of select="node()"/>
   </xsl:template>
   <xsl:template match="tei:ptr" mode="cleanup">
      <ptr xmlns="http://www.tei-c.org/ns/1.0">
         <xsl:variable name="curr" select="current()"/>
         <xsl:variable name="id-val"
            select="
               if (preceding::tei:w[@n = substring-after($curr/@target, '#')]) then
                  concat('#', preceding::tei:w[@n = substring-after($curr/@target, '#')]/ancestor-or-self::*[self::tei:ab | self::tei:head | self::tei:trailer]/@xml:id, '.', count(preceding::tei:w[@n = substring-after($curr/@target, '#')]/preceding-sibling::tei:w[normalize-space()]) + 1)
               else
                  'null'"/>
         <xsl:attribute name="target"
            select="
               if ($id-val = 'null') then
                  @target
               else
                  $id-val"/>

      </ptr>
   </xsl:template>
   <xsl:template match="tei:sep" mode="cleanup">
      <!-- better design would have obviated this step -->
      <!-- retaining just in case there are residual -->
      <xsl:copy-of select="node()"/>
   </xsl:template>
</xsl:stylesheet>
