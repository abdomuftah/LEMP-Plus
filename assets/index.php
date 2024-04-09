<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #121212;
            color: #ffffff;
        }
        .container {
            max-width: 800px;
            margin: auto;
            background-color: #212121;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(255, 255, 255, 0.1);
        }
        h1, h2 {
            color: #ffffff;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            font-size: 24px;
            margin-bottom: 10px;
            border-bottom: 2px solid #ffffff;
            padding-bottom: 5px;
        }
        .info p {
            margin: 5px 0;
        }
        .social-icons {
            margin-top: 20px;
        }
        .social-icons a {
            display: inline-block;
            margin-right: 10px;
            color: #ffffff;
            text-decoration: none;
            font-size: 20px;
        }
        .social-icons a:hover {
            color: #007bff;
        }
        .glances-button {
            background-color: #007bff;
            color: #ffffff;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
        }
        .glances-button:hover {
            background-color: #0056b3;
        }
        footer {
            margin-top: 20px;
            text-align: center;
            color: #999999;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Server Information</h1>

        <div class="section">
            <h2>Server Details</h2>
            <div class="info">
                <p><strong>Server Software:</strong> <?php echo $_SERVER['SERVER_SOFTWARE']; ?></p>
                <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
                <p><strong>Server Port:</strong> <?php echo $_SERVER['SERVER_PORT']; ?></p>
                <p><strong>Server Protocol:</strong> <?php echo $_SERVER['SERVER_PROTOCOL']; ?></p>
            </div>
        </div>

        <div class="section">
            <h2>System Resources</h2>
            <div class="info">
                <?php
                function formatBytes($bytes, $precision = 2) {
                    $units = array('B', 'KB', 'MB', 'GB', 'TB');
                    $bytes = max($bytes, 0);
                    $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
                    $pow = min($pow, count($units) - 1);
                    $bytes /= (1 << (10 * $pow));
                    return round($bytes, $precision) . ' ' . $units[$pow];
                }

                echo '<p><strong>Total Memory:</strong> ' . formatBytes(memory_get_usage(true)) . '</p>';
                echo '<p><strong>Free Memory:</strong> ' . formatBytes(memory_get_usage()) . '</p>';
                ?>
            </div>
        </div>

        <div class="section">
            <h2>PHP Settings</h2>
            <div class="info">
                <?php
                echo '<p><strong>PHP Version:</strong> ' . phpversion() . '</p>';
                echo '<p><strong>PHP Configuration File (php.ini) Path:</strong> ' . php_ini_loaded_file() . '</p>';
                ?>
            </div>
        </div>

        <div class="section">
            <h2>Connect with Me</h2>
            <div class="social-icons">
                <a href="https://twitter.com/ScarNaruto" target="_blank">Twitter</a>
                <a href="https://discord.snyt.xyz" target="_blank">Discord</a>
            </div>
        </div>
    </div>
    <footer>
        &copy; 2024 ScarNaruto. All rights reserved.
    </footer>
</body>
</html>
