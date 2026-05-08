// =======================
// BASE DE DATOS SIMPLE
// =======================

const alimentosDB = {

    manzana: {
        calorias: 52,
        proteina: 0.3,
        carbohidratos: 14,
        grasa: 0.2
    },

    arroz: {
        calorias: 130,
        proteina: 2.7,
        carbohidratos: 28,
        grasa: 0.3
    },

    pollo: {
        calorias: 239,
        proteina: 27,
        carbohidratos: 0,
        grasa: 14
    },

    frijoles: {
        calorias: 347,
        proteina: 21,
        carbohidratos: 63,
        grasa: 1.2
    },

    huevo: {
        calorias: 155,
        proteina: 13,
        carbohidratos: 1.1,
        grasa: 11
    }
};


// =======================
// ELEMENTOS HTML
// =======================

const form = document.getElementById("foodForm");

const resultado = document.getElementById("resultado");

const contador = document.getElementById("contadorCalorias");


// =======================
// CARGAR CALORÍAS
// =======================

let caloriasTotales =
    Number(localStorage.getItem("caloriasHoy")) || 0;

contador.innerText =
`Calorías de hoy: ${caloriasTotales} kcal`;


// =======================
// FORMULARIO
// =======================

form.addEventListener("submit", (e) => {

    e.preventDefault();

    const nombre =
        document.getElementById("nombre")
        .value
        .toLowerCase();

    const cantidad =
        Number(document.getElementById("cantidad").value);

    const hora =
        document.getElementById("hora").value;


    // VALIDACIÓN
    if(!nombre || !cantidad || !hora){

        alert("Completa todos los campos 🌱");

        return;
    }


    // BUSCAR ALIMENTO
    const alimento = alimentosDB[nombre];


    if(!alimento){

        resultado.innerHTML = `
            <p>
            ⚠ No encontramos ese alimento.
            </p>
        `;

        return;
    }


    // CÁLCULOS
    const factor = cantidad / 100;

    const calorias =
        (alimento.calorias * factor).toFixed(1);

    const proteina =
        (alimento.proteina * factor).toFixed(1);

    const carbohidratos =
        (alimento.carbohidratos * factor).toFixed(1);

    const grasa =
        (alimento.grasa * factor).toFixed(1);


    // GUARDAR CALORÍAS
    caloriasTotales += Number(calorias);

    localStorage.setItem(
        "caloriasHoy",
        caloriasTotales
    );


    // GUARDAR REGISTRO
    const registros =
        JSON.parse(localStorage.getItem("registros"))
        || [];

registros.push({

    nombre,

    cantidad,

    hora,

    calorias,

    fecha:
    new Date()
    .toISOString()
    .split("T")[0]

});

    localStorage.setItem(
        "registros",
        JSON.stringify(registros)
    );


    // MOSTRAR RESULTADOS
    resultado.innerHTML = `

        <div class="card">

            <h2>✅ Alimento guardado</h2>

            <br>

            <p><strong>Alimento:</strong> ${nombre}</p>

            <p><strong>Cantidad:</strong> ${cantidad} g</p>

            <p><strong>Hora:</strong> ${hora}</p>

            <br>

            <p>🔥 Calorías: ${calorias} kcal</p>

            <p>💪 Proteína: ${proteina} g</p>

            <p>🌾 Carbohidratos: ${carbohidratos} g</p>

            <p>🥑 Grasas: ${grasa} g</p>

        </div>

    `;


    // ACTUALIZAR CONTADOR
    contador.innerText =
    `Calorías de hoy: ${caloriasTotales.toFixed(1)} kcal`;


    // LIMPIAR FORM
    form.reset();

});