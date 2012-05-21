<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="http://dev.digitalmishnah.org/local-functions.uri"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd cx tei my" version="2.0">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 8, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> hlapin</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!-- xslt transformation of output from collatex demo for automated transformation in Cocoon
pipeline. -->
    <!-- Parameters for cocoon transformation -->
    <xsl:param name="rqs"/>
    <xsl:param name="mcite" select="'4.2.2.1'"/>
    <xsl:variable name="cite" select="if (string-length($mcite) = 0) then '4.2.2.1' else $mcite"/>
    <xsl:variable name="queryParams" select="tokenize($rqs, '&amp;')"/>
    <xsl:variable name="sortlist" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
        select="document('../tei/ref.xml')/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit//tei:witness[@corresp]"> </xsl:variable>
    <xsl:variable name="refList" select="for $ab in
        document('../tei/ref.xml')/tei:TEI/tei:text/tei:body/tei:div1/tei:div2/tei:div3[@xml:id='ref.4.2.2']/tei:ab
        return substring-after($ab/@xml:id, 'ref.')"/>
    
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <link rel="stylesheet" type="text/css"
                    href="http://www.jewishstudies.umd.edu/faculty/Lapin/MishnahProject/CollatexOutput.css"
                    title="Documentary"/>
                <title>Sample Output Collatex Output</title>
                <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>
            </head>
            <body xsl:exclude-result-prefixes="#all" dir="rtl">
                <h1>Digital Mishnah Project</h1>
                <h2>Sample Collatex Output</h2>
                <h2>
                    <xsl:variable name="ref-cit" select="tei:TEI/tei:text/tei:body/tei:div/@n"> </xsl:variable>
                    <xsl:variable name="look-up">
                        <xsl:analyze-string select="$ref-cit"
                            regex="^([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                            <xsl:matching-substring>#ref.<xsl:value-of select="regex-group(1)"
                                    />.<xsl:value-of select="regex-group(2)"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:variable name="look-up-text">
                        <xsl:copy-of
                            select="document(normalize-space(concat('../tei/ref.xml',$look-up)),document(''))"
                        />
                    </xsl:variable>
                    <span class="tractate">
                        <xsl:value-of select="translate($look-up-text/*/@n,'_',' ')"/>
                    </span>
                    <xsl:analyze-string select="$ref-cit"
                        regex="^([0-9])\.([0-9]{{1,2}})\.([0-9]{{1,2}})\.([0-9]{{1,2}})$">
                        <xsl:matching-substring><xsl:text> </xsl:text><xsl:value-of
                                select="regex-group(3)"/>:<xsl:value-of select="regex-group(4)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </h2>
                <h3>1. Select a Passage</h3>
                <form name="selection" action="param-pass" method="get">                <div dir="ltr" style="text-align: center">
                    <select name="mcite">
                        <xsl:for-each select="$refList">
                            <option>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                                <xsl:if test=". = $cite">
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if> 
                                <xsl:variable name="lookup-text">
                                    <xsl:copy-of select="document(normalize-space(concat('../tei/ref.xml#ref.', substring(., 1, 3))),document(''))"/>
                                </xsl:variable>
                                <xsl:value-of select="translate($lookup-text/*/@n,'_',' ')"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="substring(., 5)"/>
                                <!--<xsl:value-of select="normalize-space(concat('../tei/ref.xml#ref.', substring($cite, 1, 3)))"/>-->
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                
                <h3>2. Sources for Collation</h3>
                <table class="sources" dir="ltr">
                    
                        <xsl:for-each select="$sortlist">
                            <tr>
                                <td class="ref-wit">
                                    <xsl:value-of select="@xml:id"/>
                                </td>
                                <td>
                                    <input name="{@xml:id}" type="text" maxlength="3" size="3">
                                        <xsl:attribute name="id">
                                            <xsl:text>sel</xsl:text>
                                            <xsl:value-of select="@xml:id"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="value" select="''"/>
                                    </input>
                                    
                                </td>
                                <td class="ref-data">
                                    <xsl:value-of select="text()"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                        <tr/>
                        <tr>
                            <td dir="ltr">
                                <input type="submit" value="Collate"/>
                            </td>
                        </tr>
                    
                </table></form>
                <div>
                    <p><mcite><xsl:copy-of select="$mcite"/></mcite>
                    <rqs><xsl:copy-of select="$rqs"/></rqs></p>
                </div>

            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
