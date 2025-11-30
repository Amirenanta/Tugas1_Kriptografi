<?php

// Set headers untuk API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

// DATABASE CONFIGURATION
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');  // Kosongkan jika tidak ada password
define('DB_NAME', 'asset_management');
define('ENCRYPTION_KEY', 'AssetSecureKey2024');

// DATABASE CONNECTION FUNCTION
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        $conn = new PDO($dsn, DB_USER, DB_PASS, $options);
        return $conn;
    } catch(PDOException $e) {
        sendResponse(500, false, 'Database connection failed: ' . $e->getMessage());
        exit;
    }
}

// ENCRYPTION FUNCTIONS - Stream XOR

/**
 * Enkripsi data menggunakan Stream XOR
 * @param string $data Data yang akan dienkripsi
 * @param string $key Encryption key
 * @return string Data terenkripsi dalam base64
 */
function xorEncrypt($data, $key = ENCRYPTION_KEY) {
    if (empty($data)) return '';
    
    $result = '';
    $keyLength = strlen($key);
    $dataLength = strlen($data);
    
    for ($i = 0; $i < $dataLength; $i++) {
        $result .= chr(ord($data[$i]) ^ ord($key[$i % $keyLength]));
    }
    
    return base64_encode($result);
}

/**
 * Dekripsi data menggunakan Stream XOR
 * @param string $encrypted Data terenkripsi (base64)
 * @param string $key Encryption key
 * @return string Data terdekripsi
 */
function xorDecrypt($encrypted, $key = ENCRYPTION_KEY) {
    if (empty($encrypted)) return '';
    
    try {
        $decoded = base64_decode($encrypted);
        if ($decoded === false) return $encrypted;
        
        $result = '';
        $keyLength = strlen($key);
        $decodedLength = strlen($decoded);
        
        for ($i = 0; $i < $decodedLength; $i++) {
            $result .= chr(ord($decoded[$i]) ^ ord($key[$i % $keyLength]));
        }
        
        return $result;
    } catch (Exception $e) {
        return $encrypted;
    }
}

/**
 * Enkripsi field sensitif pada asset
 * @param array $asset Data asset
 * @return array Asset dengan field terenkripsi
 */
function encryptAssetFields($asset) {
    $sensitiveFields = ['asset_name', 'location', 'price', 'specifications', 'serial_number'];
    
    foreach ($sensitiveFields as $field) {
        if (isset($asset[$field]) && !empty($asset[$field])) {
            $asset[$field] = xorEncrypt($asset[$field]);
        }
    }
    
    return $asset;
}

/**
 * Dekripsi field sensitif pada asset
 * @param array $asset Data asset terenkripsi
 * @return array Asset dengan field terdekripsi
 */
function decryptAssetFields($asset) {
    $sensitiveFields = ['asset_name', 'location', 'price', 'specifications', 'serial_number'];
    
    foreach ($sensitiveFields as $field) {
        if (isset($asset[$field]) && !empty($asset[$field])) {
            $asset[$field] = xorDecrypt($asset[$field]);
        }
    }
    
    return $asset;
}

/**
 * Send JSON response
 * @param int $statusCode HTTP status code
 * @param bool $success Success status
 * @param string $message Response message
 * @param mixed $data Additional data
 */
