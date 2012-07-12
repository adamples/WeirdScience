<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:output
        method="text"
        encoding="UTF-8"
        indent="no"
      />

      <xsl:include href="include/string.xsl"/>

      <xsl:variable name="quote">"</xsl:variable>
      <xsl:variable name="escaped-quote">\"</xsl:variable>

      <xsl:template match="/global-metadata">
        <xsl:text>var images = new Array (</xsl:text>
        <xsl:apply-templates select="//article-metadata[count(images/image[type='thumb'])!=0]"/>
        <xsl:text>);</xsl:text>
      </xsl:template>

      <xsl:template match="article-metadata">
        <xsl:text>{title:"</xsl:text>
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="$quote"/>
          <xsl:with-param name="replace" select="$escaped-quote"/>
          <xsl:with-param name="subject" select="title"/>
        </xsl:call-template>
        <xsl:text>",images:Array(</xsl:text>
        <xsl:apply-templates select="images/image[type='thumb']"/>
        <xsl:text>)}</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:template>

      <xsl:template match="image" >
        <xsl:text>"</xsl:text>
        <xsl:value-of select="image-metadata/destination-name"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:template>


  </xsl:stylesheet>
