<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs tei xhtml" version="2.0">

   <xsl:output method="html" indent="yes" encoding="UTF-8"/>
   <xsl:strip-space elements="*"/>

   <xsl:param name="mcite" select="'4.2.5.1'"/>
   <xsl:param name="wits" select="'S07397,S07326,S00651,S00483,S01520,S08174,P00001,P179204,S07319,S08010,P00002,S07204,S07106,S07394'"/>
   
   <xsl:variable name="base" select="tokenize($wits, ',')[1]"/>
   <xsl:variable name="witList" select="tokenize($wits, ',')[position() &gt; 1]"/>
   
   <xsl:variable name="collation" select="*/*[1]"/>
   <xsl:variable name="w-data" select="//tei:w"/>
   <xsl:template match="/">
      
      <!--<xsl:copy-of select="$w-data/id('S07397.4.2.5.1.5')"></xsl:copy-of>-->
      <xsl:apply-templates select="$collation/*"/>
   </xsl:template>
   <xsl:template match="element() | @* | text()">
      <xsl:copy>
         <xsl:apply-templates select="element() | text() | @*"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="tei:teiHeader"/>
   <xsl:template match="tei:TEI | tei:text | tei:body">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="tei:ab[tei:app]">
      
      <!--<div class="apparatus">-->
         <xsl:for-each-group select="tei:app" group-adjacent="boolean(tei:rdgGrp[@n = 'empty']/tei:rdg[contains(@wit,$base)])">
            <!-- above a bit generic while settling format of target XML.  -->
            <xsl:choose>
               <xsl:when test="current-grouping-key()">
                  <!-- base text absent at this locus -->
                  <xsl:call-template name="baseAbsentAtLocus"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:for-each select="current-group()">
                     <xsl:choose>
                        <!-- test for special case where last precedes absent token in following -->
                        <xsl:when test="following-sibling::*[1]/tei:rdgGrp[@n = 'empty']/tei:rdg[contains(@wit, $base)]">
                           <!-- do nothing, handled with group where base does not have text --> </xsl:when>
                        <xsl:otherwise>
                           <xsl:call-template name="basePresentAtLocus"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:for-each>

               </xsl:otherwise>

            </xsl:choose>
         </xsl:for-each-group>
      <!--</div>-->
   </xsl:template>

   <xsl:template name="basePresentAtLocus">
      <!-- exclude cases where all readings are identical -->
      <xsl:if test="count(tei:rdgGrp[1]/tei:rdg) &lt; count($witList) + 1">
         <div class="locusGrp" id="{@xml:id}">
            <!-- readings that match base -->
            <span class="matchesBase">
               <xsl:call-template name="sigla">
                  <xsl:with-param name="theseWits" select="tei:rdgGrp[tei:rdg[contains(@wit, $base)]]/tei:rdg/@wit"/>
               </xsl:call-template>
            </span>
            <!-- pre-determined reading groups internally sorted by user order -->
            <xsl:for-each select="tei:rdgGrp[not(@n = 'empty')][not(tei:rdg/@wit[contains(., $base)])]">
               <span class="rdgGrp grp-{@n}">
                  <span class="rdg">
                     <xsl:for-each select="tei:rdg[1]/tei:ptr/@target">
                        <xsl:variable name="id" select="tokenize(., ' ')"/>
                        <xsl:apply-templates select="$w-data/id(substring-after(tokenize($id[1], '-')[1], '#'))">
                           <xsl:with-param name="h" select="if (contains($id, '-h')) then   tokenize($id[1], '-')[last()] else ''" tunnel="yes"/>
                        </xsl:apply-templates>
                     </xsl:for-each>
                  </span>
                  <xsl:call-template name="sigla">
                     <xsl:with-param name="theseWits" select="tei:rdg/@wit"/>
                  </xsl:call-template>
               </span>
            </xsl:for-each>
            <!-- finally, cases where witness other than base did not have a corresponding reading -->
            <xsl:if test="current-group()/tei:rdgGrp[@n = 'empty']">
               <span class="rdgGrp empty">
                  <xsl:call-template name="sigla">
                     <xsl:with-param name="theseWits" select="current-group()/tei:rdgGrp[@n = 'empty']/tei:rdg/@wit"/>
                  </xsl:call-template> 
               </span>
            </xsl:if>
         </div>
      </xsl:if>
   </xsl:template>
   <xsl:template name="baseAbsentAtLocus">
      <!-- base text is absent at this locus -->
      <!-- merge with last preceding locus that has reading -->
      <div class="locusGrp" id="{@xml:id}">
         <span class="rdg">
            <xsl:for-each select="current-group()[1]/preceding-sibling::*[1]/tei:rdgGrp/tei:rdg[contains(@wit,$base)]/tei:ptr/@target">
               <xsl:variable name="id" select="tokenize(., ' ')"/>
               <xsl:apply-templates select="$w-data/id(substring-after(tokenize($id[1], '-')[1], '#'))">
                  <xsl:with-param name="h" select="                         if (contains($id, '-h')) then                            tokenize($id[1], '-')[last()]                         else                            ''" tunnel="yes"/>
               </xsl:apply-templates>
            </xsl:for-each>
            <xsl:text> ...</xsl:text>
         </span>
         <xsl:variable name="groups">
            <xsl:for-each-group select="(current-group()[1]/preceding-sibling::*[1] | tei:rdg | current-group())//tei:rdg" group-by="@wit">
               <!-- grp is the group of tokens associated with these columns -->
               <grp n="{@wit}">
                  <sort>
                     <xsl:value-of select="                            for $t in current-group()/tei:ptr/@target                            return                               $w-data/id(replace(substring-after($t, '#'), '-h[\d]', ''))"/>
                  </sort>
                  <use>
                     <xsl:for-each select="current-group()/tei:ptr/@target">
                        <xsl:variable name="id" select="tokenize(., ' ')"/>
                        <xsl:apply-templates select="$w-data/id(substring-after(tokenize($id[1], '-')[1], '#'))">
                           <xsl:with-param name="h" select="                                  if (contains($id, '-h')) then                                     tokenize($id[1], '-')[last()]                                  else                                     ''" tunnel="yes"/>
                        </xsl:apply-templates>
                     </xsl:for-each>
                  </use>
               </grp>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:if test="$groups/xhtml:grp[@n = $base]/xhtml:sort = $groups/xhtml:grp[@n != $base]/xhtml:sort">
            <span class="matchesBase merged">
               <span class="sigla">
                  <!-- too long an expression? -->
                  <xsl:variable name="witsInGrp" select="$groups/xhtml:grp[@n != $base][xhtml:sort = $groups/xhtml:grp[@n = $base]/xhtml:sort]/@n"/>
                  <xsl:value-of select="                         for $i in $witList                         return                            if ($i = $witsInGrp) then                               $i                            else                               ()"/>
               </span>
            </span>

         </xsl:if>

         <xsl:for-each-group select="$groups/xhtml:grp" group-by="xhtml:sort">
            <xsl:choose>
               <xsl:when test="not($base = current-group()/@n) and current-group()//xhtml:sort[normalize-space(.)]">
                  <span class="rdgGrp merged">
                     <span class="rdg">
                        <xsl:copy-of select="current-group()[1]//xhtml:use/*"/>
                     </span>
                     <span class="sigla">
                        <xsl:variable name="witsInGrp" select="current-group()/@n"/>
                        <xsl:value-of select="                               for $i in $witList                               return                                  if ($i = $witsInGrp) then                                     $i                                  else                                     ()"/>
                     </span>
                  </span>
               </xsl:when>
               <xsl:when test="current-group()//xhtml:sort[not(normalize-space(.))]">
                  <span class="rdgGrp empty">
                     <xsl:variable name="witsInGrp" select="current-group()/@n"/>
                     <span class="sigla">
                        <xsl:value-of select="                               for $i in $witList                               return                                  if ($i = $witsInGrp) then                                     $i                                  else                                     ()"/>
                     </span>
                  </span>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each-group>
      </div>
   </xsl:template>
   <xsl:template name="sigla">
      <xsl:param name="theseWits"/>
      <span class="sigla">
         <xsl:variable name="witsInGrp" select=" for $w in $theseWits return replace($w,'^#','')"/>
         <xsl:value-of select="                            for $i in $witList                            return                               if ($i = $witsInGrp) then                                  $i                               else                                  ()"/>
      </span>
   </xsl:template>


   <!-- these templates apply to w tokens drawn from original texts (descendants of $w-data) -->
   <xsl:template match="tei:w">
      <xsl:param name="h" tunnel="yes"/>
      <xsl:choose>
         <xsl:when test="tei:choice">
            <xsl:apply-templates>
               <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>--> </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <span class="surface">
               <!--id="{concat(@xml:id, if ($h) then
               concat('-',$h) else ())}">-->
               <xsl:choose>
                  <xsl:when test="$h = 'h2' and not(descendant-or-self::tei:addSpan[@type = 'add'] | descendant-or-self::tei:delSpan | descendant-or-self::tei:anchor[@type = 'add'] | descendant-or-self::tei:anchor[@type = 'del'])">
                     <span class="add">
                        <xsl:apply-templates>
                           <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>-->
                        </xsl:apply-templates>
                     </span>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates>
                        <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>-->
                     </xsl:apply-templates>
                  </xsl:otherwise>
               </xsl:choose>
            </span>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="tei:choice">
      <!--      <xsl:param name="h" tunnel="yes"></xsl:param>-->
      <span class="choice">
         <xsl:apply-templates>
            <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>--> </xsl:apply-templates>
      </span>
   </xsl:template>
   <xsl:template match="tei:abbr | tei:orig">
      <xsl:param name="h" tunnel="yes"/>
      <xsl:variable name="id"/>
      <span class="surface {name()}">
         <!--id="{concat(ancestor::tei:w/@xml:id/string(),if ($h) then
         concat('-',$h) else ())}">-->
         <xsl:choose>
            <xsl:when test="$h = 'h2' and not(descendant-or-self::tei:addSpan[@type = 'add'] | descendant-or-self::tei:delSpan | descendant-or-self::tei:anchor[@type = 'add'] | descendant-or-self::tei:anchor[@type = 'del'])">
               <span class="add">
                  <xsl:apply-templates>
                     <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>-->
                  </xsl:apply-templates>
               </span>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates>
                  <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>--> </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </span>
   </xsl:template>
   <xsl:template match="tei:expan">
      <xsl:param name="h" tunnel="yes"/>
      <span class="expan">
         <!--<xsl:attribute name="id"><xsl:if
         test="
            concat(ancestor::tei:w/@xml:id/string(), if ($h) then
               concat('-', $h)
            else
               ())"/></xsl:attribute>-->
         <xsl:apply-templates>
            <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>--> </xsl:apply-templates>
      </span>
   </xsl:template>

   <xsl:template match="tei:anchor | tei:delSpan | tei:addSpan | tei:damageSpan | tei:reg"/>


   <xsl:template match="tei:am | tei:c">
      <!--<xsl:param name="h" tunnel="yes"></xsl:param>-->
      <xsl:apply-templates>
         <!--<xsl:with-param name="h" select="$h" tunnel="yes"/>--> </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="tei:lb[@break = 'no']">
      <xsl:text>|</xsl:text>
   </xsl:template>



   <xsl:template match="text()[ancestor::tei:w]">
      <xsl:param name="h" tunnel="yes"/>
      <!-- uses xpath expressions originally worked out for xquery rather than xsl:choice -->
      <xsl:variable name="addDel">
         <xsl:variable name="addSpan" select="preceding-sibling::tei:addSpan[1][@type = 'add']"/>
         <xsl:variable name="addAnchor" select="following-sibling::tei:anchor[1][@type = 'add']"/>
         <xsl:variable name="delSpan" select="preceding-sibling::tei:delSpan[1]"/>
         <xsl:variable name="delAnchor" select="preceding-sibling::tei:delSpan[1]"/>
         <xsl:value-of select="                if ($addAnchor[@xml:id = substring-after($addSpan/@spanTo, '#')]) then                   'add'                else                   if (($addAnchor and not(exists($addSpan))) or ($addSpan and not(exists($addAnchor)))) then                      'add'                   else                      if ($delAnchor[@xml:id = substring-after($delSpan/@spanTo, '#')]) then                         'del'                      else                         if (($delAnchor and not(exists($delSpan))) or ($delSpan and not(exists($delAnchor)))) then                            'del'                         else                            ()"/>
      </xsl:variable>
      <xsl:variable name="dam">
         <xsl:variable name="damageSpan" select="preceding-sibling::tei:damageSpan[1]"/>
         <xsl:variable name="damageAnchor" select="following-sibling::tei:anchor[1][@type = 'damage']"/>
         <xsl:value-of select="                if ($damageAnchor[@xml:id = substring-after($damageSpan/@spanTo, '#')]) then                   'damage'                else                   if (($damageAnchor and not(exists($damageSpan))) or ($damageSpan and not(exists($damageAnchor)))) then                      'damage'                   else                      ()"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="not(normalize-space(.))">
            <!-- do nothing --> </xsl:when>
         <xsl:when test="$h = 'h2'">
            <xsl:choose>
               <xsl:when test="$addDel = 'add'">
                  <span>
                     <xsl:attribute name="class" select="$addDel | $dam" separator=" "/>
                     <xsl:value-of select="normalize-space(.)"/>
                  </span>
               </xsl:when>
               <xsl:when test="$addDel = 'del'">
                  <span>
                     <xsl:attribute name="class" select="$addDel | $dam" separator=" "/>
                     <xsl:value-of select="normalize-space(.)"/>
                  </span>
               </xsl:when>
               <xsl:when test="$addDel = 'damage'">
                  <span>
                     <xsl:attribute name="class" select="$dam"/>
                     <xsl:value-of select="normalize-space(.)"/>
                  </span>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space(.)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$h = 'h1'">
            <xsl:choose>
               <xsl:when test="$addDel = 'add'"><!-- omit --></xsl:when>
               <xsl:when test="$addDel = 'del' and not($dam = 'damage')">
                  <xsl:value-of select="normalize-space(.)"/>
               </xsl:when>
               <xsl:when test="$addDel = 'damage'">
                  <span>
                     <xsl:attribute name="class" select="$dam"/>
                     <xsl:value-of select="normalize-space(.)"/>
                  </span>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space(.)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$dam = 'damage'">
            <!-- automatically has already treated cases if h1 and h2 -->
            <span>
               <xsl:attribute name="class" select="$dam"/>
               <xsl:value-of select="normalize-space(.)"/>
            </span>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>