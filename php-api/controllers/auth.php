<?php
require_once '../config/database.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$action = $_GET['action'] ?? '';

$database = new Database();
$db = $database->getConnection();

switch ($action) {
    case 'register':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Method not allowed']);
            exit();
        }

        $data = json_decode(file_get_contents('php://input'), true);
        
        $firebase_uid = $data['firebase_uid'] ?? '';
        $email = $data['email'] ?? '';
        $full_name = $data['full_name'] ?? '';
        $role = $data['role'] ?? 'user';
        $phone = $data['phone'] ?? null;
        $address = $data['address'] ?? null;

        if (empty($firebase_uid) || empty($email) || empty($full_name)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit();
        }

        try {
            // Check if user already exists
            $check = $db->prepare("SELECT id FROM users WHERE firebase_uid = ? OR email = ?");
            $check->execute([$firebase_uid, $email]);
            if ($check->fetch()) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'User already exists']);
                exit();
            }

            $stmt = $db->prepare("INSERT INTO users (firebase_uid, email, role, full_name, phone, address) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->execute([$firebase_uid, $email, $role, $full_name, $phone, $address]);
            
            $user_id = $db->lastInsertId();
            
            $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
            $stmt->execute([$user_id]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'message' => 'User registered successfully',
                'user' => [
                    'id' => (int)$user['id'],
                    'firebase_uid' => $user['firebase_uid'],
                    'email' => $user['email'],
                    'role' => $user['role'],
                    'full_name' => $user['full_name'],
                    'phone' => $user['phone'],
                    'address' => $user['address'],
                    'created_at' => $user['created_at']
                ]
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'login':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Method not allowed']);
            exit();
        }

        $data = json_decode(file_get_contents('php://input'), true);
        $firebase_uid = $data['firebase_uid'] ?? '';

        if (empty($firebase_uid)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Firebase UID is required']);
            exit();
        }

        try {
            $stmt = $db->prepare("SELECT * FROM users WHERE firebase_uid = ?");
            $stmt->execute([$firebase_uid]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user) {
                http_response_code(404);
                echo json_encode(['success' => false, 'message' => 'User not found. Please register first.']);
                exit();
            }

            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'user' => [
                    'id' => (int)$user['id'],
                    'firebase_uid' => $user['firebase_uid'],
                    'email' => $user['email'],
                    'role' => $user['role'],
                    'full_name' => $user['full_name'],
                    'phone' => $user['phone'],
                    'address' => $user['address'],
                    'created_at' => $user['created_at']
                ]
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'getUser':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Method not allowed']);
            exit();
        }

        $firebase_uid = $_GET['firebase_uid'] ?? '';

        if (empty($firebase_uid)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Firebase UID is required']);
            exit();
        }

        try {
            $stmt = $db->prepare("SELECT * FROM users WHERE firebase_uid = ?");
            $stmt->execute([$firebase_uid]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user) {
                http_response_code(404);
                echo json_encode(['success' => false, 'message' => 'User not found']);
                exit();
            }

            echo json_encode([
                'success' => true,
                'user' => [
                    'id' => (int)$user['id'],
                    'firebase_uid' => $user['firebase_uid'],
                    'email' => $user['email'],
                    'role' => $user['role'],
                    'full_name' => $user['full_name'],
                    'phone' => $user['phone'],
                    'address' => $user['address'],
                    'created_at' => $user['created_at']
                ]
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        break;
}
?>

