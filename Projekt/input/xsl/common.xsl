<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:import href="include/path_info.xsl" />
      <xsl:import href="include/string.xsl" />
      <xsl:import href="include/date.xsl" />

  <!-- Elementy wewnątrz tekstu -->

      <xsl:template match="text()" priority="-10">
        <xsl:variable name="begin">
          <xsl:if test="position()!=1 and normalize-space(substring(.,1,1))!=substring(.,1,1)">
            <xsl:if test="position()!=last() or string-length(normalize-space(.))!=0">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="end">
          <xsl:if test="string-length(normalize-space(concat($begin,.)))!=0 and position()!=last() and normalize-space(substring(.,string-length(.)))!=substring(.,string-length(.))">
            <xsl:if test="position()!=1 or string-length(normalize-space(.))!=0">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="tmp1">
          <xsl:call-template name="insert-nbsp">
            <xsl:with-param name="input" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="tmp2">
          <xsl:call-template name="replace-special-sequences">
            <xsl:with-param name="input" select="$tmp1"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$begin" />
        <xsl:value-of select="$tmp2" />
        <xsl:value-of select="$end" />
      </xsl:template>

      <xsl:template match="br">
        <br/>
      </xsl:template>

  <!-- Elementy wewnątrz tekstu koniec -->

  <!-- Wspólne -->

      <xsl:template match="*" priority="-10">
        <b style="color:red">
          <xsl:text>&lt;</xsl:text>
          <xsl:value-of select="name()" />
          <xsl:apply-templates select="@*" />
          <xsl:text>&gt;</xsl:text>
          <xsl:apply-templates select="text()" />
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()" />
          <xsl:text>&gt;</xsl:text>
        </b>
      </xsl:template>

      <xsl:template match="@*" priority="-10">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()" />
        <xsl:text>="</xsl:text>
        <xsl:value-of select="." />
        <xsl:text>"</xsl:text>
      </xsl:template>

  <!-- Wspólne koniec -->

  </xsl:stylesheet>