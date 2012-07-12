<?php

$GLOBALS["language"] = "pl";
$GLOBALS["hyphen"] = "\xC2\xAD";
$GLOBALS["dictionary"] = "php/patterns/dictionary.txt";
$GLOBALS["leftmin"] = 3;
$GLOBALS["rightmin"] = 3;
$GLOBALS["charmin"] = 1;
$GLOBALS["charmax"] = 100;
$GLOBALS["path_to_patterns"] = "php/patterns/";

include "hyphenation.php";


  class MakeHyphenation implements MakeMethod {

      public function __construct () {
      }


      public function run ($input, $output, $make, $params = null) {
        if (count ($input) == 1 && is_a ($make, "Make")) {
          $dom = new DOMDocument ("1.0", "UTF-8");
          $code = str_replace (array ("&lt;", "&gt;", "&amp;"), array ("%1%", "%2%", "%3%"), file_get_contents ($input [0]));
          $code = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>$code";
          $dom->loadXML ($code);
          $xpath = new DOMXPath ($dom);
            foreach ($xpath->query ("//*[name()!='code']/*[name()!='pre' and name()!='code']/text()") as $text)
              $text->nodeValue = hyphenation ($text->nodeValue);
          $code = $dom->saveXML ();
          $code = str_replace (array ("%1%", "%2%", "%3%"), array ("&lt;", "&gt;", "&amp;"), $code);
          file_put_contents ($output, $code);
          return true;
        } else
          return false;
      }

  }