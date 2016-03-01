<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <!-- Receives a document generated by aggregation that has <div> top element and <my:struct> for index of ref.xml 
        and <my:composList> for composite index of all witnesses -->
    <!-- Uses fairly obtrusive (and not well conceived) javascript -->
    
    <xsl:param name="unit" select="'ch'"/>
    <xsl:param name="mcite" select="'4.2.2'"/>
    <xsl:variable name="prevLookup">
        
        <!-- reconstructs the previous lookup from xslt parameters, and uses as parameters in javascript:menuToggle() -->
        <xsl:choose>
            <xsl:when test="$unit = 'm'">
                <my:prevM>
                    <xsl:value-of select="concat('ref.',$mcite)"/>
                </my:prevM>
                <my:prevCh>
                    
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter/my:mishnah[@xml:id=concat('ref.',$mcite)]/parent::my:chapter/@xml:id"
                    />
                </my:prevCh>
                <my:prevTract>
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter/my:mishnah[@xml:id=concat('ref.',$mcite)]/ancestor::my:tract/@xml:id"
                    />
                </my:prevTract>
                <my:prevOrd>
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter/my:mishnah[@xml:id=concat('ref.',$mcite)]/ancestor::my:order/@n"
                    />
                </my:prevOrd>
            </xsl:when>
            <xsl:when test="$unit = 'ch'">
                <my:prevCh>
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter[@xml:id=concat('ref.',$mcite)]/@xml:id"
                    />
                </my:prevCh>
                <my:prevTract>
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter[@xml:id=concat('ref.',$mcite)]/parent::my:tract/@xml:id"
                    />
                </my:prevTract>
                <my:prevOrd>
                    <xsl:value-of
                        select="/my:div/my:struct/my:order/my:tract/my:chapter/my:mishnah[@xml:id=concat('ref.',$mcite)]/ancestor::my:order/@n"
                    />
                </my:prevOrd>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <div class="dropdown" xmlns="http://www.w3.org/1999/xhtml">
            <h3>Select Passages<a class="tooltip">[?]<span class="help"><em>Select Passage</em>To be added</span></a></h3>
            <ul class="order">
                <xsl:apply-templates/>
            </ul>
            <!--Adapted from https://developer.mozilla.org/en-US/docs/DOM/element.scrollIntoView-->
            <xsl:variable name="scrollTo">
                <xsl:choose>
                    <xsl:when test="$unit='ch'">
                        <xsl:value-of select="$prevLookup/my:prevCh"/>
                    </xsl:when>
                    <xsl:when test="$unit='m'">
                        <xsl:value-of select="$prevLookup/my:prevM"/>
                    </xsl:when>
                </xsl:choose>
                
            </xsl:variable>
            
            <xsl:if test="normalize-space($scrollTo) != ''">
                <script>
                    var showThis = document.getElementById(<xsl:value-of select="$scrollTo"/>);
                    showThis.scrollIntoView(true);</script>
            </xsl:if>
            
            
        </div>
    </xsl:template>
    <xsl:template match="div|my:struct">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="my:wits">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="my:order">
        <li xmlns="http://www.w3.org/1999/xhtml">
            <a class="toggle" href="javascript:menuToggle('{@n}')">
                <xsl:value-of select="@n"/>
            </a>
            <ul class="tract" id="{@n}">
                <xsl:apply-templates/>
            </ul>
        </li>
    </xsl:template>
    <xsl:template match="my:tract">
        <xsl:choose>
            <xsl:when
                test="substring-after(@xml:id,'ref.') = //my:tract-compos/@n">
                <!-- This tractate has chapter children -->
                <li class="tract-text" xmlns="http://www.w3.org/1999/xhtml">
                    
                    <a class="toggle" href="javascript:menuToggle('{@n}')">
                        <xsl:value-of select="replace(@n,'_',' ')"/>
                    </a>
                    <ul class="chapt" id="{@n}">
                        <xsl:apply-templates/>
                    </ul>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li class="tract-no-text" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:value-of select="replace(@n,'_',' ')"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="my:chapter">
        <xsl:choose>
            <xsl:when test="substring-after(@xml:id,'ref.') = //my:ch-compos/@n">
                <!-- This chapter has mishnah children -->
                <li xmlns="http://www.w3.org/1999/xhtml" class="ch-text">
                    
                    <a class="toggle" href="javascript:menuToggle('{@xml:id}')"
                        >Chapter <xsl:value-of
                            select="substring-after(@xml:id, concat(parent::my:tract/@xml:id, '.'))"
                        /></a>
                    <xsl:if
                        test="substring-after(@xml:id,'ref.') = //my:ch-compos/@n">
                        <ul class="mish" id="{@xml:id}">
                            <xsl:if test="@xml:id = $prevLookup/my:prevCh">
                                <xsl:attribute name="style"
                                    >display:block</xsl:attribute>
                            </xsl:if>
                            <xsl:apply-templates/>
                        </ul>
                    </xsl:if>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li class="ch-no-text" xmlns="http://www.w3.org/1999/xhtml">
                    Chapter <xsl:value-of
                        select="substring-after(@xml:id, concat(parent::my:tract/@xml:id, '.'))"
                    />
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="my:mishnah">
        <xsl:choose>
            <xsl:when test="substring-after(@xml:id,'ref.') = //my:m-compos/@n">
                <!-- This Mishnah has text -->
                <li xmlns="http://www.w3.org/1999/xhtml" class="indiv-m">
                    <a
                        href="edit?unit=m&amp;mcite={substring-after(@xml:id,'ref.')}&amp;tractName={ancestor::my:tract/@n}">
                        <xsl:value-of
                            select="concat('Mishnah ',substring-after(@xml:id, concat(ancestor::my:tract/@xml:id, '.')))"
                        />
                    </a>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li xmlns="http://www.w3.org/1999/xhtml" class="indiv-m-no-text">
                    <xsl:value-of
                        select="concat('Mishnah ',substring-after(@xml:id, concat(ancestor::my:tract/@xml:id, '.')))"
                    />
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="my:composList"/>
</xsl:stylesheet>
