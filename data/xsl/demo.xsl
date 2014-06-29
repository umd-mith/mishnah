<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd"
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="html"></xsl:output>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 29, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:TEI/tei:teiHeader"></xsl:template>
    <xsl:template match="/">
        <!--<html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>Digital Mishnah Project Demo</title>
                <link href="./css/FormattingforHTML.css" rel="stylesheet" type="text/css" />
                <link href="./css/demo-styles.css" rel="stylesheet" type="text/css" />
                <link href="./images/favicon.ico" rel="icon" type="image/ico" />
            </head>
            <body>
                <header id="header">
                  <img src="./images/mishnah_logo.png" width="413" height="61" alt="Digital Mishnah" />
                </header>
                <div class="hrlineB">&#160;</div>-->
                <div class="about">
                <h2>About this demo</h2>
                <p>
                    The <a class="highlighted" href="http://blog.umd.edu/digitalmishnah/">Digital Mishnah Project</a> will provide users with a database of digitized manuscripts of the Mishnah from around the world, along with tools for collation, comparison, and analysis. This demo provides fully marked up transcriptions of twenty-two witnesses to a sample chapter, <cite>Bava Metsia</cite> ch 2, and illustrates basic functionalities.
                </p>
                <p>
                  The <a class="highlighted" href="browse">browse</a> function presents metadata and a rendering of the transcription that which can be viewed with their metadata and approximately as laid out in the original text.
                </p>
                <p>
                  The <a class="highlighted" href="collate-hl">collate</a> function allows for the detailed comparison of witnesses. At its core it runs a set of texts through <a href="http://www.collatex.net/">CollateX</a>, which aligns matching words ("tokens"). The Digital Mishnah site remerges this output with the original textual data and represents the results both as an alignment table, and as a text with critical apparatus. The user can determine the passage, the witnesses, and the order. Because we anticipate that a number of users will prefer a parallel-column ("synoptic") presentation, the collate page shows an arrangement of the selected passage arranged in parallel columns by witness in the user-specified order.
                </p>
                </div>
                <!--<xsl:for-each select="tei:TEI/tei:text/tei:body/tei:p"><p><xsl:value-of
                    select="."/></p></xsl:for-each>
                <form name="selection" action="collate-hl" method="get">
                    <input value="Collate" type="submit" ></input><span
                        style="display:inline-block;font-style:italic;">&#xa0;&#xa0;Collate and
                        process selected
                        witnesses</span>
                </form>    
                <form name="selection" action="browse" method="get">
                    <input value="Browse" type="submit" ></input><span
                        style="display:inline-block;font-style:italic;">&#xa0;&#xa0;Browse individual transcriptions. Layout approximates page layout of the original witness</span>
                </form>-->
                <!--<footer id="footer" class="footer-wrap">
                  <div class="hrlineB">&#160;</div>
                  <div class="footer">
                    <div class="info">
                      <div class="fl">&#169; 2012&#8211;2013 Digital Mishnah</div>
                      <div class="fr">Developed by Hayim Lapin with support from the <a href="http://mith.umd.edu/" title="MITH" target="_blank">Maryland Institute of Technology in the Humanities (MITH)</a>.</div>
                    </div>
                    <div class="credit">The technological infrastructure for this project has been supported in part by a generous grant from <a href="http://aws.amazon.com/" target="_blank">Amazon Web Services</a>.</div>
                  </div>
                </footer>
            </body>
        </html>-->
    </xsl:template>
</xsl:stylesheet>
