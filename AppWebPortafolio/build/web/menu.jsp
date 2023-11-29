<!-- menu.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        nav {
            background-color: #333;
            overflow: hidden;
        }

        nav ul {
            list-style-type: none;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        nav li {
            float: left;
        }

        nav a {
            display: block;
            color: white;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }

        nav a:hover {
            background-color: #ddd;
            color: black;
        }
    </style>
</head>
<body>
    <nav>
        <ul>
            <li><a href="http://localhost:8080/AppWebPortafolio/#">Inicio</a></li>
            <li><a href="http://localhost:8080/AppWebPortafolio/departamentos.jsp">Departamentos Disponibles</a></li>
            <!-- Puedes agregar más elementos del menú según sea necesario -->
        </ul>
    </nav>
</body>
</html>