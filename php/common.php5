<?php

setlocale (LC_CTYPE, 'pl_PL.UTF-8');

define ("LOG_I", 0);
define ("LOG_IB", 1);
define ("LOG_IE", 2);
define ("LOG_W", 3);
define ("LOG_E", 4);

define ("TXT_RESET", "\033[0m");
define ("TXT_RED", "\033[0;1;4;31m");
define ("TXT_GREEN", "\033[0;32m");
define ("TXT_YELLOW", "\033[0;1;33m");
define ("TXT_GRAY", "\033[0m");


list ($B_MICRO, $B_SEC) = explode (" ", microtime ());


  function autoload ($class_name) {
      include $class_name . ".class.php5";
  }

  spl_autoload_register('autoload');


  function has_interface ($object, $interface) {
    $ref = new ReflectionClass ();
    $ref->clone ($object);
  }


  function log_write ($msg, $level = LOG_I) {
    global $B_MICRO;
    global $B_SEC;

      if ($level != LOG_IE) {
        list ($micro, $sec) = explode (" ", microtime ());

        echo TXT_RESET;

        printf ("[%011.6F] ", $sec - $B_SEC + $micro - $B_MICRO);

          switch ($level) {
            case LOG_IB :
            case LOG_I : echo TXT_GREEN . "II: "; break;
            case LOG_W : echo TXT_YELLOW . "WW: "; break;
            case LOG_E : echo TXT_RED . "EE: "; break;
          }

      }

      if ($level == LOG_IE)
        if ($msg == "sukces")
          echo TXT_GREEN;
        else
          echo TXT_RED;

    echo "$msg";

      if ($level == LOG_IB)
        echo "... ";
      else
        echo ".\n";

    echo TXT_RESET;
  }


  function strtolower_pl ($input) {
    return strtr (strtolower ($input), "ĄĆĘŁŃÓŚŻŹ", "ąćęłńóśżź");
  }


  function strtoascii ($input) {
    return iconv ("UTF-8", "ASCII//TRANSLIT", $input);
  }


  function strtocharset ($input, $charset) {
    $result = '';
      if (is_string ($input) && is_string ($charset)) {
          for ($i = 0, $c = strlen ($input); $i < $c; $i++)
            if (strpos ($charset, $input[$i]) !== false)
              $result .= $input[$i];
      }
    return $result;
  }


  function normalize_space ($input) {
      if (is_string ($input)) {
        $result = str_replace ("\xC2\xA0", " ", $input);
          while (($tmp = str_replace ("  ", " ", $result)) != $result) $result = $tmp;
        return trim ($result);
      }
  }


  function uri_escape ($input) {
    $result = $input;
    $result = str_replace (" ", "%20", $result);
    return $result;
  }


  function text_id ($input) {
    return normalize_space (strtocharset (strtoascii ($input), "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678- "));
  }


  function words_compare ($a, $b) {
    return levenshtein ($a, $b, 2, 2, 1)*1.75;
  }


  function ndec ($n, $one, $tofour, $rest) {
      if ($n == 1)
        return "1 $one";
      else
        if ($n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 > 20))
          return "$n $tofour";
        else
          return "$n $rest";
  }


  function image_output_path ($input_path) {
    $input_path = realpath ($input_path);

    $subdirs = 1;

    $name = md5_file($input_path);
    $mime = explode ("/", mime_content_type($input_path));
    $ext = $mime[1];

    $result = "";

    for ($i = 0; $i < $subdirs; ++$i)
      $result .= $name[$i] . "/";

    $result .= $name . "." . $ext;
    return $result;
  }
