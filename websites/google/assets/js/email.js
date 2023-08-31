const input = document.querySelector(".form-group input");
const label = document.querySelector(".form-group label[for='email']");
const button = document.querySelector(".dropdown");
const contas = document.querySelector(".contas");

input.onblur = function () {
  if (input.value !== "") {
    label.classList.add('active');
  } else {
    label.classList.remove('active');
  }
}

button.onclick = function(e) {
  e.preventDefault();
  contas.classList.toggle('activeDropdown');
}