<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:output
        method="xml"
        encoding="UTF-8"
        indent="yes"
      />


      <xsl:template match="/index">
        <global-metadata>
          <xsl:apply-templates select="//article"/>
        </global-metadata>
      </xsl:template>


      <xsl:template match="article" >
        <xsl:copy-of select="document(concat('../../', temp-path, '/metadata.xml'))/article-metadata"/>
      </xsl:template>


  </xsl:stylesheet>