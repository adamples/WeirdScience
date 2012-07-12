<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

			<xsl:output method="text" encoding="UTF-8"/>

			<xsl:template name="date-atom-to-pl">
				<xsl:param name="date" />
				<xsl:variable name="year" select="number(substring($date,1,4))" />
				<xsl:variable name="month" select="number(substring($date,6,2))" />
				<xsl:variable name="day" select="number(substring($date,9,2))" />
				<xsl:value-of select="$day" />
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$month=1"><xsl:text>stycznia</xsl:text></xsl:when>
					<xsl:when test="$month=2"><xsl:text>lutego</xsl:text></xsl:when>
					<xsl:when test="$month=3"><xsl:text>marca</xsl:text></xsl:when>
					<xsl:when test="$month=4"><xsl:text>kwietnia</xsl:text></xsl:when>
					<xsl:when test="$month=5"><xsl:text>maja</xsl:text></xsl:when>
					<xsl:when test="$month=6"><xsl:text>czerwca</xsl:text></xsl:when>
					<xsl:when test="$month=7"><xsl:text>lipca</xsl:text></xsl:when>
					<xsl:when test="$month=8"><xsl:text>sierpnia</xsl:text></xsl:when>
					<xsl:when test="$month=9"><xsl:text>września</xsl:text></xsl:when>
					<xsl:when test="$month=10"><xsl:text>października</xsl:text></xsl:when>
					<xsl:when test="$month=11"><xsl:text>listopada</xsl:text></xsl:when>
					<xsl:when test="$month=12"><xsl:text>grudnia</xsl:text></xsl:when>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$year" />
				<xsl:text> roku</xsl:text>
			</xsl:template>

			<xsl:template name="date-atom-to-year">
				<xsl:param name="date" />
				<xsl:value-of select="number(substring($date,1,4))" />
			</xsl:template>

	</xsl:stylesheet>