function sendResponse($statusCode, $success, $message, $data = null) {
    http_response_code($statusCode);
    
    $response = [
        'success' => $success,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    exit;
}

/**
 * Get request data from JSON body
 * @return array Request data
 */
function getRequestData() {
    $rawData = file_get_contents('php://input');
    $data = json_decode($rawData, true);
    return $data ? $data : [];
}

/**
 * Validate login credentials
 * @param string $username Username
 * @param string $password Password
 * @return array|false User data or false
 */
function validateLogin($username, $password) {
    $validUsers = [
        'admin' => [
            'password' => 'admin123',
            'role' => 'Administrator',
            'full_name' => 'Administrator'
        ],
        'user' => [
            'password' => 'user123',
            'role' => 'User',
            'full_name' => 'Regular User'
        ]
    ];
    
    if (isset($validUsers[$username]) && $validUsers[$username]['password'] === $password) {
        return [
            'username' => $username,
            'role' => $validUsers[$username]['role'],
            'full_name' => $validUsers[$username]['full_name']
        ];
    }
    
    return false;
}

/**
 * Log asset changes to history table
 */
function logAssetChange($conn, $assetId, $actionType, $oldData, $newData, $changedBy, $notes) {
    try {
        $sql = "INSERT INTO asset_history (asset_id, action_type, old_data, new_data, changed_by, notes) 
                VALUES (:asset_id, :action_type, :old_data, :new_data, :changed_by, :notes)";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':asset_id' => $assetId,
            ':action_type' => $actionType,
            ':old_data' => $oldData,
            ':new_data' => $newData,
            ':changed_by' => $changedBy,
            ':notes' => $notes
        ]);
    } catch (Exception $e) {
        // Log error 
        error_log('Failed to log asset change: ' . $e->getMessage());
    }
}

// API ROUTING

$method = $_SERVER['REQUEST_METHOD'];
$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : '';

// Route to appropriate handler
switch ($endpoint) {
    case 'login':
        handleLogin();
        break;
    
    case 'assets':
        handleAssetsEndpoint($method);
        break;
    
    case 'asset':
        handleAssetEndpoint($method);
        break;
    
    case 'statistics':
        handleStatistics();
        break;
    
    case 'history':
        handleHistory();
        break;
    
    case 'test':
        // Test endpoint to verify API is working
        sendResponse(200, true, 'API is working!', [
            'version' => '1.0',
            'encryption' => 'Stream XOR',
            'endpoints' => ['login', 'assets', 'asset', 'statistics', 'history']
        ]);
        break;
    
    default:
        sendResponse(404, false, 'Endpoint not found. Available endpoints: login, assets, asset, statistics, history');
}


/**
 * Handle login endpoint
 */
function handleLogin() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendResponse(405, false, 'Method not allowed. Use POST');
    }
    
    $data = getRequestData();
    
    if (!isset($data['username']) || !isset($data['password'])) {
        sendResponse(400, false, 'Username and password required');
    }
    
    $user = validateLogin($data['username'], $data['password']);
    
    if ($user) {
        $user['token'] = base64_encode($data['username'] . ':' . time());
        sendResponse(200, true, 'Login successful', $user);
    } else {
        sendResponse(401, false, 'Invalid username or password');
    }
}

/**
 * Handle assets endpoint
 */
function handleAssetsEndpoint($method) {
    switch ($method) {
        case 'GET':
            getAllAssets();
            break;
        case 'POST':
            createAsset();
            break;
        case 'PUT':
            updateAsset();
            break;
        case 'DELETE':
            deleteAsset();
            break;
        default:
            sendResponse(405, false, 'Method not allowed');
    }
}

/**
 * Handle single asset endpoint
 */
function handleAssetEndpoint($method) {
    if ($method !== 'GET') {
        sendResponse(405, false, 'Method not allowed. Use GET');
    }
    getAssetById();
}

/**
 * GET - Retrieve all assets
 */
function getAllAssets() {
    try {
        $conn = getDBConnection();
        
        $sql = "SELECT * FROM assets ORDER BY created_at DESC";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        
        $assets = $stmt->fetchAll();
        
        // Decrypt each asset
        $decryptedAssets = array_map('decryptAssetFields', $assets);
        
        sendResponse(200, true, 'Assets retrieved successfully', [
            'count' => count($decryptedAssets),
            'assets' => $decryptedAssets
        ]);
    } catch (Exception $e) {
        sendResponse(500, false, 'Error retrieving assets: ' . $e->getMessage());
    }
}

/**
 * GET - Retrieve single asset by ID
 */
