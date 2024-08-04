<?php

  class MakeXSL implements MakeMethod {

      const SAXON_COMMAND = 'java -jar "' . __DIR__ . '/../3rd_party/SaxonHE12-5J/saxon-he-12.5.jar"';

      public function __construct () {
      }


      public function run ($input, $output, $make, $params = null) {
        if (is_a ($make, "Make")) {
          list ($xml, $stylesheet) = $input;

          $p = "";
          if (is_array ($params))
            foreach ($params as $name => $value) {
              if (is_string ($value))
                $p .= " --stringparam \"$name\" \"" . str_replace("\"", "\\\"", $value) . "\"";
              else
                $p .= " --param \"$name\" \"$value\"";
            }

          $tmp = file_get_contents ($stylesheet, FALSE, NULL, 50, 200);
          $exec_out = array ();
          $ret = 0;

          $output = str_replace("\"", "\\\"", $output);
          $stylesheet = str_replace("\"", "\\\"", $stylesheet);
          $xml = str_replace("\"", "\\\"", $xml);

            if (strpos ($tmp, "version=\"2.0\"") !== FALSE) {
              echo "(XSLT 2.0) ";
              exec (MakeXSL::SAXON_COMMAND . " -o:\"$output\" -xsl:\"$stylesheet\" -s:\"$xml\" 2> /dev/stdout", $exec_out, $ret);
            } else {
              //~ echo "\n\nxsltproc -o \"$output\" $p \"$stylesheet\" \"$xml\" 2> /dev/stdout\n\n";
              exec ("xsltproc -o \"$output\" $p \"$stylesheet\" \"$xml\" 2> /dev/stdout", $exec_out, $ret);
            }

          $exec_out = strtolower (implode("\n", $exec_out));
          echo $exec_out;

          return $ret == 0 && strpos ($exec_out, "warning") === false && strpos ($exec_out, "error") === false;
        } else
          return false;
      }

  }
