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
        if ($action === 'byUser') {
            $user_id = $_GET['user_id'] ?? 0;
            try {
                $stmt = $db->prepare("
                    SELECT ci.*, p.name, p.price, p.image_url, p.stock_quantity,
                           (ci.quantity * p.price) as item_total
                    FROM cart_items ci
                    JOIN products p ON ci.product_id = p.id
                    WHERE ci.user_id = ?
                    ORDER BY ci.created_at DESC
                ");
                $stmt->execute([$user_id]);
                $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                $total = 0;
                foreach ($items as $item) {
                    $total += (float)$item['item_total'];
                }
                
                echo json_encode([
                    'success' => true,
                    'cart_items' => array_map(function($item) {
                        return [
                            'id' => (int)$item['id'],
                            'user_id' => (int)$item['user_id'],
                            'product_id' => (int)$item['product_id'],
                            'quantity' => (int)$item['quantity'],
                            'productName' => $item['name'],
                            'price' => (float)$item['price'],
                            'image_url' => $item['image_url'],
                            'stock_quantity' => (int)$item['stock_quantity'],
                            'item_total' => (float)$item['item_total'],
                            'created_at' => $item['created_at']
                        ];
                    }, $items),
                    'total' => $total,
                    'count' => count($items)
                ]);
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        $user_id = $data['user_id'] ?? 0;
        $product_id = $data['product_id'] ?? 0;
        $quantity = $data['quantity'] ?? 1;

        if (!$user_id || !$product_id || $quantity <= 0) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit();
        }

        try {
            // Check if user is trying to add their own product
            $product_check = $db->prepare("SELECT seller_id FROM products WHERE id = ?");
            $product_check->execute([$product_id]);
            $product = $product_check->fetch(PDO::FETCH_ASSOC);
            
            if (!$product) {
                http_response_code(404);
                echo json_encode(['success' => false, 'message' => 'Product not found']);
                exit();
            }
            
            if ((int)$product['seller_id'] === (int)$user_id) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'You cannot add your own product to cart']);
                exit();
            }
            
            // Check if item already exists in cart
            $check = $db->prepare("SELECT id, quantity FROM cart_items WHERE user_id = ? AND product_id = ?");
            $check->execute([$user_id, $product_id]);
            $existing = $check->fetch(PDO::FETCH_ASSOC);

            if ($existing) {
                // Update quantity
                $new_quantity = (int)$existing['quantity'] + $quantity;
                $stmt = $db->prepare("UPDATE cart_items SET quantity = ? WHERE id = ?");
                $stmt->execute([$new_quantity, $existing['id']]);
                $cart_item_id = $existing['id'];
            } else {
                // Insert new item
                $stmt = $db->prepare("INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)");
                $stmt->execute([$user_id, $product_id, $quantity]);
                $cart_item_id = $db->lastInsertId();
            }

            echo json_encode([
                'success' => true,
                'message' => 'Item added to cart',
                'cart_item_id' => (int)$cart_item_id
            ]);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $data['id'] ?? 0;
        $quantity = $data['quantity'] ?? 0;

        if (!$id || $quantity <= 0) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit();
        }

        try {
            $stmt = $db->prepare("UPDATE cart_items SET quantity = ? WHERE id = ?");
            $stmt->execute([$quantity, $id]);

            echo json_encode([
                'success' => true,
                'message' => 'Cart item updated successfully'
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
            echo json_encode(['success' => false, 'message' => 'Cart item ID is required']);
            exit();
        }

        try {
            $stmt = $db->prepare("DELETE FROM cart_items WHERE id = ?");
            $stmt->execute([$id]);

            echo json_encode([
                'success' => true,
                'message' => 'Item removed from cart'
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

