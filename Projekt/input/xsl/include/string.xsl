<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <!-- trim! -->

    <xsl:template name="left-trim">
      <xsl:param name="s" />
      <xsl:choose>
       <xsl:when test="substring($s, 1, 1) = ''">
        <xsl:value-of select="$s"/>
       </xsl:when>
       <xsl:when test="normalize-space(substring($s, 1, 1)) = ''">
        <xsl:call-template name="left-trim">
          <xsl:with-param name="s" select="substring($s, 2)" />
        </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="$s" />
       </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="right-trim">
      <xsl:param name="s" />
      <xsl:choose>
       <xsl:when test="substring($s, 1, 1) = ''">
        <xsl:value-of select="$s"/>
       </xsl:when>
       <xsl:when test="normalize-space(substring($s, string-length($s))) = ''">
        <xsl:call-template name="right-trim">
          <xsl:with-param name="s" select="substring($s, 1, string-length($s) - 1)" />
        </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="$s" />
       </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="trim">
      <xsl:param name="s" />
      <xsl:call-template name="right-trim">
       <xsl:with-param name="s">
        <xsl:call-template name="left-trim">
          <xsl:with-param name="s" select="$s" />
        </xsl:call-template>
       </xsl:with-param>
      </xsl:call-template>
    </xsl:template>

    <!-- trim koniec -->

    <!-- replace -->

    <xsl:template name="replace">
      <xsl:param name="search"/>
      <xsl:param name="replace"/>
      <xsl:param name="subject"/>
      <xsl:choose>
        <xsl:when test="contains($subject,$search)">
          <xsl:variable name="before" select="substring-before($subject,$search)"/>
          <xsl:variable name="after">
            <xsl:call-template name="replace">
              <xsl:with-param name="search" select="$search"/>
              <xsl:with-param name="replace" select="$replace"/>
              <xsl:with-param name="subject" select="substring-after($subject,$search)"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat($before,$replace,$after)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$subject"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- replace koniec -->

    <xsl:template name="insert-nbsp">
      <xsl:param name="input"/>
      <xsl:variable name="tmp1" select="concat(' ',normalize-space($input),' ')"/>
      <xsl:variable name="tmp2">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="' a '"/>
          <xsl:with-param name="replace" select="' a '"/>
          <xsl:with-param name="subject" select="$tmp1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp3">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="' i '"/>
          <xsl:with-param name="replace" select="' i '"/>
          <xsl:with-param name="subject" select="$tmp2"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp4">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="' o '"/>
          <xsl:with-param name="replace" select="' o '"/>
          <xsl:with-param name="subject" select="$tmp3"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp5">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="' w '"/>
          <xsl:with-param name="replace" select="' w '"/>
          <xsl:with-param name="subject" select="$tmp4"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp6">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="' z '"/>
          <xsl:with-param name="replace" select="' z '"/>
          <xsl:with-param name="subject" select="$tmp5"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="normalize-space($tmp6)"/>
    </xsl:template>

    <xsl:template name="replace-special-sequences">
      <xsl:param name="input"/>
      <xsl:variable name="tmp1">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'*'"/>
          <xsl:with-param name="replace" select="'×'"/>
          <xsl:with-param name="subject" select="$input"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp2">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'--'"/>
          <xsl:with-param name="replace" select="'–'"/>
          <xsl:with-param name="subject" select="$tmp1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp3">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="',,'"/>
          <xsl:with-param name="replace" select="'„'"/>
          <xsl:with-param name="subject" select="$tmp2"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp4">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="&#34;''&#34;"/>
          <xsl:with-param name="replace" select="'”'"/>
          <xsl:with-param name="subject" select="$tmp3"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp5">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'...'"/>
          <xsl:with-param name="replace" select="'…'"/>
          <xsl:with-param name="subject" select="$tmp4"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$tmp5"/>
    </xsl:template>

    <xsl:template name="replace-tex-special-characters">
      <xsl:param name="input"/>
      <xsl:variable name="tmp1">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'\'"/>
          <xsl:with-param name="replace" select="'\bslash '"/>
          <xsl:with-param name="subject" select="$input"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp2">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'$'"/>
          <xsl:with-param name="replace" select="'\$'"/>
          <xsl:with-param name="subject" select="$tmp1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp3">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'{'"/>
          <xsl:with-param name="replace" select="'\{'"/>
          <xsl:with-param name="subject" select="$tmp2"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp4">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'}'"/>
          <xsl:with-param name="replace" select="'\}'"/>
          <xsl:with-param name="subject" select="$tmp3"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp5">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'%'"/>
          <xsl:with-param name="replace" select="'\%'"/>
          <xsl:with-param name="subject" select="$tmp4"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp6">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'&amp;'"/>
          <xsl:with-param name="replace" select="'\&amp;'"/>
          <xsl:with-param name="subject" select="$tmp5"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp7">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'#'"/>
          <xsl:with-param name="replace" select="'\#'"/>
          <xsl:with-param name="subject" select="$tmp6"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp8">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'~'"/>
          <xsl:with-param name="replace" select="'{\raise.17ex\hbox{$\scriptstyle\mathtt{\sim}$}}'"/>
          <xsl:with-param name="subject" select="$tmp7"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp9">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'/'"/>
          <xsl:with-param name="replace" select="'\slash '"/>
          <xsl:with-param name="subject" select="$tmp8"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp10">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'&gt;'"/>
          <xsl:with-param name="replace" select="'$&gt;$'"/>
          <xsl:with-param name="subject" select="$tmp9"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp11">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'&lt;'"/>
          <xsl:with-param name="replace" select="'$&lt;$'"/>
          <xsl:with-param name="subject" select="$tmp10"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp12">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'_'"/>
          <xsl:with-param name="replace" select="'\_'"/>
          <xsl:with-param name="subject" select="$tmp11"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="tmp13">
        <xsl:call-template name="replace">
          <xsl:with-param name="search" select="'|'"/>
          <xsl:with-param name="replace" select="'\vbar '"/>
          <xsl:with-param name="subject" select="$tmp12"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$tmp13"/>
    </xsl:template>

    <!-- replace koniec -->

    <!-- href-escape -->

    <xsl:template name="href-escape">
      <xsl:param name="url"/>
      <xsl:call-template name="replace">
        <xsl:with-param name="search" select="' '"/>
        <xsl:with-param name="replace" select="'%20'"/>
        <xsl:with-param name="subject" select="$url"/>
      </xsl:call-template>
    </xsl:template>

    <!-- url-escape -->

  </xsl:stylesheet>