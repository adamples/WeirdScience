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

      <xsl:template match="/article">
        <html>
          <head>
            <meta charset="utf-8"/>
            <link rel="stylesheet" href="css/grid.css" type="text/css" media="all"/>
            <link rel="stylesheet" href="css/all.css" type="text/css" media="all"/>
            <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen"/>
            <link rel="stylesheet" href="css/print.css" type="text/css" media="print"/>
            <script src="js/jquery.js"> </script>
            <script src="js/images.js"> </script>
            <script src="js/main.js"> </script>
            <title>
              <xsl:value-of select="$title"/>
              <xsl:text> — Weird Science</xsl:text>
            </title>
          </head>
          <body>
            <h1>
              <xsl:text>Weird Science</xsl:text>
            </h1>
            <xsl:copy-of select="document('../../tmp/menu.html')"/>
            <div id="content">
              <h2>
                <xsl:value-of select="$title"/>
              </h2>
              <xsl:apply-templates select="*"/>
              <p class="signature">
                <xsl:text>Marek Ples</xsl:text>
                <!--
                <xsl:text>,   </xsl:text>
                <xsl:value-of select="document(concat('../../', $temp_path, '/metadata.xml'))//date"/>
                -->
              </p>
            </div>
            <div id="footer">
              <p>
                <xsl:text>copyright © 2011 — </xsl:text>
                <xsl:value-of select="document('../../index.xml')//year"/>
                <xsl:text> Marek Ples </xsl:text>
                <span class="gmail-email">
                  <xsl:text>moze.dzis</xsl:text>
                </span>
                <xsl:text> · design © 2011 — </xsl:text>
                <xsl:value-of select="document('../../index.xml')//year"/>
                <xsl:text> Adam Ples </xsl:text>
                <span class="gmail-email">
                  <xsl:text>ples.adam</xsl:text>
                </span>
              </p>
            </div>
          </body>
        </html>
      </xsl:template>


      <xsl:template match="img[@class='inline']" >
        <img alt="Ilustracja">
          <xsl:attribute name="src">
            <xsl:apply-templates select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata" mode="src-full"/>
          </xsl:attribute>
        </img>
      </xsl:template>


      <xsl:key name="img-key" match="img[not(@class) or @class!='inline']" use="generate-id(preceding::*[name()!='img' or @class='inline'][1])"/>

      <xsl:template match="img[not(@class) or @class!='inline']">
        <xsl:variable name="prev" select="preceding::*[1]"/>
        <xsl:variable name="key" select="generate-id(preceding::*[name()!='img' or @class='inline'][1])"/>

        <xsl:choose>
          <xsl:when test="name($prev)!='img' or $prev/@class='inline'">
            <div class="illustrations">
              <a>
                <xsl:attribute name="href">
                  <xsl:apply-templates select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata" mode="src-full"/>
                  <xsl:text>.html</xsl:text>
                </xsl:attribute>
                <img alt="Ilustracja: {@title}" title="{@title}">
                  <xsl:if test="position() mod 2=1">
                    <xsl:attribute name="class">even</xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="src">
                    <xsl:apply-templates select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata" mode="src-thumb"/>
                  </xsl:attribute>
                </img>
                <p class="description">
                  <xsl:if test="@title">
                    <xsl:value-of select="@title"/>
                  </xsl:if>
                  <xsl:if test="not(@title)">
                    <xsl:text>Kliknij, aby powiększyć</xsl:text>
                  </xsl:if>
                </p>
              </a>
              <xsl:apply-templates select="key('img-key', $key)[position()!=1]" mode="not-first"/>
            </div>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:template>

      <xsl:template match="img[not(@class) or @class!='inline']" mode="not-first">
        <a>
          <xsl:attribute name="href">
            <xsl:apply-templates select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata" mode="src-full"/>
            <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <xsl:if test="position() mod 2=1">
            <xsl:attribute name="class">even</xsl:attribute>
          </xsl:if>
          <img alt="Ilustracja: {@title}" title="{@title}">
            <xsl:attribute name="src">
              <xsl:apply-templates select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata" mode="src-thumb"/>
            </xsl:attribute>
          </img>
          <p class="description">
            <xsl:if test="@title">
              <xsl:value-of select="@title"/>
            </xsl:if>
            <xsl:if test="not(@title)">
              <xsl:text>Kliknij aby powiększyć</xsl:text>
            </xsl:if>
          </p>
        </a>
      </xsl:template>


      <xsl:template match="image-metadata" mode="src-full">
        <xsl:value-of select="concat('images/', destination-name)"/>
      </xsl:template>

      <xsl:template match="image-metadata" mode="src-thumb">
        <xsl:value-of select="concat('thumbs/', destination-name)"/>
      </xsl:template>


      <xsl:template match="alert">
        <p class="alert">
          <xsl:apply-templates select="*|text()"/>
        </p>
      </xsl:template>

      <xsl:template match="object">
        <object data="{embed/@src}" type="{embed/@type}">
          <xsl:apply-templates select="@*|*"/>
        </object>
      </xsl:template>

      <xsl:template match="*">
        <xsl:element name="{translate(name(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')}">
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="*|text()"/>
        </xsl:element>
      </xsl:template>

      <xsl:template match="@*">
        <xsl:attribute name="{translate(name(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:template>

      <xsl:template match="object/@width|embed/@width">
        <xsl:attribute name="width">
          <xsl:text>560</xsl:text>
        </xsl:attribute>
      </xsl:template>

      <xsl:template match="object/@height|embed/@height">
        <xsl:attribute name="height">
          <xsl:text>340</xsl:text>
        </xsl:attribute>
      </xsl:template>

      <xsl:template match="h3|H3">
        <xsl:variable name="s" select="normalize-space(text())"/>
        <xsl:if test="$s=''">
          <xsl:message>
            <xsl:text>error: empty header</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:if test="$s!=''">
          <h3>
            <xsl:apply-templates select="text()"/>
          </h3>
        </xsl:if>
      </xsl:template>

      <xsl:template match="h5|H5">
        <h4>
          <xsl:apply-templates select="text()"/>
        </h4>
      </xsl:template>

      <xsl:template match="a[substring(@href, 1, 7)!='http://' and substring-before(@href, '.html')='']">
        <a href="downloads/{@href}">
          <xsl:apply-templates select="text()"/>
        </a>
      </xsl:template>

  </xsl:stylesheet>
