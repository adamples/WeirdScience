<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:output
        method="xml"
        encoding="UTF-8"
        indent="yes"
      />


      <xsl:template match="/article">
        <article-metadata>
          <title>
            <xsl:value-of select="$title"/>
          </title>
          <xsl:copy-of select="document('../../index.xml')//article[temp-path=$temp_path]/date"/>
          <xsl:copy-of select="document('../../index.xml')//article[temp-path=$temp_path]/timestamp"/>
          <xsl:copy-of select="document('../../index.xml')//article[temp-path=$temp_path]/new"/>
          <original-path>
            <xsl:value-of select="$original_path"/>
          </original-path>
          <temp-path>
            <xsl:value-of select="$temp_path"/>
          </temp-path>
          <images>
            <xsl:apply-templates select=".//img"/>
          </images>
          <downloads>
            <xsl:apply-templates select=".//a[substring(@href, 1, 7)!='http://' and substring-before(@href, '.html')='']"/>
          </downloads>
        </article-metadata>
      </xsl:template>


      <xsl:template match="img" >
        <image>
          <type>
            <xsl:choose>
              <xsl:when test="@class='inline'">
                <xsl:text>inline</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>thumb</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </type>
          <signature>
            <xsl:choose>
              <xsl:when test="@signature='no'">
                <xsl:text>false</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>true</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </signature>
          <xsl:copy-of select="document(concat('../../', $temp_path, '/', @src, '.xml'))/image-metadata"/>
          <description>
            <xsl:copy-of select="following-sibling::*[1][name()='center']"/>
          </description>
        </image>
      </xsl:template>

      <xsl:template match="a">
        <download>
          <original-path>
            <xsl:value-of select="$original_path"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@href"/>
          </original-path>
          <filename>
            <xsl:value-of select="@href"/>
          </filename>
        </download>
      </xsl:template>

  </xsl:stylesheet>
