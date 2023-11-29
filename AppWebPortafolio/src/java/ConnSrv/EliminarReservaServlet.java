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
import java.sql.SQLException;
import javax.sql.DataSource;
import javax.naming.Context;
import javax.naming.InitialContext;

@WebServlet("/EliminarUltimaReservaServlet")
public class EliminarReservaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Obtén el parámetro del formulario

        // Configura la respuesta del servlet
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Obtiene la conexión a la base de datos desde el pool
            Context initialContext = new InitialContext();
            DataSource dataSource = (DataSource) initialContext.lookup("Portafolio");
            Connection connection = dataSource.getConnection();

            // Prepara la consulta SQL para la actualización del estado de la reserva
            String updateReservaSQL = "DELETE FROM RESERVA WHERE id_reserva = (SELECT MAX(id_reserva) FROM RESERVA)";

            try (PreparedStatement pstmtReserva = connection.prepareStatement(updateReservaSQL)) {
                // Establece los parámetros en la consulta SQL


                // Ejecuta la actualización en la tabla de reservas
                int filasAfectadasReserva = pstmtReserva.executeUpdate();
                
                // Verifica si se realizaron cambios en la base de datos
                if (filasAfectadasReserva <= 0) {
                    throw new SQLException("No se pudo realizar la actualización en la tabla de reservas.");
                }
            }

            // Envía la respuesta al cliente
            out.println("Actualización de estado de reserva exitosa.");

        } catch (SQLException | javax.naming.NamingException e) {
            out.println("Error al conectar a la base de datos: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
