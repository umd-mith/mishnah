<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:my="local-functions.uri"
    version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:output method="html" indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:strip-space elements="*"/>


    <xsl:param name="rqs"
        select="'mcite=4.2.2.3&amp;unit=m&amp;tractName=Bava_Metsia&amp;Kauf=1&amp;ParmA=2&amp;Camb=3&amp;S00651=&amp;S08174=6&amp;P00001=&amp;Vilna=4&amp;Mun=&amp;Hamb=&amp;Vat114=5&amp;Vat115=&amp;Vat117=&amp;Leid=&amp;S03524=&amp;S04533=&amp;S04589=&amp;S04624=&amp;S01715=&amp;S05134=&amp;S04944=&amp;S04636=&amp;alignType=align'"/>
    <xsl:param name="alignType" select="'align'"/>
    <xsl:param name="algorithm" select="'dekker'"/>
    <xsl:param name="mcite" select="'4.2.2.3'"/>
    <xsl:param name="unit" select="'m'"/>
    <xsl:param name="tractName" select="'Bava_Metsia'"/>

    <!-- requires some finagling to extract the named parameters from $rqs, which is the complete parameter string -->
    <!-- Should have been able to use a recursive template to successively remove strings,
        but tests kept failing. Given the small number of these I am settling for this method -->
    <xsl:variable name="urlString">
        <xsl:variable name="string" select="concat($rqs,'&amp;')"/>
        <xsl:variable name="my:remove" xmlns="local-function.uri">
            <my:param>
                <xsl:value-of select="concat('mcite=',$mcite,'&amp;')"/>
            </my:param>
            <my:param>
                <xsl:value-of select="concat('unit=',$unit,'&amp;')"/>
            </my:param>
            <my:param>
                <xsl:value-of select="concat('alignType=',$alignType,'&amp;')"/>
            </my:param>
            <my:param>
                <xsl:value-of select="concat('tractName=',$tractName,'&amp;')"/>
            </my:param>
            <!--<my:param>
                <xsl:value-of select="concat('algorithm=',$algorithm,'&amp;')"/>
            </my:param>-->
        </xsl:variable>
        <xsl:variable name="tempStr1"
            select="concat(substring-before($string,$my:remove/my:param[1]),substring-after($string,$my:remove/my:param[1]))"/>
        <xsl:variable name="tempStr2"
            select="concat(substring-before($tempStr1,$my:remove/my:param[2]),substring-after($tempStr1,$my:remove/my:param[2]))"/>
        <xsl:variable name="tempStr3"
            select="concat(substring-before($tempStr2,$my:remove/my:param[3]),substring-after($tempStr2,$my:remove/my:param[3]))"/>
        <xsl:variable name="tempStr4"
            select="concat(substring-before($tempStr3,$my:remove/my:param[4]),substring-after($tempStr3,$my:remove/my:param[4]))"/>
        <!--<xsl:variable name="tempStr5"
            select="concat(substring-before($tempStr4,$my:remove/my:param[5]),substring-after($tempStr4,$my:remove/my:param[5]))"/>-->
        <!-- truncate last &amp; -->
        <xsl:value-of select="substring($tempStr4,1,string-length($tempStr4) - 1)"/>
    </xsl:variable>

    <xsl:variable name="ref.cit" select="concat('ref.',$mcite)"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="@*|node()">

        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="my:chapter">
        <xsl:if test=" $unit = 'ch' and @xml:id=$ref.cit">
                <xsl:for-each select="my:mishnah">
                <!-- Only way I could get cinclude with parameters to work was with a full URL -->
                <!-- For local testing replace http://dev.digitalmishnah.org/viewer/text with http://localhost:8888/text -->            
                <cinclude:include>
                    <!--<xsl:attribute name="src"
                        select="concat('http&#58;&#47;&#47;dev.digitalmishnah.umd.edu&#47;merge','?mcite=',substring-after(@xml:id,'ref.'),'&#38;',$urlString)"/>
                    <xsl:attribute name="element" select="'test'"/>-->
                    <xsl:attribute name="src"
                        select="concat('http&#58;&#47;&#47;localhost&#58;8888&#47;text&#47;merge','?mcite=',substring-after(@xml:id,'ref.'),'&#38;',$urlString)"/>
                    <xsl:attribute name="element" select="'test'"/>
                </cinclude:include>
                
            </xsl:for-each>
            
        </xsl:if><xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="my:mishnah">
        <xsl:if test="$unit = 'm' and @xml:id = $ref.cit"> 
            <cinclude:include>
                <!-- Only way I could get cinclude with parameters to work was with a full URL -->
                <!-- For local testing replace http://dev.digitalmishnah.org/viewer/text with http://localhost:8888/text -->
                <!--<xsl:attribute name="src"
                select="concat('http&#58;&#47;&#47;dev.digitalmishnah.umd.edu&#47;merge','?mcite=',$mcite,'&#38;',$urlString)"/>
                <xsl:attribute name="element" select="'test'"/>-->
                <xsl:attribute name="src"
                    select="concat('http&#58;&#47;&#47;localhost&#58;8888&#47;text&#47;merge','?mcite=',$mcite,'&#38;',$urlString)"/>
            <xsl:attribute name="element" select="'test'"/>
            </cinclude:include>
        </xsl:if>
    </xsl:template>

    <xsl:template match="my:order|my:tract">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="my:struct">
        <struct xmlns="http://www.tei-c.org/ns/1.0">
            <rqs>
                <xsl:value-of select="$urlString"/>
            </rqs>
            <alignType>
                <xsl:value-of select="$alignType"/>
            </alignType>
            <unit>
                <xsl:value-of select="$unit"/>
            </unit>
            <mcite>
                <xsl:value-of select="$mcite"/>
            </mcite>
            <tractName>
                <xsl:value-of select="$tractName"/>
            </tractName>
            
            <xsl:apply-templates select="*"/>
        </struct>
    </xsl:template>


</xsl:stylesheet>