function getAssetById() {
    try {
        $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
        
        if ($id <= 0) {
            sendResponse(400, false, 'Valid asset ID required');
        }
        
        $conn = getDBConnection();
        
        $sql = "SELECT * FROM assets WHERE id = :id";
        $stmt = $conn->prepare($sql);
        $stmt->execute([':id' => $id]);
        
        $asset = $stmt->fetch();
        
        if ($asset) {
            $decryptedAsset = decryptAssetFields($asset);
            sendResponse(200, true, 'Asset retrieved successfully', $decryptedAsset);
        } else {
            sendResponse(404, false, 'Asset not found');
        }
    } catch (Exception $e) {
        sendResponse(500, false, 'Error retrieving asset: ' . $e->getMessage());
    }
}

/**
 * POST - Create new asset
 */
function createAsset() {
    try {
        $data = getRequestData();
        
        // Validate required fields
        $requiredFields = ['asset_code', 'asset_name', 'category', 'location', 'status', 'purchase_date', 'price'];
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                sendResponse(400, false, "Field '$field' is required");
            }
        }
        
        $conn = getDBConnection();
        
        // Encrypt sensitive data
        $encryptedData = encryptAssetFields($data);
        
        $sql = "INSERT INTO assets 
                (asset_code, asset_name, category, location, status, purchase_date, price, specifications, serial_number, created_by) 
                VALUES 
                (:asset_code, :asset_name, :category, :location, :status, :purchase_date, :price, :specifications, :serial_number, :created_by)";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':asset_code' => $data['asset_code'],
            ':asset_name' => $encryptedData['asset_name'],
            ':category' => $data['category'],
            ':location' => $encryptedData['location'],
            ':status' => $data['status'],
            ':purchase_date' => $data['purchase_date'],
            ':price' => $encryptedData['price'],
            ':specifications' => isset($encryptedData['specifications']) ? $encryptedData['specifications'] : null,
            ':serial_number' => isset($encryptedData['serial_number']) ? $encryptedData['serial_number'] : null,
            ':created_by' => 1 // Default user ID
        ]);
        
        $newAssetId = $conn->lastInsertId();
        
        // Log history
        logAssetChange($conn, $newAssetId, 'CREATE', null, json_encode($data), 1, 'Asset created via API');
        
        sendResponse(201, true, 'Asset created successfully', ['id' => $newAssetId]);
    } catch (PDOException $e) {
        if ($e->getCode() == 23000) {
            sendResponse(409, false, 'Asset code already exists');
        } else {
            sendResponse(500, false, 'Error creating asset: ' . $e->getMessage());
        }
    }
}

/**
 * PUT - Update existing asset
 */
function updateAsset() {
    try {
        $data = getRequestData();
        
        if (!isset($data['id']) || empty($data['id'])) {
            sendResponse(400, false, 'Asset ID is required');
        }
        
        $conn = getDBConnection();
        
        // Get old data for history
        $oldDataStmt = $conn->prepare("SELECT * FROM assets WHERE id = :id");
        $oldDataStmt->execute([':id' => $data['id']]);
        $oldData = $oldDataStmt->fetch();
        
        if (!$oldData) {
            sendResponse(404, false, 'Asset not found');
        }
        
        // Encrypt sensitive data
        $encryptedData = encryptAssetFields($data);
        
        $sql = "UPDATE assets SET 
                asset_code = :asset_code,
                asset_name = :asset_name,
                category = :category,
                location = :location,
                status = :status,
                purchase_date = :purchase_date,
                price = :price,
                specifications = :specifications,
                serial_number = :serial_number
                WHERE id = :id";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':id' => $data['id'],
            ':asset_code' => $data['asset_code'],
            ':asset_name' => $encryptedData['asset_name'],
            ':category' => $data['category'],
            ':location' => $encryptedData['location'],
            ':status' => $data['status'],
            ':purchase_date' => $data['purchase_date'],
            ':price' => $encryptedData['price'],
            ':specifications' => isset($encryptedData['specifications']) ? $encryptedData['specifications'] : null,
            ':serial_number' => isset($encryptedData['serial_number']) ? $encryptedData['serial_number'] : null
        ]);
        
        // Log history
        logAssetChange($conn, $data['id'], 'UPDATE', json_encode($oldData), json_encode($data), 1, 'Asset updated via API');
        
        sendResponse(200, true, 'Asset updated successfully');
    } catch (Exception $e) {
        sendResponse(500, false, 'Error updating asset: ' . $e->getMessage());
    }
}

