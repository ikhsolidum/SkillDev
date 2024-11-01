<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Register endpoint hit");

// Get the requesting origin
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';

// List of allowed origins
$allowed_origins = array(
    'http://localhost:3000',
    'http://localhost',
    'http://localhost:56740', // Add your Flutter web port
    'capacitor://localhost',
    'http://localhost:8080',
    'http://127.0.0.1',
    'http://127.0.0.1:8080'
);

// Check if the origin is allowed
if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    header("Access-Control-Allow-Origin: *"); // Fallback to allow all origins
}

// Required CORS headers
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Max-Age: 3600");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

// Include database connection
require_once 'mobile-connect.php';

// Get posted data
$rawData = file_get_contents("php://input");
error_log("Received raw data: " . $rawData);

$data = json_decode($rawData);

// Initialize response array
$response = array('success' => false, 'message' => '', 'debug' => array());

// Log received data
error_log("Decoded data: " . print_r($data, true));

// Validation to Check for Incomplete Data
if (!isset($data) || !is_object($data)) {
    $response['message'] = 'Invalid JSON data received';
    $response['debug']['raw_data'] = $rawData;
    http_response_code(400);
} else if (
    empty($data->username) ||
    empty($data->email) ||
    empty($data->password) ||
    empty($data->id_proof) ||
    empty($data->proof_clearance) ||  // Fixed the syntax error here
    empty($data->profileImage)
) {
    $response['message'] = 'Incomplete data provided';
    $response['debug'] = [
        'username' => $data->username ?? null,
        'email' => $data->email ?? null,
        'password' => isset($data->password) ? 'provided' : null,
        'id_proof' => $data->id_proof ?? null,
        'proof_clearance' => $data->proof_clearance ?? null,
        'profileImage' => $data->profileImage ?? null
    ];
    http_response_code(400);
} else {
    // Create database connection
    $database = new Database();
    $db = $database->getConnection();

    if ($db) {
        try {
            // First check if email already exists
            $checkQuery = "SELECT COUNT(*) FROM users WHERE email = :email";
            $checkStmt = $db->prepare($checkQuery);
            $checkStmt->bindParam(':email', $data->email);
            $checkStmt->execute();
            
            if ($checkStmt->fetchColumn() > 0) {
                $response['message'] = 'Email already registered';
                $response['debug']['email'] = $data->email;
                http_response_code(409); // Conflict
            } else {
                // Prepare insert query
                $query = "INSERT INTO users (username, email, password, id_proof, proof_clearance, profileImage) 
                          VALUES (:username, :email, :password, :id_proof, :proof_clearance, :profileImage)";
                
                // Prepare statement
                $stmt = $db->prepare($query);

                // Sanitize and bind data
                $username = htmlspecialchars(strip_tags($data->username));
                $email = htmlspecialchars(strip_tags($data->email));
                $password = password_hash($data->password, PASSWORD_DEFAULT);
                $id_proof = htmlspecialchars(strip_tags($data->id_proof));
                $proof_clearance = htmlspecialchars(strip_tags($data->proof_clearance));
                $profileImage = htmlspecialchars(strip_tags($data->profileImage));

                $stmt->bindParam(':username', $username);
                $stmt->bindParam(':email', $email);
                $stmt->bindParam(':password', $password);
                $stmt->bindParam(':id_proof', $id_proof);
                $stmt->bindParam(':proof_clearance', $proof_clearance);
                $stmt->bindParam(':profileImage', $profileImage);

                if ($stmt->execute()) {
                    $response['success'] = true;
                    $response['message'] = 'User registered successfully';
                    http_response_code(201); // Created
                } else {
                    $response['message'] = 'Unable to register user';
                    $response['debug']['sql_error'] = $stmt->errorInfo();
                    http_response_code(500);
                }
            }
        } catch (PDOException $e) {
            $response['message'] = 'Database error: ' . $e->getMessage();
            $response['debug']['exception'] = $e->getMessage();
            error_log("Database error: " . $e->getMessage());
            http_response_code(500);
        }
    } else {
        $response['message'] = 'Unable to connect to database';
        $response['debug']['connection'] = 'Database connection failed';
        http_response_code(500);
    }
}

// Send response
echo json_encode($response);
error_log("Response sent: " . json_encode($response));