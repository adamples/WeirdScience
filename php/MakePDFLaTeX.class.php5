<?php

	class MakePDFLaTeX implements MakeMethod {

			public function __construct () {
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_array ($input) && is_a ($make, "Make")) {
					$input = $input [0];
					$current_dir = realpath (getcwd ());
					chdir (dirname ($input));
					exec ("pdflatex -interaction=nonstopmode \"" . basename ($input) . "\"");
					exec ("pdflatex -interaction=nonstopmode \"" . basename ($input) . "\"");
						foreach (glob (basename ($input, ".tex") . ".*") as $path)
							if ($path != basename ($input) && $path != basename ($input, ".tex") . ".pdf")
								unlink ($path);
					chdir ($current_dir);
						if (is_file (dirname ($input) . "/" . basename ($input, ".tex") . ".pdf")) {
							copy (dirname ($input) . "/" . basename ($input, ".tex") . ".pdf", $output) or die ("Dupa!\n");
							unlink (dirname ($input) . "/" . basename ($input, ".tex") . ".pdf");
							return true;
						}
					return false;
				} else
					return false;
			}

	}