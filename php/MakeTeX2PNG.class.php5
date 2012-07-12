<?php

	class MakeTeX2PNG implements MakeMethod {


			public function __construct () {
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_a ($make, "Make")) {
					$tex = $params [0];
					file_put_contents ("/tmp/math.tex", "\\documentclass{article}[10pt]\n\\begin{document}\n\\thispagestyle{empty}\n\$$tex\$\n\\end{document}\n");
					exec ("latex -interaction=nonstopmode -output-directory /tmp math.tex > /dev/null");
					exec ("dvipng /tmp/math.dvi -bg Transparent -D 108 -T tight -o \"$output\" > /dev/null");
					return true;
				} else
					return false;
			}

	}