# dataSocial
Pesca dados de redes sociais através de páginas sociais modificadas usando a técnica phishing de engenharia social

### DataSocial
![main](https://github.com/Olliv3r/dataSocial/blob/main/media/modeInteractive.jpg)

### Instalação:
```
apt update && apt upgrade -y && apt install git proot curl -y && cd $HOME && git clone https://github.com/Olliv3r/dataSocial && cd dataSocial && bash install.sh && termux-chroot ./dataSocial.sh --help
```

### Obs! Resoluçâo do erro
Execute o programa na shell proot, chroot ou outro, caso contrário pode mostrar links nulos do tunel:
```
termux-chroot
```
Use o modo interativo caso queira:
```
cd dataSocial && termux-chroot ./dataSocial.sh -i # Modo interativo
```
### Processo:
![main](https://github.com/Olliv3r/dataSocial/blob/main/media/process.jpg)
