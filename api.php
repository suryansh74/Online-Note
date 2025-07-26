<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');

// Database credentials
$host = "host_name";  // Replace with your actual host
$db   = "db_name";
$user = "user_name";      
$pass = "your_password";

$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    exit;
}

// ROUTING
$method = $_SERVER['REQUEST_METHOD'];

// CREATE (POST)
if ($method === 'POST') {
    $message = $_POST['message'] ?? '';
    if ($message) {
        $stmt = $pdo->prepare("INSERT INTO messages (content) VALUES (?)");
        $stmt->execute([$message]);
        echo json_encode(["status" => "success", "message" => "Saved"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Empty message"]);
    }
    exit;
}

// READ (GET)
// READ (GET)
if ($method === 'GET') {
    $search = $_GET['search'] ?? '';
    $limit  = isset($_GET['limit']) ? (int)$_GET['limit'] : 5; // Default: last 5
    $all    = isset($_GET['all']) ? (bool)$_GET['all'] : false;

    // Build base query
    $sql = "SELECT * FROM messages WHERE content LIKE ?";

    // Add ordering and limits
    if (!$all) {
        $sql .= " ORDER BY id DESC LIMIT $limit";
    } else {
        $sql .= " ORDER BY id DESC";
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute(["%$search%"]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($results);
    exit;
}


// UPDATE (PUT)
if ($method === 'PUT') {
    parse_str(file_get_contents("php://input"), $put_vars);
    $id = $put_vars['id'] ?? 0;
    $content = $put_vars['content'] ?? '';
    if ($id && $content) {
        $stmt = $pdo->prepare("UPDATE messages SET content=? WHERE id=?");
        $stmt->execute([$content, $id]);
        echo json_encode(["status" => "success", "message" => "Updated"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Missing ID or content"]);
    }
    exit;
}

// DELETE (DELETE)
if ($method === 'DELETE') {
    parse_str(file_get_contents("php://input"), $del_vars);
    $id = $del_vars['id'] ?? 0;
    if ($id) {
        $stmt = $pdo->prepare("DELETE FROM messages WHERE id=?");
        $stmt->execute([$id]);
        echo json_encode(["status" => "success", "message" => "Deleted"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Missing ID"]);
    }
    exit;
}

echo json_encode(["status" => "error", "message" => "Invalid Request"]);
?>
