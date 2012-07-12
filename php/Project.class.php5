<?php

  class Project {

    protected   $make;
    protected   $base_dir;


    public function __construct ($base_dir) {
      $this->base_dir = $base_dir;
      $this->make = new Make (true, $this->base_dir . "/.md5.php");
      $this->make->registerMethod (new MakeHyphenation (), "hyphenation");
      $this->make->registerMethod (new MakeTeX2PNG (), "tex2png");
      $this->make->registerMethod (new MakeQRCode (), "qrcode");
      $this->make->registerMethod (new MakeExternal ("touch \$o"), "touch");
    }


    protected function pre_build () {
      log_write ("Project->pre_build ()");
    }


    public function build () {
      list ($bmicro, $bsec) = explode (" ", microtime ());
      log_write ("Project->build (): Wchodzę do \"" . $this->base_dir . "\"");
      chdir ($this->base_dir);
      $this->pre_build ();
      $this->make->runAll ();
      $this->post_build ();
      log_write ("Project->build (): Sprzątanie");
      $this->make->cleanDir ("output");
      $this->make->cleanDir ("tmp");
      $this->make->printSummary ();
      list ($emicro, $esec) = explode (" ", microtime ());
      log_write ("Project->build (): Koniec");
    }


    protected function post_build () {
      log_write ("Project->post_build ()");
    }

  }
