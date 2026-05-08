// =========================
// DATOS GUARDADOS
// =========================

const historialDiv =
document.getElementById("historial");

const recomendacionInput =
document.getElementById("recomendacion");

const guardarBtn =
document.getElementById("guardarRecomendacion");


// =========================
// CARGAR REGISTROS
// =========================

const registros =
JSON.parse(localStorage.getItem("registros"))
|| [];


// =========================
// CALORÍAS
// =========================

let calorias = [];

let nombres = [];

let proteinas = 0;

let carbohidratos = 0;

let grasas = 0;


// Simulación nutricional
registros.forEach((r) => {

  nombres.push(r.nombre);

  calorias.push(r.calorias);

  proteinas += 20;

  carbohidratos += 30;

  grasas += 10;

});


// =========================
// GRÁFICA CALORÍAS
// =========================

new Chart(

document.getElementById("caloriasChart"),

{
  type: "bar",

  data: {

    labels: nombres,

    datasets: [{

      label: "Calorías",

      data: calorias,

      borderWidth: 1

    }]
  }
});


// =========================
// GRÁFICA MACROS
// =========================

new Chart(

document.getElementById("macroChart"),

{
  type: "pie",

  data: {

    labels: [
      "Proteínas",
      "Carbohidratos",
      "Grasas"
    ],

    datasets: [{

      data: [
        proteinas,
        carbohidratos,
        grasas
      ]

    }]
  }
});


// =========================
// GUARDAR RECOMENDACIONES
// =========================

guardarBtn.addEventListener("click", () => {

  const texto =
  recomendacionInput.value;

  if(!texto){

    alert("Escribe una recomendación");

    return;
  }

  const observaciones =
  JSON.parse(localStorage.getItem("observaciones"))
  || [];

  observaciones.push(texto);

  localStorage.setItem(
    "observaciones",
    JSON.stringify(observaciones)
  );

  recomendacionInput.value = "";

  cargarHistorial();

  alert("Recomendación guardada 🌱");
});


// =========================
// MOSTRAR HISTORIAL
// =========================

function cargarHistorial(){

  const observaciones =
  JSON.parse(localStorage.getItem("observaciones"))
  || [];

  historialDiv.innerHTML = "";

  observaciones.forEach((obs) => {

    historialDiv.innerHTML += `

      <div class="card" style="margin-top:10px;">

        📝 ${obs}

      </div>

    `;
  });
}

cargarHistorial();