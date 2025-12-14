<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

class Database {
    private $host = 'localhost';
    private $db_name = 'drone_ecommerce';
    private $username = 'root';
    private $password = ''; // Empty by default in Laragon
    private $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            // First try to connect without database to check if MySQL is running
            $test_conn = new PDO(
                "mysql:host=" . $this->host . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            
            // Check if database exists, create if not
            $check_db = $test_conn->prepare("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?");
            $check_db->execute([$this->db_name]);
            
            if (!$check_db->fetch()) {
                // Database doesn't exist, create it
                $test_conn->exec("CREATE DATABASE IF NOT EXISTS `" . $this->db_name . "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            }
            
            // Now connect to the database
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Database connection error: ' . $e->getMessage(),
                'hint' => 'Make sure MySQL is running in Laragon and database "drone_ecommerce" exists'
            ]);
            exit();
        }

        return $this->conn;
    }
}
?>

