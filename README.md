# dataSocial
Pesca dados de redes sociais através de páginas sociais modificadas usando a técnica phishing de engenharia social

### DataSocial
![main](https://github.com/Olliv3r/DataSocial/blob/main/media/modeInteractive.jpg)

### Instalação:

Atualizar o repositório e instalar o git:
```
apt update &&:apt upgrade -y && apt install git -y
```

Clonar o repositório e instalar dependências:
```
cd $HOME;git clone https://github.com/Olliv3r/DataSocial;cd DataSocial;bash ./setup.sh --install
```

> [!NOTE]
> Execute o programa numa shell proot, chroot ou outro ambiente diferente de *termux*, caso contrário pode mostrar links nulos do tunel:

#### Exemplo:

Entrar no ambiente `termux-chroot`:
```
termux-chroot
```

Executar no ambiente `termux-chroot`:
```
./dataaocial.sh
```

### Ajuda
Modo de opçôes:
```
./datasocial.sh --help
```
Use o modo interativo:
```
./datasocial.sh -i
```

### Desinstalação:
Caso queira desinstalar todos os programas que o *--install* instalou, basta usar a opção *--uninstall* ao invés de *--install*.


### Teste:
![main](https://github.com/Olliv3r/DataSocial/blob/main/media/process.jpg)

boa sorte :)!
