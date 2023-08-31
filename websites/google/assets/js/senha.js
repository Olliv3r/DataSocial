const input = document.querySelector(".form-group input");
const label = document.querySelector(".form-group label[for='senha']");
const senhaInput = document.querySelector(".form-group input");
const elementInput = document.querySelector("input[id='mostrarOcultar']");

input.onblur = function () {
  if (input.value !== "") {
    label.classList.add('active');
  } else {
    label.classList.remove('active');
  }
}

elementInput.onclick = function() {
  if (senhaInput.type == "text") {
    senhaInput.type = "password";
  } else {
    senhaInput.type = "text";
  }
}

