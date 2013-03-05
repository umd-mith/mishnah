<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 29, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <!--<html>
            <head>
                <title>Browse Digital Mishnah Files</title>
            </head>
            <body style="width:75%; margin-right:15%; margin-left:15%;">-->
        
            
        <div class="about" title="Browse Digital Mishnah Files">
            <h2>Browse Files from the Digital Mishnah Project</h2>
            <div id="shown" style="direction:ltr;"><p>
                <a class="toggle" href="javascript:toggle('hidden')">About this Page</a></p></div>
            <div id="hidden" style="direction:ltr;display:none;"><p><a class="toggle" 
                href="javascript:toggle('hidden')">Hide Description</a></p><p>Files are stored as XML, following the TEI (Text Encoding Initiative)
                    specifications. They are presented in converted into HTML using XSLT on the fly,
                    using a Cocoon pipeline. Most sigla for manuscript witnesses are based on the <i>Thesaurus of Talmud
                    Manuscripts</i>, ed. Sussmann et al. (Jerusalem: Yad Izhak ben Zvi and Friedenberg
                    Genizah Project, 2012), preceded by "S". Print editions are given a serial number of the same type, preceded by "P".</p>
                <p>In future versions, these sigla will be enriched to indicate type of manuscript
                    (e.g., Mishnah alone or with commentary; Talmud text) and other information.</p>
                <p>Sigla of the type "Kauf" are legacy files, that are part of the initial demo
                    based on Chapter 2 of Bava Metsi'a.</p>
                <p>Genizah fragments are encoded whole. Other witness files, except legacy files,
                    encode the text of Bava Qamma, Bava Metsi'a, and Bava Batra. Legacy files
                    include only Chapter 2 of Bava Metsi'a, and are gradually being replaced.</p>
                <p>The heading "J.G.M." refers to joined Genizah fragments as identified in the Sussmann Catalog. At a later stage, the project will provide virtual joins of such fragments. It will also extend joining to other manuscripts (e.g., the Maimonides autograph ms).</p>
                <p>Click "TEI/XML" to see the underlying TEI encoding.</p>
                <p><a class="toggle"
                    href="javascript:toggle('hidden')">Hide Description</a></p></div>

            </div>
        <div class="browse"><h2>Witness List</h2><table style="width:90%; margin-right:5%; margin-left:5%;">
                    <xsl:apply-templates select="*/*/*/tei:sourceDesc/tei:listWit//tei:listWit"/>
                </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:witness[@corresp]">
       
            <xsl:variable name="fileURI">
                <xsl:value-of select="concat('../tei/',@corresp)"/>
            </xsl:variable>
        <tr style="vertical-align:top">
                <td style="font-weight:bold; padding-right:5;">
                    <xsl:variable name="source" xmlns:tei="http://www.tei-c.org/ns/1.0">
                        <xsl:sequence select="document($fileURI,(document('')))"/>
                    </xsl:variable>
                    <xsl:variable name="linkToFirst">
                        <xsl:value-of select="@xml:id"/>
                        <xsl:text>.browse-param.html?mode=pg</xsl:text>
                        <xsl:text>&amp;pg=</xsl:text>
                        <xsl:value-of
                            select="substring-after(($source/tei:TEI/tei:text/tei:body//tei:pb)[1]/@xml:id,concat(@xml:id,'.'))"/>
                        <xsl:text>&amp;col=</xsl:text>
                        <xsl:value-of
                            select="substring-after(($source/tei:TEI/tei:text/tei:body//tei:cb)[1]/@xml:id,concat(@xml:id,'.'))"/>
                        <xsl:text>&amp;ch=</xsl:text>
                        <xsl:value-of
                            select="substring-after(($source/tei:TEI/tei:text/tei:body//tei:div3)[1]/@xml:id,concat(@xml:id,'.'))"
                        />
                    </xsl:variable>
                    <a href="{$linkToFirst}">
                        <xsl:value-of select="@xml:id"/>
                    </a>
                </td>
                <td>
                    <xsl:value-of select="text()"/>
                    <xsl:text>
                            (</xsl:text>
                    <span style="font-size:75%;">
                        <a href="{substring-before(@corresp, '.xml')}.xml">TEI/XML</a>
                    </span>
                    <xsl:text>)</xsl:text>
                </td>
            </tr>
        
    </xsl:template>
    <xsl:template match="tei:listWit">
        <xsl:if test="@n">
            <tr style="height:36;"><td></td><td style="font-weight:bold; padding-right:5;"><xsl:value-of select="@n"></xsl:value-of></td></tr>
            <xsl:apply-templates select="tei:witness"></xsl:apply-templates>
        </xsl:if>
        <xsl:if test="@xml:id">
            <tr style="height:36px;"><td></td><td style="font-weight:bold; padding-right:5;"><xsl:value-of select="@xml:id"></xsl:value-of>
                <xsl:apply-templates select="tei:witness"></xsl:apply-templates></td></tr>
        </xsl:if>
            
        
    </xsl:template>

</xsl:stylesheet>
