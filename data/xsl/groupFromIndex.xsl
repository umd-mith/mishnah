<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:my="local-functions.uri" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes" encoding="UTF-8"/>
    <!-- Possible values for unit: all, tract, ch, m -->
    <xsl:param name="unit" select="'ch'"/>
    <xsl:param name="mcite" select="'4.2.2'"/>
    <xsl:variable name="use-param">
        <xsl:choose>
            <xsl:when test="$unit = ''"><xsl:text>all</xsl:text></xsl:when>
            <xsl:otherwise><xsl:value-of select="$unit"></xsl:value-of></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="/">
        <my:composList>
            <xsl:apply-templates/>
        </my:composList>
    </xsl:template>

    <xsl:template match="my:index">
        <xsl:copy-of select="tei:listWit"></xsl:copy-of>
        <xsl:variable name="composite">
            <xsl:for-each select="my:witness">
                <xsl:copy-of select="* except ."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$use-param = 'all'">
                <xsl:for-each-group select="$composite/my:mishnah" group-by="@order">
                    <my:ord-compos n="{current-grouping-key()}">
                        <xsl:for-each-group select="current-group()" group-by="@tractate">
                            <my:tract-compos n="{current-grouping-key()}">
                                <xsl:for-each-group select="current-group()" group-by="@chapter">
                                    <my:ch-compos n="{current-grouping-key()}">
                                        <xsl:for-each-group select="current-group()" group-by="@n">
                                            <my:m-compos>
                                                <xsl:attribute name="n"
                                                  select="current-grouping-key()"/>
                                                <xsl:for-each-group select="current-group()"
                                                  group-by="@name">
                                                  <my:wit-compos>
                                                  <xsl:value-of select="current-grouping-key()"/>
                                                  </my:wit-compos>
                                                </xsl:for-each-group>
                                            </my:m-compos>
                                        </xsl:for-each-group>


                                    </my:ch-compos>
                                </xsl:for-each-group>
                            </my:tract-compos>
                        </xsl:for-each-group>
                    </my:ord-compos>

                </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="$use-param='m'">
                
                <xsl:for-each-group select="$composite/my:mishnah" group-by="@n">
                    <xsl:if test="current-grouping-key()=$mcite">
                        <my:m-active-compos>
                            <xsl:attribute name="n" select="current-grouping-key()"/>
                            <xsl:for-each-group select="current-group()" group-by="@name">
                                <my:wit-compos>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </my:wit-compos>
                            </xsl:for-each-group>
                        </my:m-active-compos>
                    </xsl:if>

                </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="$use-param='ch'">
                <xsl:for-each-group select="$composite/my:mishnah" group-by="@chapter">
                    <xsl:if test="current-grouping-key()=$mcite">
                        <my:ch-compos>
                            <xsl:attribute name="n" select="current-grouping-key()"/>
                            <xsl:for-each-group select="current-group()" group-by="@name">
                                <my:wit-compos>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </my:wit-compos>
                            </xsl:for-each-group>
                        </my:ch-compos>
                    </xsl:if>
                    
                </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="$use-param='tract'">
                <xsl:for-each-group select="$composite/my:mishnah" group-by="@tractate">
                    <xsl:if test="current-grouping-key()=$mcite">
                        <my:ch-compos>
                            <xsl:attribute name="n" select="current-grouping-key()"/>
                            <xsl:for-each-group select="current-group()" group-by="@name">
                                <my:wit-compos>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </my:wit-compos>
                            </xsl:for-each-group>
                        </my:ch-compos>
                    </xsl:if>
                    
                </xsl:for-each-group>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>
