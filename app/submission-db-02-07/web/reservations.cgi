#!/usr/bin/python3
import cgi
import cgitb; cgitb.enable()
from db import get_connection
import html

print("Content-type: text/html\n")
print("""
<html>
<head>
    <title>Reservations</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { text-decoration: underline; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background-color: #3498db; color: white; padding: 12px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f0f0f0; }
        .form-box { background-color: #f9f9f9; padding: 20px; border-radius: 5px; border: 1px solid #ddd; }
        label { display: block; margin: 10px 0 5px 0; color: #555; font-weight: bold; }
        input[type="date"], select { width: 100%; max-width: 400px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        input:focus, select:focus { outline: none; border-color: #3498db; }
        input[type="submit"], button { padding: 10px 20px; background-color: #27ae60; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 10px; }
        input[type="submit"]:hover, button:hover { background-color: #229954; }
        button.delete-btn { background-color: #e74c3c; padding: 6px 12px; font-size: 13px; margin: 0; }
        button.delete-btn:hover { background-color: #c0392b; }
        .message { padding: 12px; margin: 15px 0; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; color: #155724; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .inline-form { display: inline; }
    </style>
</head>
<body>
<div class="container">
    <a href='menu.cgi' class="back-link"> Back to Menu</a>
    <h1>Reservations</h1>
""")

form = cgi.FieldStorage()
action = form.getvalue('action')

conn = None
try:
    conn = get_connection()
    conn.autocommit = False
    cur = conn.cursor()

    if action == 'create':
        start_date = form.getvalue('start_date')
        end_date = form.getvalue('end_date')
        boat_key = form.getvalue('boat')
        responsible = form.getvalue('responsible')

        if not start_date or not end_date or not boat_key or not responsible:
            print("<p class='error'>Error: All fields are required.</p>")
        else:
            if boat_key and '|' in boat_key:
                country, cni = boat_key.split('|', 1)
            else:
                country, cni = None, None

            sql_interval = """
                INSERT INTO date_interval(start_date, end_date)
                VALUES (%s, %s)
                ON CONFLICT (start_date, end_date) DO NOTHING
            """
            cur.execute(sql_interval, (start_date, end_date))

            sql_res = """
                INSERT INTO reservation(start_date, end_date, country, cni, responsible)
                VALUES (%s, %s, %s, %s, %s)
            """
            cur.execute(sql_res, (start_date, end_date, country, cni, responsible))

            conn.commit()
            print("<p class='message'> Reservation created successfully.</p>")

    elif action == 'delete':
        start_date = form.getvalue('start_date')
        end_date = form.getvalue('end_date')
        country = form.getvalue('country')
        cni = form.getvalue('cni')

        cur.execute("""
            DELETE FROM trip
            WHERE reservation_start_date = %s AND reservation_end_date = %s
              AND boat_country = %s AND cni = %s
        """, (start_date, end_date, country, cni))

        cur.execute("""
            DELETE FROM authorised
            WHERE start_date = %s AND end_date = %s
              AND boat_country = %s AND cni = %s
        """, (start_date, end_date, country, cni))

        cur.execute("""
            DELETE FROM reservation
            WHERE start_date = %s AND end_date = %s
              AND country = %s AND cni = %s
        """, (start_date, end_date, country, cni))

        conn.commit()
        print("<p class='message'> Reservation deleted successfully.</p>")

    cur.execute("""
        SELECT r.start_date, r.end_date,
               r.country, r.cni,
               b.name AS boat_name,
               r.responsible
        FROM reservation r
        JOIN boat b ON r.country = b.country AND r.cni = b.cni
        ORDER BY r.start_date, r.country, r.cni
    """)
    rows = cur.fetchall()

    print("<h2>Existing Reservations</h2>")
    if rows:
        print("<table>")
        print("<tr><th>Start Date</th><th>End Date</th><th>Country</th><th>CNI</th><th>Boat</th><th>Responsible</th><th>Actions</th></tr>")
        for start_date, end_date, country, cni, boat_name, responsible in rows:
            print("<tr>")
            print(f"<td>{html.escape(str(start_date))}</td>")
            print(f"<td>{html.escape(str(end_date))}</td>")
            print(f"<td>{html.escape(country)}</td>")
            print(f"<td>{html.escape(cni)}</td>")
            print(f"<td>{html.escape(boat_name)}</td>")
            print(f"<td>{html.escape(responsible)}</td>")
            print("<td>")
            print("<form method='post' action='reservations.cgi' class='inline-form'>")
            print("<input type='hidden' name='action' value='delete'/>")
            print(f"<input type='hidden' name='start_date' value='{start_date}'/>")
            print(f"<input type='hidden' name='end_date' value='{end_date}'/>")
            print(f"<input type='hidden' name='country' value='{country}'/>")
            print(f"<input type='hidden' name='cni' value='{cni}'/>")
            print("<button type='submit' class='delete-btn'>Delete</button>")
            print("</form>")
            print("</td>")
            print("</tr>")
        print("</table>")
    else:
        print("<p>No reservations registered.</p>")

    cur.execute("SELECT country, cni, name FROM boat ORDER BY country, cni")
    boats = cur.fetchall()

    cur.execute("SELECT email FROM senior ORDER BY email")
    seniors = cur.fetchall()

    print("<h2>Create Reservation</h2>")
    if not boats:
        print("<p class='error'>No boats available. Please add boats first.</p>")
    elif not seniors:
        print("<p class='error'>No senior sailors available. Please add senior sailors first.</p>")
    else:
        print("<div class='form-box'>")
        print("<form method='post' action='reservations.cgi'>")
        print("<input type='hidden' name='action' value='create'/>")

        print("<label>Start Date:</label>")
        print("<input type='date' name='start_date' required/>")

        print("<label>End Date:</label>")
        print("<input type='date' name='end_date' required/>")

        print("<label>Boat:</label>")
        print("<select name='boat' required>")
        for country, cni, boat_name in boats:
            value = f"{country}|{cni}"
            label = f"{country} - {cni} ({boat_name})"
            print(f"<option value='{value}'>{label}</option>")
        print("</select>")

        print("<label>Responsible (Senior):</label>")
        print("<select name='responsible' required>")
        for (email,) in seniors:
            print(f"<option value='{email}'>{email}</option>")
        print("</select>")

        print("<input type='submit' value='Create Reservation'/>")
        print("</form>")
        print("</div>")

    cur.close()
except Exception as error:
    if conn is not None:
        conn.rollback()
    print("<p class='error'>An error occurred:</p>")
    print(f"<pre>{html.escape(str(error))}</pre>")
finally:
    if conn is not None:
        conn.close()

print("</div></body></html>")