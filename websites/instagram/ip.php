<?php
if(isset($_SERVER['HTTP_CLIENT_IP'])) {
	$ip = $_SERVER['HTTP_CLIENT_IP'];

}
else if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
	$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];

}
else if (isset($_SERVER['REMOTE_ADDR'])) {
	$ip = $_SERVER['REMOTE_ADDR'];

}

$arquivo = fopen("ip.txt", "w");

fwrite($arquivo ,"Endereço IP: {$ip}");

fclose($arquivo);
?>
