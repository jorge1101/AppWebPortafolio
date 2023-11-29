/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package ConnSrv;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;
import javax.naming.Context;
import javax.naming.InitialContext;
@WebServlet("/GuardarClienteServlet")
public class GuardarClienteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Obtén los parámetros del formulario
        String rut = request.getParameter("rut");
        String correo = request.getParameter("correo");
        String telefono = request.getParameter("telefono");
        String nombre = request.getParameter("nombre");
        
        // Obtén la ID del departamento desde los parámetros de la solicitud
        String idDepartamentoReservado = request.getParameter("idDepartamento");

        // Configura la respuesta del servlet
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Obtiene la conexión a la base de datos desde el pool
            Context initialContext = new InitialContext();
            DataSource dataSource = (DataSource) initialContext.lookup("Portafolio");
            Connection connection = dataSource.getConnection();

            // Prepara la consulta SQL para la inserción del cliente
            String consultaSQLCliente = "INSERT INTO cliente (rut_cliente, correo, telefono_cliente, nombre_cliente) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pstmtCliente = connection.prepareStatement(consultaSQLCliente)) {
                // Establece los parámetros en la consulta SQL
                pstmtCliente.setString(1, rut);
                pstmtCliente.setString(2, correo);
                pstmtCliente.setString(3, telefono);
                pstmtCliente.setString(4, nombre);

                // Ejecuta la inserción del cliente
                int filasAfectadasCliente = pstmtCliente.executeUpdate();

                // Verifica si se realizaron cambios en la base de datos (tabla cliente)
                if (filasAfectadasCliente <= 0) {
                    throw new SQLException("No se pudo realizar la inserción en la tabla CLIENTE.");
                }
            }

            // Prepara la consulta SQL para actualizar el departamento con la ID del cliente
            String updateDepartamentoSQL = "UPDATE DEPARTAMENTO SET RUT_CLIENTE = ? WHERE ID_DEPARTAMENTO = ?";
            try (PreparedStatement pstmtDepartamento = connection.prepareStatement(updateDepartamentoSQL)) {
                // Establece los parámetros en la consulta SQL
                pstmtDepartamento.setString(1, rut);
                pstmtDepartamento.setString(2, idDepartamentoReservado);

                // Ejecuta la actualización en la tabla DEPARTAMENTO
                int filasAfectadasDepartamento = pstmtDepartamento.executeUpdate();

                // Verifica si se realizaron cambios en la base de datos (tabla DEPARTAMENTO)
                if (filasAfectadasDepartamento <= 0) {
                    throw new SQLException("No se pudo realizar la actualización en la tabla DEPARTAMENTO.");
                }
            }

            
            // Prepara la consulta SQL para obtener el próximo ID de reserva
            String obtenerNuevoIdReservaSQL = "SELECT MAX(id_reserva) + 1 AS nuevoId FROM RESERVA";
            int nuevoIdReserva;
            try (PreparedStatement pstmtNuevoIdReserva = connection.prepareStatement(obtenerNuevoIdReservaSQL)) {
                ResultSet resultSet = pstmtNuevoIdReserva.executeQuery();
                resultSet.next();
                nuevoIdReserva = resultSet.getInt("nuevoId");
            }

            // Prepara la consulta SQL para la inserción en la tabla RESERVA
String insertReservaSQL = "INSERT INTO RESERVA (id_reserva, fec_ini, fec_ter, rut_cliente, estado_reserva, tipo_reserva) VALUES (?, ?, ?, ?, ?, ?)";
try (PreparedStatement pstmtReserva = connection.prepareStatement(insertReservaSQL)) {
    // Establece los parámetros en la consulta SQL
    pstmtReserva.setInt(1, nuevoIdReserva);
    pstmtReserva.setDate(2, java.sql.Date.valueOf(request.getParameter("fechaInicio")));
    pstmtReserva.setDate(3, java.sql.Date.valueOf(request.getParameter("fechaFin")));
    pstmtReserva.setString(4, rut);
    pstmtReserva.setInt(5, 1); // Estado_reserva: 1 (suponiendo que 1 representa el estado deseado)
    pstmtReserva.setString(6, request.getParameter("tipoReserva")); // Nueva línea para el tipo de reserva

    // Ejecuta la inserción en la tabla RESERVA
    int filasAfectadasReserva = pstmtReserva.executeUpdate();

    // Verifica si se realizaron cambios en la base de datos (tabla RESERVA)
    if (filasAfectadasReserva <= 0) {
        throw new SQLException("No se pudo realizar la inserción en la tabla RESERVA.");
    }
}

// Establece atributos de solicitud con los datos relevantes
request.setAttribute("rut", rut);
request.setAttribute("idDepartamento", idDepartamentoReservado);
request.setAttribute("fechaInicio", request.getParameter("fechaInicio"));
request.setAttribute("fechaFin", request.getParameter("fechaFin"));
request.setAttribute("tipoReserva", request.getParameter("tipoReserva"));

// Redirige a la página de detalles
request.getRequestDispatcher("Detalles.jsp").forward(request, response);

            // Envía la respuesta al cliente
            out.println("Inserción exitosa en la base de datos.");

        } catch (SQLException | javax.naming.NamingException e) {
            out.println("Error al conectar a la base de datos: " + e.getMessage());
            e.printStackTrace();
        }
    }
}