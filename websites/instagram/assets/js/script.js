const icone = document.querySelector('[data-icone]');
const passInput = document.querySelector('[data-input]');
const link = document.querySelector('[data-link-icone]')
const image = document.getElementById('image');

// Funcionalidade: slide automatico
function slide() {
  image.src = "assets/img/destaque.png";
  setTimeout("slide2()", 5000);
}

function slide2() {
  image.src = "assets/img/destaque2.png";
  setTimeout("slide3()", 5000);
}

function slide3() {
  image.src = "assets/img/destaque3.png";
  setTimeout("slide4()", 5000)
}

function slide4() {
  image.src = "assets/img/destaque4.png";
  setTimeout("slide()", 5000)
}

// Funcionalidade: mostrar/ocultar
icone.addEventListener("click", () => {
  if (passInput.type === "password") {
    passInput.type = "text";
    icone.innerHTML = '<i data-icone class="fa-solid fa-eye-slash"></i>';
  } else if (passInput.type === "text") {
    passInput.type = "password";
    icone.innerHTML = '<i data-icone class="fa-solid fa-eye"></i>';
  }

});