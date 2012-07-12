<?php

	class MakeCat implements MakeMethod {


			public function __construct () {
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_a ($make, "Make")) {
					$content = "";
						foreach ($input as $path)
							$content .= file_get_contents ($path);
					file_put_contents ($output, $content);
					return true;
				} else
					return false;
			}

	}