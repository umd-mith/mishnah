<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="html" encoding="UTF-8"/>
    <xsl:param name="mcite"/>
    <xsl:param name="tractName"/>
    <xsl:param name="unit"/>
    <!-- Assembles the parts of the "edit" module of the demo -->

    <xsl:template match="/" xmlns="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tempDiv">

        <div class="about" stye="clear:both" style="width:60%;direction:ltr"
            xmlns="http://www.w3.org/1999/xhtml" title="Digital Mishnah Project: Compare Witnesses">
            <h2>Edit Collations <span class="tractate">
                    <xsl:value-of select="replace($tractName,'_',' ')"/>
                </span>
                <xsl:analyze-string select="$mcite" regex="\d\.\d\.(.*)">
                    <xsl:matching-substring>
                        <xsl:text> </xsl:text><xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </h2>
            <div id="shown">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">About this Page</a>
                </p>
            </div>
            <div id="hidden" style="display:none;">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
                <p>To be added.</p>
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
            </div>

        </div>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'dropdown']"/>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'js_app-container']"/>
    </xsl:template>
</xsl:stylesheet>
