<?php

	class MakeIndex implements MakeMethod {
		private $min_length;

			public function __construct ($min_length = 3) {
				$this->min_length = $min_length;
			}

			private function compress (&$result) {
				$result = str_replace (array (", )", "  ", "\n"), "", $result);
				$result = str_replace (array (" => ", ",)", "<?php"), array ("=>", ")", "<?php\n"), $result);
			}

			private function stage1 ($ipath, $opath) {
					$index = "<?php\n";
					$content = file_get_contents ($ipath);
					$title = trim (substr ($content, 0, strpos ($content, "\n")));
						/* Może trzeba zamienić "(" na spacje (np. procedure cos(x:real);) */
					$content = strtr ($content, "|", " ");
					$content = normalize_space ($content);
					$content = explode (" ", $content);
					$content_matrix = array ();
					$words = array ();
						foreach ($content as $i => $word) {
							$n_word = normalize_space (strtocharset (strtolower (strtoascii ($word)), "abcdefghijklmnopqrstuvwxyz"));
								if (strlen ($n_word) >= $this->min_length) {
									if (!isset ($words [$n_word]))
										$words [$n_word] = array ($i);
									else
										$words [$n_word] []= $i;
								}
						}
					$output = "<?php\n"
						. "\$title=" . var_export ($title, true) . ";"
						. "\$content=" . var_export ($content, true) . ";"
						. "\$file_index=" . var_export ($words, true) . ";";
					$this->compress ($output);
					file_put_contents ($opath, $output);
			}

			private function stage2 ($ipathes, $opath) {
				$index = array ();
					foreach ($ipathes as $file_id => $ipath) {
						include $ipath;
							foreach ($file_index as $word => $positions)
								$index [$word][$file_id] = count ($positions);
						unset ($file_index);
					}
				$words = array_keys ($index);
				sort($words);
				$files = array ();
					for ($i = 0, $c = count ($ipathes); $i < $c; $i++)
						$files [$i] = basename ($ipathes [$i], ".php");
				$output =  "<?php\n"
					. "\$files=" . var_export ($files, true) . ";"
					. "\$index=" . var_export ($index, true) . ";"
					. "\$words=" . var_export ($words, true) . ";";
				$this->compress ($output);
				file_put_contents ($opath, $output);
			}

			public function run ($input, $output, $make, $params = null) {
				if (is_a ($make, "Make")) {
					switch ($params [0]) {
						case "stage-1" : $this->stage1 ($input [0], $output); break;
						case "stage-2" : $this->stage2 ($input, $output);
						//case "stage3" : $this->stage1 ($input, $output);
					}
					return true;
				} else
					return false;
			}

	}