<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%@ include file="menu.jsp" %>
<%@ page import="ConnSrv.GuardarClienteServlet" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página de Arriendo de Departamentos</title>
    <style>
        /* Agregado el estilo para el modal */
        #reservaModal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1;
        }

        .modal-content {
            background-color: #fefefe;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .modal-content label,
        .modal-content input,
        .modal-content button {
            margin: 10px;
        }

        .modal-content button {
            background-color: #333;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
    </style>

    <script>
        function envioDatos(idDepartamento) {
            // Obtén los valores de los campos del formulario
            var rut = document.getElementById('rut').value;
            var correo = document.getElementById('correo').value;
            var telefono = document.getElementById('telefono').value;
            var nombre = document.getElementById('nombre').value;
            var fechaInicio = document.getElementById('fechaInicio').value;
            var fechaFin = document.getElementById('fechaFin').value;

            // Obtén el valor del tipo de reserva
            var tipoReserva = document.getElementById('tipoReserva').value;

            // Realiza la conexión y la inserción en la base de datos
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "GuardarClienteServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // Formatea los datos para enviar en la solicitud POST
            var datos = "rut=" + rut + "&correo=" + correo + "&telefono=" + telefono + "&nombre=" + nombre + "&idDepartamento=" + idDepartamento + "&fechaInicio=" + fechaInicio + "&fechaFin=" + fechaFin + "&tipoReserva=" + tipoReserva;

            // Define la función a ejecutar cuando la solicitud se complete
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    // Maneja la respuesta del servidor
                    console.log(xhr.responseText);
                    // Agrega aquí cualquier lógica adicional después de enviar los datos

                    // Realiza una actualización adicional
                    actualizarEstadoReserva(idDepartamento);
                    
                    window.location.href = "Detalles.jsp";
                }
            };

            // Envía la solicitud con los datos del formulario y el ID del departamento
            xhr.send(datos);
        }

        // Nueva función para actualizar el estado de la reserva
        function actualizarEstadoReserva(idDepartamento) {
            // Realiza la conexión y la actualización en la base de datos
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "ActualizarEstadoReservaServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            // Formatea los datos para enviar en la solicitud POST
            var datos = "idDepartamento=" + idDepartamento;

            // Define la función a ejecutar cuando la solicitud se complete
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    // Maneja la respuesta del servidor
                    console.log(xhr.responseText);
                    // Agrega aquí cualquier lógica adicional después de actualizar el estado
                }
            };

            // Envía la solicitud con el ID del departamento
            xhr.send(datos);
        }

        function abrirReservaModal(idDepartamento) {
            var modal = document.getElementById('reservaModal');
            modal.style.display = 'flex';

            // Puedes realizar acciones adicionales con el ID del departamento si es necesario
            console.log("ID del departamento seleccionado: " + idDepartamento);

            // Puedes almacenar el ID en un campo oculto si es necesario
            document.getElementById('idDepartamentoReservado').value = idDepartamento;
        }

        function cerrarReservaModal() {
            var modal = document.getElementById('reservaModal');
            modal.style.display = 'none';
        }
    </script>
</head>
<body>
    <main>
        <section id="busqueda">
            <!-- ... (sin cambios) ... -->
        </section>

        <section id="listado">
            <h2 style="text-align: center; color: #000000;">Departamentos Disponibles</h2><br><br>
        
            <div class="departamento">
                <% 
                Connection connection = null;
                try {
                    Context initialContext = new InitialContext();
                    DataSource dataSource = (DataSource) initialContext.lookup("Portafolio");
                    connection = dataSource.getConnection();
                    String consultaSQL = "SELECT ID_DEPARTAMENTO, DESCRIPCION_CABANIA FROM DEPARTAMENTO";
                    PreparedStatement pstmt = connection.prepareStatement(consultaSQL);
                    ResultSet departamentos = pstmt.executeQuery();

                    while (departamentos.next()) {
                %>
                    <div class="departamento">
                        <img src="https://images.pexels.com/photos/8782711/pexels-photo-8782711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1" alt="Departamento <%= departamentos.getString("ID_DEPARTAMENTO") %>">
                        <p>ID: <%= departamentos.getString("ID_DEPARTAMENTO") %></p>
                        <p>Descripción: <%= departamentos.getString("DESCRIPCION_CABANIA") %></p>
                        <div class="botones">
                            <button onclick="abrirReservaModal('<%= departamentos.getString("ID_DEPARTAMENTO") %>')">Reserva</button>
                        </div>
                    </div>
                <%
                    }
                } catch (SQLException e) {
                    out.println("Error al conectar a la base de datos: " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    // Cierra la conexión en un bloque finally
                    try {
                        if (connection != null) {
                            connection.close();
                        }
                    } catch (SQLException e) {
                        e.printStackTrace(); // Manejo de errores al cerrar la conexión
                    }
                }
                %>
            </div>
        </section>
    </main>

    <div id="reservaModal">
        <div class="modal-content">
            <span class="close" onclick="cerrarReservaModal()">&times;</span>
            <form id="reservaForm">
                <label for="rut">RUT:</label>
                <input type="text" id="rut" name="rut" required>

                <label for="correo">Correo:</label>
                <input type="email" id="correo" name="correo" required>

                <label for="telefono">Teléfono:</label>
                <input type="text" id="telefono" name="telefono" required>

                <label for="nombre">Nombre Completo:</label>
                <input type="text" id="nombre" name="nombre" required>

                <!-- Campo oculto para almacenar el ID del departamento -->
                <input type="hidden" id="idDepartamentoReservado" name="idDepartamentoReservado" value="">

                <!-- Campo de fecha de inicio de la reserva -->
                <label for="fechaInicio">Fecha de Inicio:</label>
                <input type="date" id="fechaInicio" name="fechaInicio" required>

                <!-- Campo de fecha de fin de la reserva -->
                <label for="fechaFin">Fecha de Fin:</label>
                <input type="date" id="fechaFin" name="fechaFin" required>

                <!-- Agregado campo oculto para almacenar el ID del departamento en el formulario modal -->
                <input type="hidden" id="idDepartamento" name="idDepartamento" value="">

                <label for="tipoReserva">Tipo de Reserva:</label>
                <select id="tipoReserva" name="tipoReserva" required>
                    <option value="individual">Individual</option>
                    <option value="duo">Duo</option>
                    <option value="familiar">Familiar</option>
                </select>
                
                <!-- Llama a la función envioDatos() al hacer clic en el botón "Enviar" -->
                <button type="button" onclick="envioDatos(document.getElementById('idDepartamentoReservado').value)">Enviar</button>
            </form>
        </div>
    </div>
</body>
</html>
