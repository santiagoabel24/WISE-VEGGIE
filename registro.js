const inputBuscar = document.getElementById("inputBuscar");
const btnBuscar = document.getElementById("btnBuscar");
const listaResultados = document.getElementById("listaResultados");
const form = document.getElementById("foodForm");
const productoSeleccionadoTxt = document.getElementById("productoSeleccionado");
const contador = document.getElementById("contadorCalorias");
const resultado = document.getElementById("resultado");

let alimentoSeleccionado = null;
let caloriasTotales = Number(localStorage.getItem("caloriasHoy")) || 0;
contador.innerText = `Calorías de hoy: ${caloriasTotales.toFixed(1)} kcal`;

btnBuscar.addEventListener("click", buscarAlimentoAPI);
inputBuscar.addEventListener("keypress", (e) => {
    if (e.key === "Enter") buscarAlimentoAPI();
});

function buscarAlimentoAPI() {
    const texto = inputBuscar.value.trim();
    if (!texto) {
        alert("Escribe algo para buscar 🍎");
        return;
    }

    listaResultados.innerHTML = "<p style='color: white;'>Buscando en la base de datos...</p>";

    const url = `https://mx.openfoodfacts.org/cgi/search.pl?search_terms=${encodeURIComponent(texto)}&search_simple=1&action=process&json=1&page_size=5`;

    fetch(url)
        .then(response => response.json()) 
        .then(data => {
            listaResultados.innerHTML = "";
            
            if (!data.products || data.products.length === 0) {
                listaResultados.innerHTML = "<p style='color: white;'>No se encontraron productos. ¡Intenta con otra palabra!</p>";
                return;
            }

            data.products.forEach(producto => {
                const nutris = producto.nutriments;
                const kcal100g = nutris["energy-kcal_100g"] || nutris["energy-kcal"] || 0;
                const prot100g = nutris["proteins_100g"] || 0;
                const carbs100g = nutris["carbohydrates_100g"] || 0;
                const grasas100g = nutris["fat_100g"] || 0;

                const item = document.createElement("div");
                item.style.background = "rgba(255, 255, 255, 0.2)";
                item.style.padding = "10px";
                item.style.margin = "5px 0";
                item.style.borderRadius = "5px";
                item.style.cursor = "pointer";
                item.style.color = "white";
                item.innerHTML = `<strong>${producto.product_name || "Producto Genérico"}</strong><br><small>${kcal100g} kcal por cada 100g</small>`;

                item.addEventListener("click", () => {
                    alimentoSeleccionado = {
                        nombre: producto.product_name || texto,
                        kcal100g,
                        prot100g,
                        carbs100g,
                        grasas100g
                    };
                    
                    productoSeleccionadoTxt.innerText = `Seleccionado: ${alimentoSeleccionado.nombre}`;
                    form.style.display = "block";
                    listaResultados.innerHTML = ""; 
                });

                listaResultados.appendChild(item);
            });
        })
        .catch(error => {
            console.error("Error al conectar con la API:", error);
            listaResultados.innerHTML = "<p style='color: red;'>Error de red al conectar con la API.</p>";
        });
}

form.addEventListener("submit", (e) => {
    e.preventDefault();

    const cantidad = Number(document.getElementById("cantidad").value); 
    const hora = document.getElementById("hora").value;

    if (!alimentoSeleccionado || !cantidad || !hora) {
        alert("Por favor completa los gramos y la hora ⏰");
        return;
    }

    const factor = cantidad / 100;
    const caloriasCalculadas = alimentoSeleccionado.kcal100g * factor;
    const proteinaCalculada = alimentoSeleccionado.prot100g * factor;
    const carbohidratosCalculados = alimentoSeleccionado.carbs100g * factor;
    const grasaCalculada = alimentoSeleccionado.grasas100g * factor;

    caloriasTotales += caloriasCalculadas;
    localStorage.setItem("caloriasHoy", caloriasTotales);

    const registros = JSON.parse(localStorage.getItem("registros")) || [];
    registros.push({
        nombre: alimentoSeleccionado.nombre,
        cantidad: cantidad,
        hora: hora,
        calorias: caloriasCalculadas,
        proteina: proteinaCalculada,
        carbohidratos: carbohidratosCalculados,
        grasa: grasaCalculada,
        fecha: new Date().toISOString().split("T")[0]
    });
    localStorage.setItem("registros", JSON.stringify(registros));

    resultado.innerHTML = `
        <div class="card" style="background: rgba(255,255,255,0.9); padding: 15px; border-radius: 15px; margin-top: 15px; color: #333;">
            <h3 style="color: #2e5a36;">✅ ¡Registrado con éxito!</h3>
            <p><strong>${alimentoSeleccionado.nombre}</strong></p>
            <p>🔥 Calorías: ${caloriasCalculadas.toFixed(1)} kcal</p>
            <p>💪 Proteínas: ${proteinaCalculada.toFixed(1)} g</p>
            <p>🌾 Carbs: ${carbohidratosCalculados.toFixed(1)} g</p>
            <p>🥑 Grasas: ${grasaCalculada.toFixed(1)} g</p>
        </div>
    `;

    contador.innerText = `Calorías de hoy: ${caloriasTotales.toFixed(1)} kcal`;
    form.reset();
    form.style.display = "none";
    inputBuscar.value = "";
    alimentoSeleccionado = null;
});
