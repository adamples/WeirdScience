<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:output
        method="xml"
        omit-xml-declaration="yes"
        doctype-public="XSLT-compat"
        encoding="UTF-8"
        media-type="text/html"
        indent="no"
      />


      <xsl:include href="common.xsl" />

      <xsl:template match="/image-metadata">
        <xsl:variable name="destination_name" select="destination-name"/>
        <html>
          <head>
            <meta charset="utf-8"/>
            <link rel="stylesheet" href="../../css/grid.css" type="text/css" media="all"/>
            <link rel="stylesheet" href="../../css/all.css" type="text/css" media="all"/>
            <link rel="stylesheet" href="../../css/screen.css" type="text/css" media="screen"/>
            <link rel="stylesheet" href="../../css/print.css" type="text/css" media="print"/>
            <link rel="stylesheet" href="../../css/image.css" type="text/css" media="screen"/>
            <title>
              <xsl:value-of select="$title"/>
              <xsl:text> — Weird Science</xsl:text>
            </title>
            <script src="../../js/jquery.js"> </script>
            <script src="../../js/images.js"> </script>
            <script src="../../js/main.js"> </script>
          </head>
          <body>
            <div id="google_translate_element"/>
            <h1>
              <xsl:text>Weird Science</xsl:text>
            </h1>
            <a>
              <xsl:attribute name="href">
                <xsl:text>../../</xsl:text>
                <xsl:value-of select="document('../../tmp/menu.html')//a[text()=$title]/@href"/>
                <xsl:text>#img-</xsl:text>
                <xsl:value-of select="substring-before(substring-after(destination-name, '/'), '.')"/>
              </xsl:attribute>

              <img src="{substring-after(destination-name, '/')}" alt='Ilustracja do artykułu "{$title}"' title="{$title}"/>
              <br/>

              <xsl:copy-of select="document(concat('../../', $temp_path, '/metadata.xml'))//image[image-metadata/destination-name=$destination_name]//description/*"/>

              <xsl:text>Kliknij, aby powrócić do artykułu </xsl:text>
              <i>
                <xsl:value-of select="$title"/>
              </i>
            </a>
          </body>
        </html>
        <script src="https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"> </script>
      </xsl:template>

  </xsl:stylesheet>
