const linkExclamation = document.getElementById("link-exclamation");
const linkApp = document.getElementById("link-app");
const icone = document.getElementById("icone");
const iconeEye = document.getElementById("iconeEye");
const input = document.getElementById("password-input");

icone.addEventListener('click', () => {
  icone.classList.toggle("active");
  linkExclamation.classList.toggle("activeExcl");
  linkApp.classList.toggle("activeApp");
});

iconeEye.addEventListener('click', () => {
  if (input.type === "password") {
    input.type = "text";
    iconeEye.innerHTML = '<i class="fa-solid fa-eye"></i>';
  } else {
    input.type = "password";
    iconeEye.innerHTML = '<i class="fa-solid fa-eye-slash"></i>';
  }
  
});

