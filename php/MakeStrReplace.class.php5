<?php

	class MakeStrReplace implements MakeMethod {
		private $search;
		private $replace;

			public function __construct ($search, $replace) {
				$this->search = $search;
				$this->replace = $replace;
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_array ($input) && count ($input) == 1 && is_a ($make, "Make")) {
					$ifile = file_get_contents ($input [0]);
					$ofile = str_replace ($this->search, $this->replace, $ifile);
					file_put_contents ($output, $ofile);
					return true;
				} else
					return false;
			}

	}