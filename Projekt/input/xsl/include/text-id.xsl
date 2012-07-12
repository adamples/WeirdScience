<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">


			<xsl:template name="text-id">
				<xsl:param name="input"/>
				<xsl:variable name="a">
					<xsl:value-of select="translate($input,'ąćęłńóśźżĄĆĘŁŃÓŚŹŻ','acelnoszzACELNOSZZ')"/>
				</xsl:variable>
				<xsl:variable name="b">
					<xsl:value-of select="translate($a,'—–.,:;&amp;@!`~*=+','')"/>
				</xsl:variable>
				<xsl:value-of select="normalize-space($b)"/>
			</xsl:template>


	</xsl:stylesheet>