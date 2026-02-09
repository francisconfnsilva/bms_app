#!/usr/bin/python3
print("Content-type: text/html\n")
print("""
<html>
<head>
    <title>Boating Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 50px auto;
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            border-bottom: 3px solid #3498db;
            padding-bottom: 15px;
            margin-bottom: 30px;
        }
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 30px;
        }
        .menu-item {
            background-color: #f9f9f9;
            border: 2px solid #ddd;
            border-radius: 8px;
            padding: 25px;
            text-align: center;
            text-decoration: none;
            color: #2c3e50;
            transition: all 0.2s;
        }
        .menu-item:hover {
            border-color: #3498db;
            background-color: #e3f2fd;
            transform: translateY(-2px);
        }
        .menu-item h2 {
            margin: 0;
            font-size: 20px;
            color: #3498db;
        }
        .menu-item p {
            margin: 10px 0 0 0;
            font-size: 14px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Boating Management System</h1>
    <div class="menu-grid">
        <a href='sailors.cgi' class="menu-item">
            <h2>Sailors</h2>
            <p>Manage Sailors</p>
        </a>
        <a href='reservations.cgi' class="menu-item">
            <h2>Reservations</h2>
            <p>Manage Reservations</p>
        </a>
        <a href='authorized.cgi' class="menu-item">
            <h2>Authorized Sailors</h2>
            <p>Authorize Sailors</p>
        </a>
        <a href='trips.cgi' class="menu-item">
            <h2>Trips</h2>
            <p>Register and Manage Trips</p>
        </a>
    </div>
</div>
</body>
</html>
""")