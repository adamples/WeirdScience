<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

      <xsl:output
        method="text"
        encoding="UTF-8"
        indent="no"
      />


      <xsl:template match="/index">
        <xsl:text>&lt;?php&#10;&#10;$titles = array(&#10;</xsl:text>
        <xsl:apply-templates select="//article"/>
        <xsl:text>);</xsl:text>
        <xsl:text><![CDATA[


  function escape ($s) {
    $result = "";
      for ($i = 0, $c = strlen ($s); $i < $c; $i++)
        if (strstr ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", $s {$i}))
          $result .= $s {$i};
    return $result;
  }


$keys = array_keys ($_GET);

if (count ($keys) == 1) {

  $escaped = escape ($keys[0]);

  if (isset ($titles [$escaped])) {
    $title = $titles [$escaped];

    header ("HTTP/1.1 301 Moved Permanently");
    header ("Location: $title.html");

    exit;
  }

}

header ("HTTP/1.1 301 Moved Permanently");
header ("Location: index.html");
]]></xsl:text>
      </xsl:template>


      <xsl:template match="article" >
        <xsl:text>  "</xsl:text>
        <xsl:value-of select="escaped-title"/>
        <xsl:text>" => "</xsl:text>
        <xsl:value-of select="title"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,&#10;</xsl:text>
        </xsl:if>
        <xsl:if test="position()=last()">
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
      </xsl:template>


  </xsl:stylesheet>