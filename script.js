// ==========================
// FIREBASE
// ==========================

import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyCMe-aEU-ennfnuEJfKLIbCRLeIvMeImPw",
  authDomain: "wise-veggie.firebaseapp.com",
  projectId: "wise-veggie",
  storageBucket: "wise-veggie.firebasestorage.app",
  messagingSenderId: "506577852638",
  appId: "1:506577852638:web:33222e3f0797c0fac04a4f",
  measurementId: "G-P572C5P757"
};

const app = initializeApp(firebaseConfig);

getAnalytics(app);


// ==========================
// CALENDARIO
// ==========================

const calendar =
document.getElementById("calendar");

if(calendar){

  const monthYear =
  document.getElementById("monthYear");

  const fechaActual =
  document.getElementById("fechaActual");

  const prevMonth =
  document.getElementById("prevMonth");

  const nextMonth =
  document.getElementById("nextMonth");

  const today = new Date();

  let currentMonth =
  today.getMonth();

  let currentYear =
  today.getFullYear();

  const meses = [
    "Enero","Febrero","Marzo","Abril",
    "Mayo","Junio","Julio","Agosto",
    "Septiembre","Octubre","Noviembre","Diciembre"
  ];

  fechaActual.innerHTML =
  `📅 Hoy es ${today.toLocaleDateString()}
   ⏰ ${today.toLocaleTimeString()}`;

  function renderCalendar(month, year){

    calendar.innerHTML = "";

    monthYear.innerText =
    `${meses[month]} ${year}`;

    const firstDay =
    new Date(year, month, 1).getDay();

    const daysInMonth =
    new Date(year, month + 1, 0).getDate();

    for(let i = 0; i < firstDay; i++){

      const empty =
      document.createElement("div");

      empty.classList.add("empty");

      calendar.appendChild(empty);
    }

    for(let day = 1; day <= daysInMonth; day++){

      const dayDiv =
      document.createElement("div");

      dayDiv.classList.add("day");

      dayDiv.innerText = day;

      if(
        day === today.getDate() &&
        month === today.getMonth() &&
        year === today.getFullYear()
      ){
        dayDiv.classList.add("today");
      }

      const saved =
      localStorage.getItem(
      `${year}-${month}-${day}`);

      if(saved){
        dayDiv.classList.add("registered");
      }

      calendar.appendChild(dayDiv);
    }
  }

  prevMonth.addEventListener("click", () => {

    currentMonth--;

    if(currentMonth < 0){

      currentMonth = 11;

      currentYear--;
    }

    renderCalendar(currentMonth, currentYear);
  });

  nextMonth.addEventListener("click", () => {

    currentMonth++;

    if(currentMonth > 11){

      currentMonth = 0;

      currentYear++;
    }

    renderCalendar(currentMonth, currentYear);
  });

  renderCalendar(currentMonth, currentYear);
}


// =========================
// TIPS Y NOTICIAS
// =========================

const contenedorNoticias =
document.getElementById("contenedorNoticias");

if(contenedorNoticias){

  const noticias = [

  {
      id:1,
      tema:"azucar",
      titulo:"Reduce el exceso de azúcar 🍭",
      contenido:
      "Consumir demasiada azúcar puede afectar la energía y salud."
  },

  {
      id:2,
      tema:"grasas",
      titulo:"Las grasas saludables ayudan 🥑",
      contenido:
      "El aguacate y nueces contienen grasas beneficiosas."
  },

  {
      id:3,
      tema:"hidratacion",
      titulo:"Tomar agua mejora el cuerpo 💧",
      contenido:
      "La hidratación ayuda al metabolismo y concentración."
  }

  ];

  function mostrarNoticias(lista){

      contenedorNoticias.innerHTML = "";

      lista.forEach((noticia) => {

          const leido =
          localStorage.getItem(
          `leido-${noticia.id}`);

          contenedorNoticias.innerHTML += `

          <div class="noticia ${leido ? "leido" : ""}">

              <h3>${noticia.titulo}</h3>

              <p>${noticia.contenido}</p>

              <small>
                Tema: ${noticia.tema}
              </small>

              <br><br>

              <button onclick="marcarLeido(${noticia.id})">

                  ${leido
                    ? "Leído ✅"
                    : "Marcar como leído"}

              </button>

          </div>
          `;
      });
  }

  window.filtrarTema = function(tema){

      if(tema === "todos"){

          mostrarNoticias(noticias);

          return;
      }

      const filtradas =
      noticias.filter(
        n => n.tema === tema
      );

      mostrarNoticias(filtradas);
  }

  window.marcarLeido = function(id){

      localStorage.setItem(
      `leido-${id}`,
      true
      );

      mostrarNoticias(noticias);
  }

  mostrarNoticias(noticias);
}

