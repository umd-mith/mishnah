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
    <!-- Assembles the parts of the "compare" module of the demo -->

    <xsl:template match="/" xmlns="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tempDiv">

        <div class="about" stye="clear:both" style="width:60%;direction:ltr"
            xmlns="http://www.w3.org/1999/xhtml" title="Digital Mishnah Project: Compare Witnesses">
            <h2>Compare Witnesses <span class="tractate">
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
                <p>This page allows users to select passages to compare witnesses. As the texts in
                    the database expand functionalities will as well.</p>
                <p>Use the dropdown menu on the left to select passages. All passages where the
                    database currently have text have active links. Bava Metsia (fourth order,
                    second tractate), Chapter 2 has the most encoded witnesses, and is the best
                    locus for exploring the functions of the site.</p>
                <p>After selecting witnesses, the selection list in the middle area will refresh
                    with only those witnesses that have text for the selected passage, and the input
                    fields and buttons will be active. Select a witness by entering a <hi
                        style="font-weight:bold; text-style:italic;">numeral</hi> in the input
                    field. This allows the user to choose the order that the witnesses are presented
                    in output.</p>
                <p>Use the buttons in the righthand area to specify whether comparison is done by
                    chapter ("div3" in TEI speak) or mishnah ("ab") and the type of output
                    requested.</p>
                <p>Output types are as follows: <ul><li><hi
                                style="font-weight:bold; text-style:italic;">Alignment table</hi>,
                            in which each each witness is presented horizontally, and each token
                            (word) is aligned with its corresponding element in the other witnesses.
                            Alignment is done using <a href="http://www.collatex.net/"
                            >CollateX</a>.</li>
                        <li><hi style="font-weight:bold; text-style:italic;">Text with
                                Apparatus</hi>. The witness selected with the lowest selection
                            number (typically 1) is the default base text. The apparatus coordinates
                            the alignment output from CollateX to the base text.</li>
                        <li><hi style="font-weight:bold; text-style:italic;">Parallel-Column
                                Synopsis</hi>. Using the order from the selection list, this section
                            of the output page presents the selected text in parallel
                        columns.</li></ul></p>
                <p>This is a demo. There is <hi style="font-weight:bold; text-style:italic;">no
                        error-checking</hi> on user input, for instance. And much work remains to be
                    done, especially on processing fragmentary texts. Feedback is requested.</p>
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
            </div>

        </div>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'dropdown']"/>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'selectionList']"/>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'output-container']"/>
    </xsl:template>
</xsl:stylesheet>
