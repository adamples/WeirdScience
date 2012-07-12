<?php

  class MakeCoolThumb implements MakeMethod {


      public function __construct () {
      }


      public function run ($input, $output, $make, $params = null) {
        if (is_a ($make, "Make")) {
          $full = new Imagick ($input[0]);
          $full->cropThumbnailImage (810, 600);
          $thumb = $full->clone ();
          $thumb->cropThumbnailImage (270, 200);

          $tw = $thumb->getImageWidth ();
          $th = $thumb->getImageHeight ();
          $fw = $full->getImageWidth ();
          $fh = $full->getImageHeight ();

          $x = rand ($tw / 4, $tw * 3 / 4);
          $y = rand ($th / 4, $th * 3 / 4);
          $r = rand ($th / 4, $th / 2);

          $draw = new ImagickDraw ();
          $draw->pushPattern ('enlarged', 0, 0, $tw, $th);
          $full->setImageOpacity (0.9);
          $draw->composite (Imagick::COMPOSITE_OVER, - $tw / 2, - $th / 2, $tw * 2, $th * 2, $full);
          $draw->popPattern ();
          $draw->setFillPatternURL ('#enlarged');

          $draw->setStrokeWidth (5);
          $draw->setStrokeColor ("white");
          $draw->setStrokeOpacity (0.5);
          $draw->setStrokeAlpha (0.5);

          $draw->circle ($x, $y, $x + $r, $y);

          $thumb->drawImage($draw);

          $draw = new ImagickDraw ();
          $draw->setFillOpacity (0);
          $draw->setStrokeWidth (5);
          $draw->setStrokeColor ("#111");
          $draw->setStrokeOpacity (0.3);

          $draw->circle ($x, $y, $x + $r, $y);

          $thumb->drawImage($draw);
          $thumb->writeImage ($output);

          return true;
        } else
          return false;
      }

  }