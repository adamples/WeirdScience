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
          <!--<p>
            <xsl:text>Ogółem projektów: </xsl:text>
            <xsl:value-of select="count(//article)"/>
          </p>-->
        </div>
      </xsl:template>


      <xsl:template match="category[name='content']">
        <xsl:if test="articles/*">
          <xsl:apply-templates select="articles"/>
        </xsl:if>
        <xsl:if test="subcategories/*">
          <xsl:apply-templates select="subcategories"/>
        </xsl:if>
      </xsl:template>


      <xsl:template match="category">
        <li class="category">
          <xsl:value-of select="name"/>
          <xsl:if test="articles/* or subcategories/*">
            <ul>
              <xsl:if test="articles/*">
                <xsl:apply-templates select="articles"/>
              </xsl:if>
              <xsl:if test="subcategories/*">
                <xsl:apply-templates select="subcategories"/>
              </xsl:if>
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


      <xsl:template match="articles">
        <xsl:apply-templates select="article"/>
      </xsl:template>


      <xsl:template match="subcategories">
        <xsl:apply-templates select="category"/>
      </xsl:template>


  </xsl:stylesheet>
