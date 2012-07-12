<?php

  class MakeImageMetadata implements MakeMethod {


      public function __construct () {
      }


      public function run ($input, $output, $make, $params = null) {
        if (is_a ($make, "Make")) {

          $input = $input [0];

          $doc = new DOMDocument ("1.0", "UTF-8");
          $doc->appendChild ($doc->createElement ("image-metadata"));
          $root = $doc->documentElement;

          $root->appendChild ($doc->createElement ("original-path", $input));
          $root->appendChild ($doc->createElement ("original-name", basename ($input)));

          $root->appendChild ($doc->createElement ("destination-name", image_output_path ($input)));

          $info = getimagesize ($input);

          $root->appendChild ($doc->createElement ("width", basename ($info[0])));
          $root->appendChild ($doc->createElement ("height", basename ($info[1])));

          $doc->save ($output);
          return true;

        } else
          return false;
      }

  }
