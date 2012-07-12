<?php

	class MakeQRCode implements MakeMethod {


			public function __construct () {
			}


			public function run ($input, $output, $make, $params = null) {
				if (is_a ($make, "Make")) {
					QRcode::png ($params [0], $output, QR_ECLEVEL_L, 5, 0);
					return true;
				} else
					return false;
			}

	}