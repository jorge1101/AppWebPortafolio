<%@ page import="java.sql.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="ConnSrv.EliminarReservaServlet" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Detalles del Departamento</title>
</head>
<body>
    <h1>Detalles del Departamento</h1>

    <%-- Recuperar parámetros enviados desde la página anterior --%>
    <% 
        String rut = (String) request.getAttribute("rut");
        String idDepartamento = (String) request.getAttribute("idDepartamento");
        String fechaInicio = (String) request.getAttribute("fechaInicio");
        String fechaFin = (String) request.getAttribute("fechaFin");
        String tipoReserva = (String) request.getAttribute("tipoReserva");

        // Variables para almacenar los detalles del departamento
        String descripcion = "";

        // Realiza la consulta para obtener los detalles del departamento
        try {
            Context initialContext = new InitialContext();
            DataSource dataSource = (DataSource) initialContext.lookup("Portafolio");
            Connection connection = dataSource.getConnection();

            String consultaSQL = "SELECT DESCRIPCION_CABANIA FROM DEPARTAMENTO WHERE ID_DEPARTAMENTO = ?";
            try (PreparedStatement pstmt = connection.prepareStatement(consultaSQL)) {
                pstmt.setString(1, idDepartamento);
                ResultSet resultSet = pstmt.executeQuery();

                if (resultSet.next()) {
                    // Obtiene los detalles del resultado
                    descripcion = resultSet.getString("DESCRIPCION_CABANIA");
                    // Asigna más detalles según sea necesario
                }
            }
        } catch (SQLException | javax.naming.NamingException e) {
            out.println("Error al conectar a la base de datos: " + e.getMessage());
            e.printStackTrace();
        }
    %>
    

    <!-- Muestra los detalles de la última reserva -->
    <%
    try {
        // Obtiene la conexión a la base de datos desde el pool
        Context initialContext = new InitialContext();
        DataSource dataSource = (DataSource) initialContext.lookup("Portafolio");
        Connection connection = dataSource.getConnection();

        // Prepara la consulta SQL para obtener la última reserva
        String obtenerUltimaReservaSQL = "SELECT * FROM RESERVA WHERE id_reserva = (SELECT MAX(id_reserva) FROM RESERVA)";
        
        try (PreparedStatement pstmtUltimaReserva = connection.prepareStatement(obtenerUltimaReservaSQL)) {
            ResultSet resultSet = pstmtUltimaReserva.executeQuery();

            if (resultSet.next()) {
                // Obtén los detalles de la última reserva
                int idReserva = resultSet.getInt("id_reserva");
                Date fechaInicioReserva = resultSet.getDate("fec_ini");
                Date fechaFinReserva = resultSet.getDate("fec_ter");
                String rutCliente = resultSet.getString("rut_cliente");
                int estadoReserva = resultSet.getInt("estado_reserva");
                String tipoReservaBD = resultSet.getString("tipo_reserva");
                int valorReserva = resultSet.getInt("valor_reserva");

                // Calcula la duración de la reserva en días
                long diffInMillies = Math.abs(fechaFinReserva.getTime() - fechaInicioReserva.getTime());
                long diffInDays = TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);

                // Calcula el monto total a pagar
                int montoTotal = valorReserva * ((int) diffInDays + 1);

                // Convierte las fechas a formato de cadena si es necesario
                DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
                String fechaInicioStr = dateFormat.format(fechaInicioReserva);
                String fechaFinStr = dateFormat.format(fechaFinReserva);
            %>

            <p><strong>ID de Reserva:</strong> <%= idReserva %></p>
            <p><strong>Fecha de Inicio :</strong> <%= fechaInicioStr %></p>
            <p><strong>Fecha de Fin:</strong> <%= fechaFinStr %></p>
            <p><strong>RUT del Cliente :</strong> <%= rutCliente %></p>
            <p><strong>Tipo de la reserva:</strong> <%= tipoReservaBD %></p>
            <p><strong>Monto Total a Pagar:</strong> <%= montoTotal %></p>

            <!-- Declarar la variable montoTotal antes de usarla en JavaScript -->
            <script>
                var montoTotal = <%= montoTotal %>;
            </script>

            <%
            } else {
                // No se encontraron reservas
                out.println("No hay reservas en la base de datos.");
            }
        }
    } catch (SQLException | javax.naming.NamingException e) {
        out.println("Error al conectar a la base de datos: " + e.getMessage());
        e.printStackTrace();
    }
    %>

    <!-- Agregar botones de pago y cancelar reserva -->
    <button onclick="realizarPago()">Pagar</button>
    <button onclick="eliminarReserva()">Eliminar Reserva</button>


    <script>
    function eliminarReserva() {
        // Realizar una solicitud AJAX al servlet para eliminar la última reserva
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "EliminarUltimaReservaServlet", true);
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                // Recargar la página después de eliminar la reserva
                location.reload();
            }
        };

        // Enviar la solicitud
        xhr.send();
    }
</script>
    
    <!-- Agregar script para las funciones realizarPago() y cancelarReserva() -->
    <script>
        // Obtener los valores de rut e idDepartamento al cargar la página
        var rut = '<%= rut %>';
        var idDepartamento = '<%= idDepartamento %>';

        // Mostrar los valores en los elementos span correspondientes

        function realizarPago() {
            var paypalSandboxURL = "https://www.sandbox.paypal.com/cgi-bin/webscr";
            var cmd = "_xclick";
            var currencyCode = "USD";
            var businessEmail = "sb-0y1o625593570@business.example.com"; // Reemplaza con tu dirección de correo de PayPal
            var amount = (montoTotal / 2).toFixed(2); // Reemplazar con el monto a cobrar
            var itemDescription = "Arriendo";
            var paypalFormURL = paypalSandboxURL + "?cmd=" + cmd + "&business=" + businessEmail
                    + "&currency_code=" + currencyCode + "&amount=" + amount + "&item_name=" + itemDescription;
            // console.log("Amount: " + amount);
            // console.log("PayPal Form URL: " + paypalFormURL);
            window.location.href = paypalFormURL;
        }

        function abrirReservaModal() {
            var modal = document.getElementById('reservaModal');
            modal.style.display = 'flex';
        }

        function cerrarReservaModal() {
            var modal = document.getElementById('reservaModal');
            modal.style.display = 'none';
        }

        function cancelarReserva() {
            // Puedes utilizar la variable idDepartamento aquí según sea necesario
            alert("Reserva cancelada para el departamento con ID: " + idDepartamento);
        }
    </script>
</body>
</html>
