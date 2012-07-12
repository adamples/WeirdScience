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
        <html>
          <head>
            <meta charset="utf-8"/>
            <link rel="stylesheet" href="../../css/image.css" type="text/css" media="screen"/>
            <title>
              <xsl:value-of select="$title"/>
              <xsl:text> — Weird Science</xsl:text>
            </title>
          </head>
          <body>
            <h1>
              <xsl:text>Weird Science</xsl:text>
            </h1>
            <a>
              <xsl:attribute name="href">
                <xsl:text>../../</xsl:text>
                <xsl:value-of select="document('../../tmp/menu.html')//a[text()=$title]/@href"/>
              </xsl:attribute>

              <img src="{substring-after(destination-name, '/')}" alt='Ilustracja do artykułu "{$title}"' title="{$title}"/>
              <br/>
              <xsl:text>Kliknij, aby powrócić do artykułu </xsl:text>
              <i>
                <xsl:value-of select="$title"/>
              </i>
            </a>
          </body>
        </html>
      </xsl:template>

  </xsl:stylesheet>