<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    exclude-result-prefixes="xd cx" version="2.0">
    <xsl:output method="html" indent="no" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 8, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- xslt transformation of output from collatex demo for automated transformation in Cocoon
        pipeline.  -->
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/CollatexOutput.css"
                    title="Documentary"/>
                <title>Sample Collatex Output</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body xsl:exclude-result-prefixes="#all" dir="rtl">
                <h1>Digital Mishnah Project</h1>
                <h2>Sample Collatex Output, Alignment Table Format</h2>
                <table dir="rtl">
                    <xsl:for-each select="/cx:alignment/cx:row">
                        <tr>
                            <td>
                                <span class="wit" >
                                    <xsl:value-of select="./@sigil"/>
                                </span>
                            </td>
                       
                        <xsl:for-each select="cx:cell">

    <!-- if empty add emdash -->
                                    <xsl:if test=".=''"><td><xsl:text>–</xsl:text></td></xsl:if>
                                    <!-- else, if not empty, insert token -->
                                    <xsl:if test=".!=''"><td><xsl:value-of select="."></xsl:value-of></td></xsl:if>
                            
                            
                        </xsl:for-each>
                            <td>
                                <span class="wit">
                                    <xsl:value-of select="./@sigil"/>
                                </span>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
