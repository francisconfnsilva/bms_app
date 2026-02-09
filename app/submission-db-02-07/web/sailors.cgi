#!/usr/bin/python3
import cgi
import cgitb; cgitb.enable()
import html
from db import get_connection

print("Content-type: text/html\n")
print("""
<html>
<head>
    <title>Sailors Management</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background-color: #3498db; color: white; padding: 12px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f0f0f0; }
        .badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-junior { background-color: #e8f5e9; color: #2e7d32; }
        .badge-senior { background-color: #e3f2fd; color: #1565c0; }
        a.delete-link { color: #e74c3c; text-decoration: none; font-weight: bold; }
        a.delete-link:hover { text-decoration: underline; }
        .form-box { background-color: #f9f9f9; padding: 20px; border-radius: 5px; border: 1px solid #ddd; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; color: #555; font-weight: bold; }
        input[type="text"], input[type="email"] { width: 100%; max-width: 400px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
        input[type="submit"] { padding: 10px 20px; background-color: #27ae60; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold; }
        input[type="submit"]:hover { background-color: #229954; }
        input[type="radio"] { margin-right: 5px; }
        .message { padding: 12px; margin: 15px 0; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; color: #155724; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
    </style>
</head>
<body>
<div class="container">
    <a href='menu.cgi' class="back-link"> Back to Menu</a>
    <h1>Sailors Management</h1>
""")

form = cgi.FieldStorage()
action = form.getvalue('action')

conn = None
try:
    conn = get_connection()
    conn.autocommit = False  # ensure atomic transactions
    cur = conn.cursor()
    cur.execute("SET CONSTRAINTS ALL DEFERRED")

    # --- CREATE SAILOR ---
    if action == 'create':
        email = form.getvalue('email', '').strip()
        firstname = form.getvalue('firstname', '').strip()
        surname = form.getvalue('surname', '').strip()
        kind = form.getvalue('kind', '').strip().lower()  # must be 'junior' or 'senior'

        if not email or not firstname or not surname or kind not in ('junior', 'senior'):
            print("<p class='error'>Error: All fields are required and type must be Junior or Senior.</p>")
        else:
            # Insert into sailor
            cur.execute("INSERT INTO sailor(email, firstname, surname) VALUES (%s, %s, %s)",
                        (email, firstname, surname))
            # Insert into correct specialization
            if kind == 'junior':
                cur.execute("INSERT INTO junior(email) VALUES (%s)", (email,))
            else:
                cur.execute("INSERT INTO senior(email) VALUES (%s)", (email,))

            conn.commit()
            print("<p class='message'> Sailor created successfully.</p>")

    # --- DELETE SAILOR ---
    elif action == 'delete':
        email = form.getvalue('email', '').strip()
        if email:
            cur.execute("DELETE FROM junior WHERE email = %s", (email,))
            cur.execute("DELETE FROM senior WHERE email = %s", (email,))
            cur.execute("DELETE FROM sailor WHERE email = %s", (email,))
            conn.commit()
            print("<p class='message'> Sailor deleted successfully.</p>")

    # --- LIST SAILORS ---
    cur.execute("""
        SELECT s.email, s.firstname, s.surname,
               CASE
                 WHEN j.email IS NOT NULL THEN 'junior'
                 WHEN sn.email IS NOT NULL THEN 'senior'
                 ELSE 'unknown'
               END AS kind
        FROM sailor s
        LEFT JOIN junior j ON s.email = j.email
        LEFT JOIN senior sn ON s.email = sn.email
        ORDER BY s.email
    """)
    rows = cur.fetchall()

    print("<h2>Existing Sailors</h2>")
    if rows:
        print("<table>")
        print("<tr><th>Email</th><th>First Name</th><th>Surname</th><th>Type</th><th>Actions</th></tr>")
        for email, firstname, surname, kind in rows:
            badge_class = 'badge-junior' if kind == 'junior' else 'badge-senior'
            print("<tr>")
            print(f"<td>{html.escape(email)}</td>")
            print(f"<td>{html.escape(firstname)}</td>")
            print(f"<td>{html.escape(surname)}</td>")
            print(f"<td><span class='badge {badge_class}'>{html.escape(kind.upper())}</span></td>")
            print(f"<td><a href='sailors.cgi?action=delete&email={html.escape(email)}' class='delete-link'>Delete</a></td>")
            print("</tr>")

        print("</table>")
    else:
        print("<p>No sailors registered.</p>")

    # --- CREATE FORM ---
    print("<h2>Create New Sailor</h2>")
    print("<div class='form-box'>")
    print("<form method='post' action='sailors.cgi'>")
    print("<input type='hidden' name='action' value='create'/>")

    print("<div class='form-group'><label>Email:</label>")
    print("<input type='email' name='email' required/></div>")

    print("<div class='form-group'><label>First Name:</label>")
    print("<input type='text' name='firstname' required/></div>")

    print("<div class='form-group'><label>Surname:</label>")
    print("<input type='text' name='surname' required/></div>")

    print("<div class='form-group'><label>Type:</label>")
    print("<label><input type='radio' name='kind' value='junior' checked/> Junior</label>")
    print("<label><input type='radio' name='kind' value='senior'/> Senior</label></div>")

    print("<input type='submit' value='Create Sailor'/>")
    print("</form></div>")

    cur.close()
except Exception as error:
    if conn is not None:
        conn.rollback()
    print("<p class='error'>An error occurred:</p>")
    print(f"<pre>{error}</pre>")
finally:
    if conn is not None:
        conn.close()

print("</div></body></html>")