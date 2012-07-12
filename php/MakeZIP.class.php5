<?php

	class MakeZIP implements MakeMethod {

			public function __construct () {
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_a ($make, "Make")) {
					$zip = new ZipArchive ();
						if ($zip->open($output, ZIPARCHIVE::CREATE) !== true)
							return false;
						foreach ($input as $path)
							$zip->addFile ($path, str_replace ($params [0], $params [1], $path));
					$zip->close ();
					return true;
				} else
					return false;
			}

	}