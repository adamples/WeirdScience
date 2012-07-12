<?php

	class MakeCSS implements MakeMethod {


			public function __construct () {
			}


			public function run ($input, $output, $make) {
				copy ($input [0], $output);
				return true;
			}

	}