// ==========================
// MÉTRICAS Y RACHA
// ==========================

const rachaActual =
document.getElementById("rachaActual");

const diasRegistrados =
document.getElementById("diasRegistrados");

const detalleDia =
document.getElementById("detalleDia");


// ==========================
// CALCULAR RACHA
// ==========================

function calcularRacha(){

    const registros =
    JSON.parse(localStorage.getItem("registros"))
    || [];

    const fechas = new Set();

    registros.forEach((r) => {

        if(r.fecha){

            fechas.add(r.fecha);
        }
    });

    diasRegistrados.innerText =
    `Días registrados: ${fechas.size}`;

    let racha = 0;

    const hoy = new Date();

    for(let i = 0; i < 365; i++){

        const fecha = new Date();

        fecha.setDate(hoy.getDate() - i);

        const key =
        fecha.toISOString().split("T")[0];

        if(fechas.has(key)){

            racha++;

        }else{

            break;
        }
    }

    rachaActual.innerText =
    `Racha actual: ${racha} días 🔥`;
}

calcularRacha();


// ==========================
// VER DETALLES DEL DÍA
// ==========================

window.verDetalleDia = function(fecha){

    const registros =
    JSON.parse(localStorage.getItem("registros"))
    || [];

    const delDia =
    registros.filter(
        r => r.fecha === fecha
    );

    if(delDia.length === 0){

        detalleDia.innerHTML =
        "No hay registros ese día.";

        return;
    }

    detalleDia.innerHTML = "";

    delDia.forEach((r) => {

        detalleDia.innerHTML += `

        <div class="card" style="margin-top:10px;">

            <h3>${r.nombre}</h3>

            <p>
                Cantidad: ${r.cantidad} g
            </p>

            <p>
                Hora: ${r.hora}
            </p>

            <p>
                🔥 ${r.calorias} kcal
            </p>

        </div>

        `;
    });
}


// ==========================
// HACER CLICK EN DÍAS
// ==========================

document.querySelectorAll(".day").forEach((dayDiv) => {

    dayDiv.addEventListener("click", () => {

        const dia =
        dayDiv.innerText;

        const fecha =
        `${currentYear}-${
            String(currentMonth + 1).padStart(2,"0")
        }-${
            String(dia).padStart(2,"0")
        }`;

        verDetalleDia(fecha);
    });
});


// ==========================
// ENCUESTAS
// ==========================

const surveyForm =
document.getElementById("surveyForm");

const encuestasGuardadas =
document.getElementById("encuestasGuardadas");

if(surveyForm){

    surveyForm.addEventListener("submit", (e) => {

        e.preventDefault();

        const persona =
        document.getElementById("persona").value;

        const habito =
        document.getElementById("habito").value;

        const encuestas =
        JSON.parse(localStorage.getItem("encuestas"))
        || [];

        encuestas.push({
            persona,
            habito
        });

        localStorage.setItem(
            "encuestas",
            JSON.stringify(encuestas)
        );

        mostrarEncuestas();

        surveyForm.reset();

        alert("Encuesta guardada 🌱");
    });
}


// ==========================
// MOSTRAR ENCUESTAS
// ==========================

function mostrarEncuestas(){

    if(!encuestasGuardadas) return;

    const encuestas =
    JSON.parse(localStorage.getItem("encuestas"))
    || [];

    encuestasGuardadas.innerHTML = "";

    encuestas.forEach((e) => {

        encuestasGuardadas.innerHTML += `

        <div class="card" style="margin-top:10px;">

            <h3>${e.persona}</h3>

            <p>${e.habito}</p>

        </div>

        `;
    });
}

mostrarEncuestas();