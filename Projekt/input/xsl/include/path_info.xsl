<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

			<xsl:output method="text" encoding="UTF-8"/>

			<xsl:template name="basename">
				<xsl:param name="path" />
				<xsl:choose>
					<xsl:when test="string-length(substring-before($path,'/'))=0">
						<xsl:value-of select="$path" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="basename">
							<xsl:with-param name="path" select="substring-after($path,'/')" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:template>

			<xsl:template name="filename-recursive">
				<xsl:param name="basename" />
				<xsl:if test="string-length(substring-before($basename,'.'))!=0">
					<xsl:value-of select="substring-before($basename,'.')" />
					<xsl:text>.</xsl:text>
					<xsl:call-template name="filename-recursive">
						<xsl:with-param name="basename" select="substring-after($basename,'.')" />
					</xsl:call-template>
				</xsl:if>
			</xsl:template>

			<xsl:template name="filename">
				<xsl:param name="path" />
				<xsl:variable name="basename">
					<xsl:call-template name="basename">
						<xsl:with-param name="path" select="$path" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="result">
					<xsl:call-template name="filename-recursive">
						<xsl:with-param name="basename" select="$basename" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="substring($result,1,string-length($result)-1)" />
			</xsl:template>

	</xsl:stylesheet>