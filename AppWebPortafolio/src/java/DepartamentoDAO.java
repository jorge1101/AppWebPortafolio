/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author flame
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DepartamentoDAO {
    public static ResultSet obtenerDepartamentosDisponibles() {
        ResultSet resultSet = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            String url = "jdbc:oracle:thin:@localhost:1521:XE";
            String usuario = "Portafolio";
            String contraseña = "duoc";

            Connection con = DriverManager.getConnection(url, usuario, contraseña);
            Statement stmt = con.createStatement();
            String sql = "SELECT * FROM Departamento";
            resultSet = stmt.executeQuery(sql);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultSet;
    }
}