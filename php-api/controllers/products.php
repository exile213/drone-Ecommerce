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

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        if ($action === 'bySeller') {
            $seller_id = $_GET['seller_id'] ?? 0;
            try {
                $stmt = $db->prepare("
                    SELECT p.*, u.full_name as seller_name, u.email as seller_email 
                    FROM products p 
                    LEFT JOIN users u ON p.seller_id = u.id 
                    WHERE p.seller_id = ? 
                    ORDER BY p.created_at DESC
                ");
                $stmt->execute([$seller_id]);
                $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                echo json_encode([
                    'success' => true,
                    'products' => array_map(function($p) {
                        return [
                            'id' => (int)$p['id'],
                            'seller_id' => (int)$p['seller_id'],
                            'name' => $p['name'],
                            'description' => $p['description'],
                            'price' => (float)$p['price'],
                            'stock_quantity' => (int)$p['stock_quantity'],
                            'category' => $p['category'],
                            'image_url' => $p['image_url'],
                            'seller_name' => $p['seller_name'],
                            'seller_email' => $p['seller_email'],
                            'created_at' => $p['created_at'],
                            'updated_at' => $p['updated_at']
                        ];
                    }, $products),
                    'count' => count($products)
                ]);
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        } else {
            $id = $_GET['id'] ?? null;
            $category = $_GET['category'] ?? null;
            $search = $_GET['search'] ?? null;
            
            try {
                $sql = "SELECT p.*, u.full_name as seller_name, u.email as seller_email FROM products p LEFT JOIN users u ON p.seller_id = u.id WHERE 1=1";
                $params = [];
                
                if ($id) {
                    $sql .= " AND p.id = ?";
                    $params[] = $id;
                }
                if ($category) {
                    $sql .= " AND p.category = ?";
                    $params[] = $category;
                }
                if ($search) {
                    $sql .= " AND (p.name LIKE ? OR p.description LIKE ?)";
                    $searchTerm = "%$search%";
                    $params[] = $searchTerm;
                    $params[] = $searchTerm;
                }
                
                $sql .= " ORDER BY p.created_at DESC";
                
                $stmt = $db->prepare($sql);
                $stmt->execute($params);
                $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if ($id && count($products) > 0) {
                    $p = $products[0];
                    echo json_encode([
                        'success' => true,
                        'product' => [
                            'id' => (int)$p['id'],
                            'seller_id' => (int)$p['seller_id'],
                            'name' => $p['name'],
                            'description' => $p['description'],
                            'price' => (float)$p['price'],
                            'stock_quantity' => (int)$p['stock_quantity'],
                            'category' => $p['category'],
                            'image_url' => $p['image_url'],
                            'seller_name' => $p['seller_name'],
                            'seller_email' => $p['seller_email'],
                            'created_at' => $p['created_at'],
                            'updated_at' => $p['updated_at']
                        ]
                    ]);
                } else {
                    echo json_encode([
                        'success' => true,
                        'products' => array_map(function($p) {
                            return [
                                'id' => (int)$p['id'],
                                'seller_id' => (int)$p['seller_id'],
                                'name' => $p['name'],
                                'description' => $p['description'],
                                'price' => (float)$p['price'],
                                'stock_quantity' => (int)$p['stock_quantity'],
                                'category' => $p['category'],
                                'image_url' => $p['image_url'],
                                'seller_name' => $p['seller_name'],
                                'seller_email' => $p['seller_email'],
                                'created_at' => $p['created_at'],
                                'updated_at' => $p['updated_at']
                            ];
                        }, $products),
                        'count' => count($products)
                    ]);
                }
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        $seller_id = $data['seller_id'] ?? 0;
        $name = $data['name'] ?? '';
        $description = $data['description'] ?? null;
        $price = $data['price'] ?? 0;
        $stock_quantity = $data['stock_quantity'] ?? 0;
        $category = $data['category'] ?? '';
        $image_url = $data['image_url'] ?? null;

        if (empty($name) || empty($category) || $price <= 0) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit();
        }

        try {
            $stmt = $db->prepare("INSERT INTO products (seller_id, name, description, price, stock_quantity, category, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$seller_id, $name, $description, $price, $stock_quantity, $category, $image_url]);
            
            $product_id = $db->lastInsertId();
            echo json_encode([
                'success' => true,
                'message' => 'Product created successfully',
                'product_id' => (int)$product_id
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'] ?? 0;

        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Product ID is required']);
            exit();
        }

        try {
            $updates = [];
            $params = [];

            if (isset($data['name'])) {
                $updates[] = "name = ?";
                $params[] = $data['name'];
            }
            if (isset($data['description'])) {
                $updates[] = "description = ?";
                $params[] = $data['description'];
            }
            if (isset($data['price'])) {
                $updates[] = "price = ?";
                $params[] = $data['price'];
            }
            if (isset($data['stock_quantity'])) {
                $updates[] = "stock_quantity = ?";
                $params[] = $data['stock_quantity'];
            }
            if (isset($data['category'])) {
                $updates[] = "category = ?";
                $params[] = $data['category'];
            }
            if (isset($data['image_url'])) {
                $updates[] = "image_url = ?";
                $params[] = $data['image_url'];
            }

            if (empty($updates)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'No fields to update']);
                exit();
            }

            $params[] = $id;
            $sql = "UPDATE products SET " . implode(', ', $updates) . " WHERE id = ?";
            $stmt = $db->prepare($sql);
            $stmt->execute($params);

            echo json_encode([
                'success' => true,
                'message' => 'Product updated successfully'
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? 0;

        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Product ID is required']);
            exit();
        }

        try {
            $stmt = $db->prepare("DELETE FROM products WHERE id = ?");
            $stmt->execute([$id]);

            echo json_encode([
                'success' => true,
                'message' => 'Product deleted successfully'
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}
?>

