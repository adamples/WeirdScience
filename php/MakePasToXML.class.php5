<?php

	class MakePasToXML implements MakeMethod {
		private $keywords = "absolute abstract all and array as asm begin case class const constructor destructor div do downto else end export external file for forward function goto if implementation in inherited initialization interface is label mod nil not object of operator or packed private procedure program protected public record repeat set shl shr then to type unit until uses var witrual while with xor";
		private $system_procs = "abs addr append arctan assert assign blockread blockwrite break chr close continue copy cos dec delete dispose eof eoln exclude exit exp filepos filesize fillbyte fillchar fillword filldword fillqword flush frac freemem getmem halt hi high inc include insert int length ln lo low lowercase move new odd ord paramcount paramstr pi pos pred random randomize read readln readstr reallocmem reset round seek seekeof seekeoln setlength sin sizeof sqr sqrt str strlen succ trunc upcase val write writeln writestr";
		private $crt_procs = "clreol clrscr directvideo delay delline gotoxy insline keypressed normvideo nosound readkey sound textattr textbackground textcolor wherex wherey windmax windmin window";



			public function __construct () {
				$this->keywords = array_flip (explode (" ", $this->keywords));
				$this->system_procs = array_flip (explode (" ", $this->system_procs));
				$this->crt_procs = array_flip (explode (" ", $this->crt_procs));
			}


			private function isoneof ($s, $words) {
				$s = strtolower ($s);
				return isset ($words [$s]);
			}


			private function is_keyword ($s) {
				return $this->isoneof ($s, $this->keywords);
			}


			private function is_system_proc ($s) {
				return $this->isoneof ($s, $this->system_procs);
			}


			private function is_crt_proc ($s) {
				return $this->isoneof ($s, $this->crt_procs);
			}


			private function translate ($input) {
				$output = '';
					for ($i = 0, $c = strlen ($input); $i < $c; $i++) {
							if ($input {$i} == '{') { // Komentarz #1
								$control = ($input{$i + 1} == '$');
									for ($tmp = ''; $i < $c && $input {$i} != '}'; $i++)
										if ($input {$i} == ' ')
											$tmp .= "\xC2\xA0";
										else
											if ($input {$i} == "\x0A")
												$tmp .= '<br/>';
											else
												$tmp .= htmlspecialchars ($input {$i});
								$output .= $control ? "<s type=\"control\">$tmp}</s>" : "<s type=\"comment\">$tmp}</s>";
							} else
							if ($input {$i} == '(' && $input {$i + 1} == '*') {
								$i += 2;
									for ($tmp = ''; $i < $c && !($input {$i} == '*' && $input {$i + 1} == ')'); $i++)
										if ($input {$i} == ' ')
											$tmp .= "\xC2\xA0";
										else
											if ($input {$i} == "\x0A")
												$tmp .= '<br/>';
											else
												$tmp .= htmlspecialchars ($input {$i});
								$output .= "<s type=\"comment\">(*$tmp*)</s>";
								$i += 1;
							} else
							if ($input {$i} == '/' && $input {$i + 1} == '/') {
									for ($tmp = ''; $i < $c && $input {$i} != "\x0A"; $i++)
										if ($input {$i} == ' ')
											$tmp .= "\xC2\xA0";
										else
											$tmp .= htmlspecialchars ($input {$i});
								$output .= "<s type=\"comment\">$tmp</s>";
								$i--;
							} else
							if ($input {$i} == "'") { // string
								$i++;
									for ($tmp = ''; $i < $c && $input {$i} != "'"; $i++)
										if ($input {$i} == ' ')
											$tmp .= "\xC2\xA0";
										else
											$tmp .= htmlspecialchars ($input {$i});
								$output .= "<s type=\"string\">'$tmp'</s>";
							} else
							if ($input {$i} == '#' && ctype_digit ($input {$i + 1})) { // Inny string
								$i++;
									for ($tmp = ''; $i < $c && ctype_digit ($input {$i}); $i++)
										$tmp .= $input {$i};
								$output .= "<s type=\"string\">#$tmp</s>";
								$i--;
							} else
							if (ctype_alpha ($input {$i}) || $input {$i} == '_') { // Identyfikator lub słowo kluczowe
									for ($tmp = ''; $i < $c && (ctype_alnum ($input {$i}) || $input {$i} == '_'); $i++)
										$tmp .= $input {$i};
									if ($this->is_keyword ($tmp))
										$output .= "<s type=\"keyword\">" . strtolower ($tmp) . "</s>";
									else
										if ($this->is_system_proc ($tmp))
											$output .= "<s type=\"identiffier\" ref=\"system#" . strtolower (trim ($tmp)) . "\">$tmp</s>";
										else if ($this->is_crt_proc ($tmp))
											$output .= "<s type=\"identiffier\" ref=\"system#" . strtolower (trim ($tmp)) . "\">$tmp</s>";
										else
											$output .= "<s type=\"identiffier\">$tmp</s>";
								$i--;
							} else
							if (ctype_digit ($input {$i})) { // Liczby stało i zmienno przecinkowe
									for ($tmp = ''; $i < $c && (ctype_digit ($input {$i}) || strpos ('eE+-.', $input {$i}) !== false); $i++)
										$tmp .= $input {$i};
								$output .= "<s type=\"number\">$tmp</s>";
								$i--;
							} else
							if ($input {$i} == '$') { // Liczby szesnastkowe
									for ($tmp = ''; $i < $c && (ctype_xdigit ($input {$i}) || $input {$i} == '$'); $i++)
										$tmp .= $input {$i};
								$output .= "<s type=\"number\">$tmp</s>";
								$i--;
							} else // Pojedyncze znaki
							if (strpos ("<>@+-=*/()[],.:;", $input {$i}) !== false)
								$output .= "<s type=\"char\">" . htmlspecialchars ($input {$i}) . "</s>";
							else
							if ($input {$i} == " ") // Spacja
								$output .= "\xC2\xA0";
							else
							if ($input {$i} == "\x0A") // Enter
								$output .= "<br/>";
							else // nieznany znak
							if (ord ($input {$i}) >= 128) {
									for ($tmp = ""; ord ($input {$i}) >= 128; $i++)
										$tmp .= $input {$i};
								$output .= "$tmp";
								$i--;
							} else
								$output .= $input {$i};
					}
				return "<?xml version=\"1.0\"?>\n<code>$output</code>";
			}


			public function run ($input, $output, $make, $params = null) {
				if (count ($input) == 1 && is_a ($make, "Make")) {
					$code = file_get_contents ($input [0]);
					$xml = $this->translate ($code);
					file_put_contents ($output, $xml);
					return true;
				} else
					return false;
			}

	}