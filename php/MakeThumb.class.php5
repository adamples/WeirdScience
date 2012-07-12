<?php

  class MakeThumb implements MakeMethod {
    private $width = 200;
    private $height = 200;
    private $quality = 50;
    private $crop = false;
    private $scale = 1.0;


      public function __construct ($width, $height, $quality, $crop = false, $scale = 1.0) {
        $this->width = $width;
        $this->height = $height;
        $this->quality = $quality;
        $this->crop = $crop;
        $this->scale = $scale;
      }


      public function run ($input, $output, $make, $params = null) {
        if (is_a ($make, "Make")) {
          $w = $this->width;
          $h = $this->height;
          $q = $this->quality;
          $scale = $this->scale;
          $ipath = $input [0];
          $opath = $output;
          //convert input.jpeg -filter Gaussian -resize 270x200^ -gravity Center -crop 270x200+0+0 output.jpeg

          if ($this->crop) {
            $img = new Imagick ($ipath);
            $img->cropThumbnailImage ($w * $scale, $h * $scale);
            $img->cropImage ($w, $h, 0.5 * $w * ($scale - 1), 0.5 * $h * ($scale - 1));
            $img->writeImage ($opath);

            //exec ("convert \"$ipath\" -quality $q -resize {$w}x$h^ -gravity Center -crop {$w}x$h+0+0 \"$opath\"");
          } else
            exec ("convert \"" . str_replace("\"", "\\\"", $ipath) . "\" -quality $q -resize {$w}x$h \"" . str_replace("\"", "\\\"", $opath) . "\"");

          return true;
        } else
          return false;
      }

  }
