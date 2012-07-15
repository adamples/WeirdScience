<?php

$months = explode(" ", "stycznia lutego marca kwietnia maja czerwca lipca sierpnia września października listopada grudnia");
date_default_timezone_set("Europe/Warsaw");

include "php/common.php5";

  class MyProject extends Project {
    protected   $articles;
    protected   $images;
    protected   $hierarchy;


    public function __construct () {
      parent::__construct ("Projekt/");

      $this->articles = array ();
      $this->images = array ();

      $this->make->registerMethod (new MakeThumb (270, 200, 60, true), "thumb");
      $this->make->registerMethod (new MakeThumb (270, 200, 60, true, 1.1), "large-thumb");
      $this->make->registerMethod (new MakeCoolThumb (), "cool-thumb");
      $this->make->registerMethod (new MakeThumb (800, 600, 95, false), "normal");
      $this->make->registerMethod (new MakeImageMetadata, "image-metadata");
      $this->make->registerMethod (new MakeStrReplace (array ("&"), array ("&amp;")), "preprocessing");
      $this->make->registerMethod (new MakeExternal ("composite -gravity SouthWest \$2 \$1 \$o"), "watermark");
      $this->make->registerMethod (new MakeStrReplace (
        array (
          " PUBLIC \"XSLT-compat\" \"\"",
          " </script>",
          "/>",
        ), array (
          "",
          "</script>",
          ">"
        )
      ), "html5compat");
    }


    protected function article_temp_path ($title) {
      $result = strtoascii($title);
      $result = strtolower($result);
      $result = strtocharset($result, "abcdefghijklmnopqrstuvwxyz");
      $result = "tmp/$result";
      return $result;
    }


    protected function article_title_escape ($s) {
      $result = "";
        for ($i = 0, $c = strlen ($s); $i < $c; $i++)
          if (strstr ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', $s {$i}))
            $result .= $s {$i};
      return $result;
    }


    protected function scan ($path) {
      $name = basename ($path);

      if ($name {0} == "~")
        return NULL;

      /* Artykuł */
      if (is_file ("$path/index.html")) {
        $title = $name;

        $mtime = filemtime("$path/index.html");
        $mtime = strtotime(date("Y-m-d"), $mtime);
        $new = "false";

        if ($name{0} == "!") {
          $title = substr($name, 1);
          $new = "true";
        }

        $article = array (
          "type" => "article",
          "name" => $name,
          "title" => $title,
          "path" => realpath ($path),
          "mtime" => $mtime,
          "new" => $new,
          "temp_path" => $this->article_temp_path ($name),
          "escaped_title" => $this->article_title_escape ($name),
          "images" => array ()
        );

          foreach (glob ("$path/*") as $found)
            if (is_file ($found)) {
              $mime = mime_content_type ($found);
              list ($type, $subtype) = explode ("/", $mime);
                if ($type == "image") {
                  $article["images"] []= basename ($found);
                  $this->images []= $found;
                }
            }

        $this->articles []= $article;
        return $article;
      }
      /* Kategoria */
      else {

        $result = array (
          "type" => "category",
          "name" => $name,
          "subcategories" => array (),
          "articles" => array ()
        );

        foreach (glob ("$path/*") as $found) {
          $r = $this->scan($found);

          if (!$r) continue;

          if ($r["type"] == "article")
            $result ["articles"] []= $r;
          else
            $result ["subcategories"] []= $r;
        }

        return $result;
      }
    }


    protected function build_index ($element) {
      global $months;

      $keys = array_keys ($element);
      if (!$element)
        return "";

      if (is_numeric ($keys[0])) {

        $result = "";

        for ($i = 0, $c = count ($element); $i < $c; ++$i)
          $result .= $this->build_index($element[$i]);

        return $result;

      } elseif ($element["type"] == "article") {

        $date = date("j", $element["mtime"]) . " " . $months[intval(date("n", $element["mtime"])) - 1] . " " . date("Y", $element["mtime"]);

        return
          "<article>" .
          "<title>" . $element["title"] . "</title>" .
          "<path>" . $element["path"] . "</path>" .
          "<timestamp>" . $element["mtime"] . "</timestamp>" .
          "<date>" . $date . "</date>" .
          "<new>" . $element["new"] . "</new>" .
          "<temp-path>" . $element["temp_path"] . "</temp-path>" .
          "<escaped-title>" . $element["escaped_title"] . "</escaped-title>" .
          "</article>";

      } else {

        return
          "<category>" .
          "<name>" . $element["name"] . "</name>" .
          "<articles>" . $this->build_index ($element["articles"]) . "</articles>" .
          "<subcategories>" . $this->build_index ($element["subcategories"]) . "</subcategories>" .
          "</category>";

      }
    }


    protected function create_index () {
      $doc = DOMDocument::loadXML("<index><year>" . date("Y") . "</year>" . $this->build_index($this->hierarchy) . "</index>");
      $doc->encoding = "UTF-8";
      $doc->formatOutput = true;
      $doc->save ("index.xml");
    }


    protected function add_dir ($in_dir, $out_dir, $method = "cat") {
      foreach (glob ("$in_dir/*") as $path)
        if (is_file ($path) && $path{0} != ".") {
          $this->make->addRule (array ($path), $out_dir . "/" . basename ($path), $method);
        } elseif (is_dir ($path) && $path{0} != ".") {
          $this->add_dir ($path, $out_dir . "/" . basename ($path), $method);
        }
    }


    protected function add_rules_stage_1 () {

      $this->add_dir ("input/css", "output/css");
      $this->add_dir ("input/js", "output/js");
      $this->add_dir ("input/player", "output/player");

      $this->make->addRule (array ("index.xml", "input/xsl/index.php.xsl"), "output/index.php", "xsl");
      $this->make->addRule (array ("index.xml", "input/xsl/menu.xsl", "tmp/metadata.xml"), "tmp/menu.html", "xsl");
      $this->make->addRule (array ("output/Strona główna.html"), "output/index.html", "cat");

      $this->make->addRule (array ("tmp/metadata.xml", "input/xsl/images.js.xsl"), "output/js/images.js", "xsl");


      $global_metadata_deps = array ("index.xml", "input/xsl/global-metadata.xsl");

      foreach ($this->articles as $article) {

        $title = $article["title"];
        $path = $article["path"];
        $tmp = $article["temp_path"];

        $global_metadata_deps [] = "$tmp/metadata.xml";

        $this->make->addRule (array ("$path/index.html"), "$tmp/1.html", "preprocessing");
        $this->make->addRule (array ("$tmp/1.html"), "$tmp/2.html", "hyphenation");

        $images_metadata = array ();

        foreach ($article["images"] as $image) {
          $this->make->addRule (array ("$path/" . $image), "$tmp/" . $image . ".xml", "image-metadata");
          $images_metadata []= "$tmp/" . $image . ".xml";
        }

        $metadata_deps = array_merge (array ("$tmp/1.html", "input/xsl/metadata.xsl", "index.xml"), $images_metadata);
        $this->make->addRule ($metadata_deps, "$tmp/metadata.xml", "xsl", array ("title" => $title, "original_path" => $path, "temp_path" => $tmp));

        $this->make->addRule (
          array_merge (
            array (
              "$tmp/2.html",
              "input/xsl/article.xsl",
              "tmp/menu.html"
            ),
            $images_metadata
          ),
          "$tmp/3.html",
          "xsl",
          array ("title" => $title, "temp_path" => $tmp)
        );

        $this->make->addRule (array ("$tmp/3.html"), "output/$title.html", "html5compat");

      }

      $this->make->addRule ($global_metadata_deps, "tmp/metadata.xml", "xsl");

    }


    protected function add_rules_stage_2 () {
      $doc = DOMDocument::load ("tmp/metadata.xml");

      $xpath = new DOMXPath ($doc);

      foreach ($xpath->query("//image[type='thumb']") as $metadata) {
        $signature = $xpath->query (".//signature", $metadata)->item (0)->nodeValue == 'true';
        $image = $xpath->query (".//original-path", $metadata)->item (0)->nodeValue;
        $opath = $xpath->query (".//destination-name", $metadata)->item (0)->nodeValue;
        $tmp = $xpath->query ("../../temp-path", $metadata)->item (0)->nodeValue;
        $title = $xpath->query ("../../title", $metadata)->item (0)->nodeValue;

        if ($signature) {
          $this->make->addRule (array ($image), "tmp/images/$opath", "normal");
          $this->make->addRule (array ("tmp/images/$opath", "input/images/watermark.png"), "output/images/$opath", "watermark");
        } else {
          $this->make->addRule (array ($image), "output/images/$opath", "normal");
        }

        $this->make->addRule (array ($image), "output/thumbs/$opath", "thumb");
        $this->make->addRule (array ($image), "output/large-thumbs/$opath", "large-thumb");

        $this->make->addRule (
          array ("$tmp/" . basename ($image) . ".xml", "input/xsl/image.xsl"), "tmp/images/$opath.html",
          "xsl", array ("title" => $title, "temp_path" => $tmp)
        );
        $this->make->addRule (array ("tmp/images/$opath.html"), "output/images/$opath.html", "html5compat");
      }

      foreach ($xpath->query("//image[type='inline']/image-metadata/original-path") as $node) {
        $image = $node->nodeValue;

        $this->make->addRule (array ($image), "output/images/" . image_output_path ($image), "cat");
      }

      foreach ($xpath->query("//download") as $node) {
        $from = $xpath->query (".//original-path", $node)->item (0)->nodeValue;
        $to = $xpath->query (".//filename", $node)->item (0)->nodeValue;

        $this->make->addRule(array ($from), "output/downloads/$to", "cat");
      }

    }


    protected function pre_build () {
      parent::pre_build ();

      log_write ("scanning content directory");
      $this->hierarchy = $this->scan("input/content");

      log_write ("creating index");
      $this->create_index ();
    }


    public function build () {

      list ($bmicro, $bsec) = explode (" ", microtime ());
      log_write ("Project->build (): Wchodzę do \"" . $this->base_dir . "\"");
      chdir ($this->base_dir);

      $this->pre_build ();

      log_write ("preparing stage 1");
      $this->add_rules_stage_1 ();
      log_write ("running stage 1");
      $this->make->runAll ();

      log_write ("preparing stage 2");
      $this->add_rules_stage_2 ();
      log_write ("running stage 2");
      $this->make->runAll ();

      $this->post_build ();

      log_write ("Project->build (): Sprzątanie");
      $this->make->cleanDir ("output");
      $this->make->cleanDir ("tmp");
      $this->make->printSummary ();
      list ($emicro, $esec) = explode (" ", microtime ());
      log_write ("Project->build (): Koniec");

    }

  }

  $project = new MyProject ();
  $project->build ();
