<?php

  class Make {
    private $tree;
    private $registered_methods = array ();
    private $methods = array ();
    private $params = array ();
    private $use_md5;
    private $md5_path;
    private $old_md5;
    private $md5 = array ();
    private $total_objects = 0;
    private $output_objects = 0;
    private $made = array ();


      public function __construct ($use_md5 = false, $md5_path = "./old_md5.php") {
        $this->tree = new DepTree ();
        $this->registerMethod (new MakeNULL (), "null");
        $this->registerMethod (new MakeXSL (), "xsl");
        $this->registerMethod (new MakeCat (), "cat");
        $this->use_md5 = $use_md5;
          if ($this->use_md5) {
            $this->md5_path = realpath (dirname ($md5_path)) . "/" . basename ($md5_path);
              if (is_file ("$md5_path"))
                $this->old_md5 = include "$md5_path";
          }
      }


      public function clear_rules () {
        $this->tree = new DepTree ();
        /*$methods = array ();
        $params = array ();
        $md5 = array ();
        $total_objects = 0;
        $output_objects = 0;*/
      }


      public function __destruct () {
          if ($this->use_md5)
            file_put_contents ("$this->md5_path", "<?php\nreturn " . var_export ($this->md5, true) . ";");
      }


      public function registerMethod ($method, $id) {
          if ($method instanceof MakeMethod)
            $this->registered_methods [$id] = $method;
          else
            log_write ("Make->registerMethod (): Nieprawidłowa metoda", LOG_E);
      }


      private function file_get_md5 ($path) {
          if (is_file ($path))
            $this->md5 [$path] = md5_file ($path);
      }


      private function file_changed ($path) {
        return !isset ($this->old_md5 [$path]) || $this->old_md5 [$path] != $this->md5 [$path];
      }


      public function addRule ($input, $output, $method_id, $params = null) {
          if (is_array ($input) && is_string ($output) && isset ($this->registered_methods [$method_id]) && ($params == null || is_array ($params))) {
//            $method = $this->registered_methods[$method_id];
//            $method_name = get_class ($method);
//            $input []= realpath ("../php/$method_name.class.php5");
              foreach ($input as $path) {
                $this->tree->addDep ($output, $path);
                $this->file_get_md5 ($path);
              }
            $this->file_get_md5 ($output);
            $this->methods [$output] = $method_id;
            $this->params [$output] = $params;
          } else
            log_write ("Make->addRule (): Nieprawidłowe wejście lub metoda");
      }


      private function createDir ($path) {
          if (!is_dir ($path)) {
            $this->createDir (dirname ($path));
            log_write ("Make->createDir (): Tworzę katalog \"$path\"");
            mkdir ($path);
          }
      }


      private function run ($path) {
          if (in_array ($path, $this->made))
            return true;
          if (isset ($this->methods [$path])) {
            $input = $this->tree->getDeps ($path);
              if ($this->use_md5 && is_file ($path)) {
                for ($i = 0; $i < count ($input); $i++)
                  if ($this->file_changed ($input [$i])) break;
                if ($i == count ($input)) return true;
              }
            $this->createDir (dirname ($path));
            log_write ("Make->run (): Wykonywanie \"$path\" za pomocą " . $this->methods [$path], LOG_IB);
              if ($this->registered_methods [$this->methods [$path]]->run ($input, $path, $this, $this->params [$path])) {
                log_write ("sukces", LOG_IE);
                $this->made []= $path;
                $this->total_objects ++;
                  if (substr ($path, 0, 6) == "output")
                    $this->output_objects ++;
                  if ($this->use_md5)
                    $this->file_get_md5 ($path);
              } else {
                log_write ("błąd", LOG_IE);
                unlink($path);
                return false;
              }
          } else {
            log_write ("Make->run (): Brak reguł do wykonania obiektu \"$path\"", LOG_E);
            return false;
          }
        return true;
      }


      public function runAll () {
        $this->changed = array ();
        $pathes = $this->tree->getList ();
          for ($i = 0, $c = count ($pathes); $i < $c && $this->run ($pathes [$i]); $i++);
          if ($i < $c) {
            log_write ("Make->runAll (): Wykonanie zakończone niepowodzeniem", LOG_E);
            return false;
          }
      }


      private function cleanDirInt ($path, $files) {
        $glob = glob ("$path/*");
        $res = count ($glob);
          foreach ($glob as $file)
            if (is_dir ($file)) {
              if ($this->cleanDirInt ($file, $files) == 0) {
                log_write ("Make->cleanDirInt (): Usuwanie zbędnego katalogu \"$file\"");
                rmdir ($file);
                $res--;
              }
            } else
              if (array_search ($file, $files, true) === false) {
                log_write ("Make->cleanDirInt (): Usuwanie zbędnego pliku \"$file\"");
                unlink ($file);
                $res--;
              }
        return $res;
      }


      public function cleanDir ($path) {
        $files = $this->tree->getAllPathes ();
        $this->cleanDirInt ($path, $files);
      }


      public function printSummary () {
        if ($this->total_objects)
          log_write ("Make->printSummary (): Wykonano " . ndec ($this->output_objects, "obiekt", "obiekty", "obiektów") . " (+" . ndec ($this->total_objects - $this->output_objects, "tymczasowy", "tymczasowe", "tymczasowych") . ")");
        else
          log_write ("Make->printSummary (): Nie wykonano żadnego obiektu");
      }

  }
