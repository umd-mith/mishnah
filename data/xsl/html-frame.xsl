<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xd"
  version="2.0"
>
  <xsl:output encoding="UTF-8" indent="yes" method="html"/>
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> February 14, 2013</xd:p>
      <xd:p><xd:b>Author:</xd:b> tbrown</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:param name="menu-mode"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title><xsl:value-of select="div/@title" /></title>
        <link href="./css/FormattingforHTML.css" rel="stylesheet" type="text/css" />
        <link href="./css/demo-styles.css" rel="stylesheet" type="text/css" />
        <xml:if test="$menu-mode = 'collation'">
          <link href="./css/CollatexOutput.css" rel="stylesheet" type="text/css" />
        </xml:if>
        <link href="./images/favicon.ico" rel="icon" type="image/ico" />
      </head>
      <body>
        <header id="header">
          <a href="demo"><img src="./images/mishnah_logo.png" width="413" height="61" alt="Digital Mishnah" /></a>
        </header>
        <!--
          I don't particularly like handling the menu in this way, but it'll
          have to do for now.
        -->
        <xsl:choose>
          <xsl:when test="$menu-mode = 'browse-param'">
            <div class="contents">
              <h2>
                <a href="demo">Back to demo home</a>
                <a href="browse">Back to browse page</a>
              </h2>
            </div>
          </xsl:when>
          <xsl:when test="$menu-mode = 'collation'">
            <div class="contents">
              <h2>
                <a href="demo">Back to demo home</a>
                <a href="#select">Select passage and witnesses</a>
                <a href="#align">Alignment table format</a>
                <a href="#text-appar">Text with apparatus</a>
                <a href="#synopsis">Parallel column synopsis</a>
              </h2>
            </div>
          </xsl:when>
        </xsl:choose>
        <div class="hrlineB">&#160;</div>
        <xsl:apply-templates/>
        <footer id="footer" class="footer-wrap">
          <div class="hrlineB">&#160;</div>
            <div class="footer">
              <div class="info">
                <div class="fl">&#169; 2012&#8211;2013 Digital Mishnah</div>
                <div class="fr">Developed by Hayim Lapin with support from the <a href="http://mith.umd.edu/" title="MITH" target="_blank">Maryland Institute of Technology in the Humanities (MITH)</a>.</div>
              </div>
              <div class="credit">The technological infrastructure for this project has been supported in part by a generous grant from <a href="http://aws.amazon.com/" target="_blank">Amazon Web Services</a>.<br/>
                Except where otherwise noted, content on this site is licensed under a 
                <a rel="license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 License</a>.
              </div>
            </div>
          </footer>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

