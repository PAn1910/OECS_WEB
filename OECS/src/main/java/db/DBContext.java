package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    private static final Logger LOGGER
            = Logger.getLogger(DBContext.class.getName());

    private static String requiredEnv(String name) {
        String value = System.getenv(name);

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException(
                    "Missing environment variable: " + name
            );
        }

        return value;
    }

    public DBContext() {
    }

    public Connection getConnection() {
        try {
            String url = requiredEnv("DB_URL");
            String user = requiredEnv("DB_USER");
            String password = requiredEnv("DB_PASSWORD");

            Class.forName(
                    "com.microsoft.sqlserver.jdbc.SQLServerDriver"
            );

            return DriverManager.getConnection(
                    url, user, password
            );

        } catch (ClassNotFoundException | SQLException ex) {
            LOGGER.log(
                    Level.SEVERE,
                    "Database connection failed",
                    ex
            );

            throw new IllegalStateException(
                    "Cannot connect to database", ex
            );
        }
    }
}
