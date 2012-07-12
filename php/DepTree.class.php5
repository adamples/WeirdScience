<?php

	class DepTree {
		private $pathes = array ();
		private $dep_on = array ();
		private $dep_of = array ();
		private $timestamps = array ();

			public function __construct () {
			}

			private function addFile ($path) {
				$id = array_search ($path, $this->pathes, true);
					if ($id === FALSE) {
						$this->pathes []= $path;
						$this->dep_on []= array ();
						$this->dep_of [] = array ();
						return count ($this->pathes) - 1;
					} else
						return $id;
			}

				/* Dodaje zależność pliku $to od pliku $from. */
			public function addDep ($to, $from) {
				$from_id = $this->addFile ($from);
				$to_id = $this->addFile ($to);
					if (array_search ($from_id, $this->dep_on [$to_id], true) === FALSE) {
						$this->dep_on [$to_id] []= $from_id;
						$this->dep_of [$from_id] []= $to_id;
					}
			}

			private function checkTimestamps () {
					for ($i = 0, $c = count ($this->pathes); $i < $c; $i++)
						if (is_file ($this->pathes [$i]))
							$this->timestamps [$i] = filemtime ($this->pathes [$i]);
						else
							$this->timestamps [$i] = -1;
			}

			public function getList () {
				$this->checkTimestamps ();
				$rebulid = array ();
				$tmp = $this->dep_on;
					while (count ($tmp) > 0) {
							foreach ($tmp as $file => $deps)
								if (count ($deps) == 0) {
											/* Jeśli plik nie istnieje */
										if ($this->timestamps [$file] == -1)
											$rebulid []= $file;
										else
											/* Jeśli starszy od jednej z zależności, albo jedna
											 * z nich została przeznaczona do przebudowania */
											foreach ($this->dep_on [$file] as $do)
												if ($this->timestamps [$do] == -1 || $this->timestamps [$file] < $this->timestamps [$do] || in_array ($do, $rebulid)) {
													$rebulid []= $file;
													break;
												}
										foreach ($this->dep_of [$file] as $do)
											$tmp [$do] = array_values (array_diff ($tmp [$do], array ($file)));
									unset ($tmp [$file]);
								}
					}
					foreach ($rebulid as &$file)
						$file = $this->pathes [$file];
				return $rebulid;
			}

			public function getDeps ($path) {
				$id = $this->addFile ($path);
				$res = $this->dep_on [$id];
					foreach ($res as &$path)
						$path = $this->pathes [$path];
				return $res;
			}


			public function getAllPathes () {
				return $this->pathes;
			}

	}
