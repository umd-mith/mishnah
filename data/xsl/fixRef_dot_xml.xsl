<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div1">
        <xsl:element name="div1" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
             <xsl:apply-templates select="tei:head"/>
            <xsl:apply-templates select="tei:div2"/>
            <xsl:apply-templates select="tei:trailer"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:div3">
        <xsl:variable name="elem-id">
            <xsl:choose>
                <xsl:when test="@xml:id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="getID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$elem-id"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:head|tei:trailer">

        <xsl:variable name="elem-id">
            <xsl:choose>
                <xsl:when test="@xml:id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="getID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$elem-id"/>
            </xsl:attribute>
            <xsl:variable name="no-id">
                <xsl:choose>
                    <xsl:when test="text()">
                        <xsl:call-template name="make-w">
                            <xsl:with-param name="text" select="concat(text(),' ')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="$no-id/node()">

                <xsl:element name="w" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="xml:id"
                        select="concat($elem-id,'.',count(preceding-sibling::tei:w)+1)"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:ab">

        <xsl:variable name="elem-id">
            <xsl:choose>
                <xsl:when test="@xml:id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="getID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$elem-id"/>
            </xsl:attribute>
            <xsl:variable name="no-id">
                <!-- Generates tokens first, in this variable, then adds IDS -->
                <xsl:for-each select="node()">
                    <xsl:choose>
                        <xsl:when test="self::tei:label">
                            <xsl:element name="{name()}" xmlns="http://www.tei-c.org/ns/1.0">
                                <xsl:variable name="elem-id">
                                    <xsl:choose>
                                        <xsl:when test="@xml:id">
                                            <xsl:copy-of select="@xml:id"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="." mode="getID"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$elem-id"/>
                                </xsl:attribute>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="self::tei:ref">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="self::text()">
                            <!-- call template to generate word elements -->
                            <xsl:call-template name="make-w">
                                <xsl:with-param name="text" select="concat(normalize-space(.),' ')"/>
                                <!-- Concat necessary to avoid empty w element at end of string. Don't understand why -->
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                <!-- now add IDs -->
            </xsl:variable>
            <xsl:for-each select="$no-id/node()">
                <xsl:choose>
                    <xsl:when test="self::tei:label|self::tei:ref">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="self::tei:w">
                        <xsl:element name="w" xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id"
                                select="concat($elem-id,'.',count(preceding-sibling::tei:w)+1)"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>

    <xsl:template match="node()" mode="getID">
        <xsl:variable name="prefix">
            <xsl:choose>
                <xsl:when test="ancestor::tei:div2">
                    <xsl:value-of select="ancestor::tei:div2/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="parent::tei:div1/@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ch">
            <xsl:choose>
                <xsl:when test="self::tei:div3">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="count(preceding-sibling::tei:div3)+1"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:div3">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="count(ancestor::tei:div3/preceding-sibling::tei:div3)+1"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mish">
            <xsl:choose>
                <xsl:when test="self::tei:ab">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="count(preceding-sibling::tei:ab)+1"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:ab">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="count(ancestor::tei:ab/preceding-sibling::tei:ab)+1"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="self::tei:head">
                    <xsl:text>.H</xsl:text>
                </xsl:when>
                <xsl:when test="self::tei:trailer">
                    <xsl:text>.T</xsl:text>
                </xsl:when>
                <xsl:when test="self::tei:label">
                    <xsl:text>.L</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space(concat($prefix,$ch,$mish,$suffix))"/>
    </xsl:template>
    <xsl:template name="make-w">
        <!-- borrows a template from M. Kay, XSLT 2.0, p. 887 -->
        <xsl:param name="text"> </xsl:param>
        <xsl:variable name="str" select="$text"/>
        <xsl:variable name="first" select="substring-before($str, ' ')"/>
        <xsl:variable name="rest" select="substring-after($str, ' ')"/>
        <xsl:element name="w" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="$first"/>
        </xsl:element>
        <xsl:if test="$rest">
            <xsl:call-template name="make-w">
                <xsl:with-param name="text" select="$rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:div2">
        <xsl:variable name="id">
            <xsl:variable name="prefix" select="'ref.xml'"/>
            <xsl:variable name="ord"
                select="normalize-space(concat('0',substring-before(substring-after(@xml:id,'ref.'),'.')))"/>
            <xsl:variable name="tract">
                <xsl:variable name="tract-num"
                    select="normalize-space(substring-after(substring-after(@xml:id,'ref.'),'.'))"/>
                <xsl:choose>
                    <xsl:when test="string-length($tract-num)=1">
                        <xsl:value-of select="normalize-space(concat('0',$tract-num,'.'))"/>
                    </xsl:when>
                    <xsl:when test="string-length($tract-num)=2">
                        <xsl:value-of select="normalize-space(concat($tract-num,'.'))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="normalize-space(concat($ord,$tract))"/>
        </xsl:variable>

        <xsl:variable name="fname" select="concat('ref-',$id,'xml')"/>
        <xsl:comment>ref to file containing <xsl:value-of select="@n"/>, <xsl:value-of select="$fname"/></xsl:comment>
        <xi:include href="{$fname}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
        <xsl:result-document href="{$fname}">
            <xsl:element name="div2" xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude">
                <xsl:copy-of select="@*"></xsl:copy-of>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:result-document>


    </xsl:template>
    <xsl:template match="/">
        
        <xsl:apply-templates/>
        
    </xsl:template>
</xsl:stylesheet>
