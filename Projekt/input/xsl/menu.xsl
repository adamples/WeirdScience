<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    version="2.0"
    exclude-result-prefixes="fn">

      <xsl:output
        method="xml"
        omit-xml-declaration="yes"
        doctype-public="XSLT-compat"
        encoding="UTF-8"
        media-type="text/html"
        indent="no"
      />


      <xsl:template match="/index">
        <div id="menu">
          <ul>
            <xsl:apply-templates select="category"/>
          </ul>
        </div>
      </xsl:template>


      <xsl:template match="category[name='content']">
        <xsl:if test="articles/*">
          <xsl:apply-templates select="articles/article"/>
        </xsl:if>
        <xsl:if test="subcategories/*">
          <xsl:apply-templates select="subcategories/category"/>
        </xsl:if>
      </xsl:template>


      <xsl:template match="category">
        <li>
          <xsl:attribute name="class">
            <xsl:text>category</xsl:text>
            <xsl:if test="name='Tajne'">
              <xsl:text> top-secret</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <xsl:value-of select="name"/>
          <xsl:if test="articles/* or subcategories/*">
            <ul>
              <xsl:apply-templates select="articles/article|subcategories/category">
                <xsl:sort select="order-key" data-type="text" order="ascending" collation="http://saxon.sf.net/collation?lang=pl_PL"/>
              </xsl:apply-templates>
            </ul>
          </xsl:if>
        </li>
      </xsl:template>


      <xsl:template match="article">
        <xsl:variable name="title" select="title"/>
        <xsl:variable name="new" select="document('../../tmp/metadata.xml')//article-metadata[title=$title]/new"/>
        <li>
          <xsl:if test="$new='true'">
            <xsl:attribute name="class">new-article</xsl:attribute>
          </xsl:if>
          <a href="{fn:encode-for-uri(title)}.html">
            <xsl:value-of select="title"/>
            <xsl:if test="$new='true'">
              <small>
                <xsl:text> (nowe!)</xsl:text>
              </small>
            </xsl:if>
          </a>
        </li>
      </xsl:template>

  </xsl:stylesheet>