/**
 * DELETE - Delete asset
 */
function deleteAsset() {
    try {
        $data = getRequestData();
        
        if (!isset($data['id']) || empty($data['id'])) {
            sendResponse(400, false, 'Asset ID is required');
        }
        
        $conn = getDBConnection();
        
        // Get asset data before deletion for history
        $stmt = $conn->prepare("SELECT * FROM assets WHERE id = :id");
        $stmt->execute([':id' => $data['id']]);
        $assetData = $stmt->fetch();
        
        if (!$assetData) {
            sendResponse(404, false, 'Asset not found');
        }
        
        // Log history before deletion
        logAssetChange($conn, $data['id'], 'DELETE', json_encode($assetData), null, 1, 'Asset deleted via API');
        
        // Delete asset
        $deleteStmt = $conn->prepare("DELETE FROM assets WHERE id = :id");
        $deleteStmt->execute([':id' => $data['id']]);
        
        sendResponse(200, true, 'Asset deleted successfully');
    } catch (Exception $e) {
        sendResponse(500, false, 'Error deleting asset: ' . $e->getMessage());
    }
}

/**
 * GET - Retrieve statistics
 */
function handleStatistics() {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        sendResponse(405, false, 'Method not allowed. Use GET');
    }
    
    try {
        $conn = getDBConnection();
        
        $sql = "SELECT 
                COUNT(*) as total_assets,
                SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) as active_assets,
                SUM(CASE WHEN status = 'Maintenance' THEN 1 ELSE 0 END) as maintenance_assets,
                SUM(CASE WHEN status = 'Retired' THEN 1 ELSE 0 END) as retired_assets,
                SUM(CASE WHEN status = 'Disposed' THEN 1 ELSE 0 END) as disposed_assets,
                COUNT(DISTINCT category) as total_categories
                FROM assets";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        
        $stats = $stmt->fetch();
        
        sendResponse(200, true, 'Statistics retrieved successfully', $stats);
    } catch (Exception $e) {
        sendResponse(500, false, 'Error retrieving statistics: ' . $e->getMessage());
    }
}

/**
 * GET - Retrieve asset history
 */
function handleHistory() {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        sendResponse(405, false, 'Method not allowed. Use GET');
    }
    
    try {
        $assetId = isset($_GET['asset_id']) ? intval($_GET['asset_id']) : 0;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 50;
        
        $conn = getDBConnection();
        
        if ($assetId > 0) {
            $sql = "SELECT ah.*, a.asset_code, a.asset_name, u.username as changed_by_user
                    FROM asset_history ah
                    LEFT JOIN assets a ON ah.asset_id = a.id
                    LEFT JOIN users u ON ah.changed_by = u.id
                    WHERE ah.asset_id = :asset_id
                    ORDER BY ah.changed_at DESC
                    LIMIT :limit";
            
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':asset_id', $assetId, PDO::PARAM_INT);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        } else {
            $sql = "SELECT ah.*, a.asset_code, a.asset_name, u.username as changed_by_user
                    FROM asset_history ah
                    LEFT JOIN assets a ON ah.asset_id = a.id
                    LEFT JOIN users u ON ah.changed_by = u.id
                    ORDER BY ah.changed_at DESC
                    LIMIT :limit";
            
            $stmt = $conn->prepare($sql);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        }
        
        $stmt->execute();
        $history = $stmt->fetchAll();
        
        sendResponse(200, true, 'History retrieved successfully', [
            'count' => count($history),
            'history' => $history
        ]);
    } catch (Exception $e) {
        sendResponse(500, false, 'Error retrieving history: ' . $e->getMessage());
    }
}
?>