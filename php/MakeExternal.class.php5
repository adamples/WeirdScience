<?php

  class MakeExternal implements MakeMethod {
    private $command;


      public function __construct ($command) {
        $this->command = $command;
      }


      public function run ($input, $output, $make, $params = null) {
        if (is_a ($make, "Make")) {
          $command = $this->command;
            foreach ($input as $i => $path) {
              $command = str_replace ("$" . ($i + 1), '"' . str_replace("\"", "\\\"", $path) . '"', $command);
            }
          $command = str_replace ("\$o", '"' . str_replace("\"", "\\\"", $output) . '"', $command);
          exec ($command);
          return true;
        } else
          return false;
      }

  }
