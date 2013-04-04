<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <!-- Creates a ref list of the full Mishnah to test the presence of witnesses against.
        Aggregated with "groupedList.xml in Cocoon for processing. -->
    <!-- Once witnesses cover whole Mishnah can dispense with this step. -->
    <xsl:variable name="list">
        <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:div1">
            <my:order>
                <xsl:copy-of select="@xml:id"/>
                <xsl:copy-of select="@n"/>
                <xsl:for-each select="tei:div2">
                    <my:tract>
                        <xsl:copy-of select="@xml:id"/>
                        <xsl:copy-of select="@n"/>

                        <xsl:for-each select="tei:div3">
                            <my:chapter>
                                <xsl:copy-of select="@xml:id"/>
                                <xsl:copy-of select="@n"/>
                                <xsl:for-each select="tei:ab">
                                    <my:mishnah>
                                        <xsl:copy-of select="@xml:id"/>
                                        <xsl:copy-of select="@n"/>
                                    </my:mishnah>
                                </xsl:for-each>
                            </my:chapter>
                        </xsl:for-each>
                    </my:tract>
                </xsl:for-each>


            </my:order>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <my:struct xmlns:my="local-functions.uri"><xsl:copy-of select="$list"/></my:struct>
    </xsl:template>
    
</xsl:stylesheet>
