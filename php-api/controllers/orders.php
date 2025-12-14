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
        $id = $_GET['id'] ?? null;
        
        if ($action === 'byUser') {
            $user_id = $_GET['user_id'] ?? 0;
            try {
                $stmt = $db->prepare("
                    SELECT o.*, u.full_name as buyer_name, u.email as buyer_email
                    FROM orders o
                    LEFT JOIN users u ON o.user_id = u.id
                    WHERE o.user_id = ?
                    ORDER BY o.created_at DESC
                ");
                $stmt->execute([$user_id]);
                $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                // Get order items for each order
                foreach ($orders as &$order) {
                    $stmt = $db->prepare("
                        SELECT oi.*, p.name as product_name, p.image_url
                        FROM order_items oi
                        JOIN products p ON oi.product_id = p.id
                        WHERE oi.order_id = ?
                    ");
                    $stmt->execute([$order['id']]);
                    $order['items'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
                }
                
                echo json_encode([
                    'success' => true,
                    'orders' => array_map(function($o) {
                        return [
                            'id' => (int)$o['id'],
                            'user_id' => (int)$o['user_id'],
                            'total_amount' => (float)$o['total_amount'],
                            'delivery_date' => $o['delivery_date'],
                            'delivery_time' => $o['delivery_time'],
                            'delivery_address' => $o['delivery_address'],
                            'status' => $o['status'],
                            'buyer_name' => $o['buyer_name'],
                            'buyer_email' => $o['buyer_email'],
                            'created_at' => $o['created_at'],
                            'updated_at' => $o['updated_at'],
                            'items' => array_map(function($item) {
                                return [
                                    'id' => (int)$item['id'],
                                    'order_id' => (int)$item['order_id'],
                                    'product_id' => (int)$item['product_id'],
                                    'quantity' => (int)$item['quantity'],
                                    'price' => (float)$item['price'],
                                    'product_name' => $item['product_name'],
                                    'image_url' => $item['image_url'],
                                    'created_at' => $item['created_at']
                                ];
                            }, $o['items'] ?? [])
                        ];
                    }, $orders),
                    'count' => count($orders)
                ]);
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        } elseif ($action === 'bySeller') {
            $seller_id = $_GET['seller_id'] ?? 0;
            try {
                $stmt = $db->prepare("
                    SELECT DISTINCT o.*, u.full_name as buyer_name, u.email as buyer_email
                    FROM orders o
                    JOIN order_items oi ON o.id = oi.order_id
                    JOIN products p ON oi.product_id = p.id
                    LEFT JOIN users u ON o.user_id = u.id
                    WHERE p.seller_id = ?
                    ORDER BY o.created_at DESC
                ");
                $stmt->execute([$seller_id]);
                $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                foreach ($orders as &$order) {
                    $stmt = $db->prepare("
                        SELECT oi.*, p.name as product_name, p.image_url
                        FROM order_items oi
                        JOIN products p ON oi.product_id = p.id
                        WHERE oi.order_id = ? AND p.seller_id = ?
                    ");
                    $stmt->execute([$order['id'], $seller_id]);
                    $order['items'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
                }
                
                echo json_encode([
                    'success' => true,
                    'orders' => array_map(function($o) {
                        return [
                            'id' => (int)$o['id'],
                            'user_id' => (int)$o['user_id'],
                            'total_amount' => (float)$o['total_amount'],
                            'delivery_date' => $o['delivery_date'],
                            'delivery_time' => $o['delivery_time'],
                            'delivery_address' => $o['delivery_address'],
                            'status' => $o['status'],
                            'buyer_name' => $o['buyer_name'],
                            'buyer_email' => $o['buyer_email'],
                            'created_at' => $o['created_at'],
                            'updated_at' => $o['updated_at'],
                            'items' => array_map(function($item) {
                                return [
                                    'id' => (int)$item['id'],
                                    'order_id' => (int)$item['order_id'],
                                    'product_id' => (int)$item['product_id'],
                                    'quantity' => (int)$item['quantity'],
                                    'price' => (float)$item['price'],
                                    'product_name' => $item['product_name'],
                                    'image_url' => $item['image_url'],
                                    'created_at' => $item['created_at']
                                ];
                            }, $o['items'] ?? [])
                        ];
                    }, $orders),
                    'count' => count($orders)
                ]);
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        } elseif ($id) {
            try {
                $stmt = $db->prepare("
                    SELECT o.*, u.full_name as buyer_name, u.email as buyer_email
                    FROM orders o
                    LEFT JOIN users u ON o.user_id = u.id
                    WHERE o.id = ?
                ");
                $stmt->execute([$id]);
                $order = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$order) {
                    http_response_code(404);
                    echo json_encode(['success' => false, 'message' => 'Order not found']);
                    exit();
                }
                
                $stmt = $db->prepare("
                    SELECT oi.*, p.name as product_name, p.image_url
                    FROM order_items oi
                    JOIN products p ON oi.product_id = p.id
                    WHERE oi.order_id = ?
                ");
                $stmt->execute([$id]);
                $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                echo json_encode([
                    'success' => true,
                    'order' => [
                        'id' => (int)$order['id'],
                        'user_id' => (int)$order['user_id'],
                        'total_amount' => (float)$order['total_amount'],
                        'delivery_date' => $order['delivery_date'],
                        'delivery_time' => $order['delivery_time'],
                        'delivery_address' => $order['delivery_address'],
                        'status' => $order['status'],
                        'buyer_name' => $order['buyer_name'],
                        'buyer_email' => $order['buyer_email'],
                        'created_at' => $order['created_at'],
                        'updated_at' => $order['updated_at'],
                        'items' => array_map(function($item) {
                            return [
                                'id' => (int)$item['id'],
                                'order_id' => (int)$item['order_id'],
                                'product_id' => (int)$item['product_id'],
                                'quantity' => (int)$item['quantity'],
                                'price' => (float)$item['price'],
                                'product_name' => $item['product_name'],
                                'image_url' => $item['image_url'],
                                'created_at' => $item['created_at']
                            ];
                        }, $items)
                    ]
                ]);
            } catch(PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid request']);
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        $user_id = $data['user_id'] ?? 0;
        $delivery_date = $data['delivery_date'] ?? '';
        $delivery_time = $data['delivery_time'] ?? '';
        $delivery_address = $data['delivery_address'] ?? '';

        if (!$user_id || !$delivery_date || !$delivery_time || !$delivery_address) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit();
        }

        try {
            $db->beginTransaction();
            
            // Get cart items
            $stmt = $db->prepare("
                SELECT ci.*, p.price, p.stock_quantity
                FROM cart_items ci
                JOIN products p ON ci.product_id = p.id
                WHERE ci.user_id = ?
            ");
            $stmt->execute([$user_id]);
            $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            if (empty($cart_items)) {
                $db->rollBack();
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Cart is empty']);
                exit();
            }
            
            // Calculate total
            $total = 0;
            foreach ($cart_items as $item) {
                // Check stock
                if ($item['stock_quantity'] < $item['quantity']) {
                    $db->rollBack();
                    http_response_code(400);
                    echo json_encode(['success' => false, 'message' => 'Insufficient stock for product']);
                    exit();
                }
                $total += (float)$item['price'] * (int)$item['quantity'];
            }
            
            // Create order
            $stmt = $db->prepare("INSERT INTO orders (user_id, total_amount, delivery_date, delivery_time, delivery_address) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$user_id, $total, $delivery_date, $delivery_time, $delivery_address]);
            $order_id = $db->lastInsertId();
            
            // Create order items and update stock
            foreach ($cart_items as $item) {
                $stmt = $db->prepare("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)");
                $stmt->execute([$order_id, $item['product_id'], $item['quantity'], $item['price']]);
                
                // Update stock
                $stmt = $db->prepare("UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?");
                $stmt->execute([$item['quantity'], $item['product_id']]);
            }
            
            // Clear cart
            $stmt = $db->prepare("DELETE FROM cart_items WHERE user_id = ?");
            $stmt->execute([$user_id]);
            
            $db->commit();
            
            echo json_encode([
                'success' => true,
                'message' => 'Order created successfully',
                'order_id' => (int)$order_id,
                'total_amount' => $total
            ]);
        } catch(PDOException $e) {
            $db->rollBack();
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
        break;

    case 'PUT':
        if ($action === 'updateStatus') {
            $data = json_decode(file_get_contents('php://input'), true);
            $order_id = $data['order_id'] ?? 0;
            $status = $data['status'] ?? '';

            if (!$order_id || !in_array($status, ['pending', 'shipped', 'completed'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Invalid request']);
                exit();
            }

            try {
                $stmt = $db->prepare("UPDATE orders SET status = ? WHERE id = ?");
                $stmt->execute([$status, $order_id]);

                echo json_encode([
                    'success' => true,
                    'message' => 'Order status updated successfully',
                    'status' => $status
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

    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}
?>

