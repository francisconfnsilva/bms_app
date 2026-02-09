#!/usr/bin/python3
import cgi
import cgitb; cgitb.enable()
from db import get_connection
import html

print("Content-type: text/html\n")
print("""
<html>
<head>
    <title>Authorized Sailors</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2, h3 { color: #34495e; margin-top: 30px; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { text-decoration: underline; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background-color: #3498db; color: white; padding: 12px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f0f0f0; }
        a { color: #3498db; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .form-box { background-color: #f9f9f9; padding: 20px; border-radius: 5px; border: 1px solid #ddd; margin-top: 20px; }
        label { display: block; margin: 10px 0 5px 0; color: #555; font-weight: bold; }
        select { width: 100%; max-width: 400px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        select:focus { outline: none; border-color: #3498db; }
        input[type="submit"], button { padding: 10px 20px; background-color: #27ae60; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 10px; }
        input[type="submit"]:hover, button:hover { background-color: #229954; }
        button.delete-btn { background-color: #e74c3c; padding: 6px 12px; font-size: 13px; margin: 0; }
        button.delete-btn:hover { background-color: #c0392b; }
        .message { padding: 12px; margin: 15px 0; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; color: #155724; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 12px; border-radius: 4px; margin: 15px 0; }
        .inline-form { display: inline; }
    </style>
</head>
<body>
<div class="container">
    <a href='menu.cgi' class="back-link"> Back to Menu</a>
    <h1>Authorized Sailors</h1>
""")

form = cgi.FieldStorage()
action = form.getvalue('action')
start_date = form.getvalue('start_date')
end_date = form.getvalue('end_date')
boat_country = form.getvalue('boat_country')
cni = form.getvalue('cni')

conn = None
try:
    conn = get_connection()
    conn.autocommit = False
    cur = conn.cursor()

    # Authorize sailor
    if action == 'authorize' and start_date and end_date and boat_country and cni:
        sailor = form.getvalue('sailor')
        if not sailor:
            print("<p class='error'>Error: Please select a sailor.</p>")
        else:
            sql_ins = """
                INSERT INTO authorised(start_date, end_date, boat_country, cni, sailor)
                VALUES (%s, %s, %s, %s, %s)
            """
            cur.execute(sql_ins, (start_date, end_date, boat_country, cni, sailor))
            conn.commit()
            print("<p class='message'> Sailor authorized successfully.</p>")

    # Deauthorize sailor
    elif action == 'deauthorize' and start_date and end_date and boat_country and cni:
        sailor = form.getvalue('sailor')
        sql_del = """
            DELETE FROM authorised
            WHERE start_date = %s AND end_date = %s
              AND boat_country = %s AND cni = %s AND sailor = %s
        """
        cur.execute(sql_del, (start_date, end_date, boat_country, cni, sailor))
        conn.commit()
        print("<p class='message'> Sailor deauthorized successfully.</p>")

    # If no reservation selected, list reservations
    if not (start_date and end_date and boat_country and cni):
        print("<h2>Select Reservation</h2>")
        cur.execute("""
            SELECT r.start_date, r.end_date,
                   r.country, r.cni,
                   b.name AS boat_name
            FROM reservation r
            JOIN boat b ON r.country = b.country AND r.cni = b.cni
            ORDER BY r.start_date, r.country, r.cni
        """)
        rows = cur.fetchall()

        if rows:
            print("<table>")
            print("<tr><th>Start</th><th>End</th><th>Country</th><th>CNI</th><th>Boat</th><th>Manage</th></tr>")
            for s, e, country, boat_cni, boat_name in rows:
                link = f"authorized.cgi?start_date={s}&end_date={e}&boat_country={country}&cni={boat_cni}"
                print("<tr>")
                print(f"<td>{html.escape(str(s))}</td>")
                print(f"<td>{html.escape(str(e))}</td>")
                print(f"<td>{html.escape(country)}</td>")
                print(f"<td>{html.escape(boat_cni)}</td>")
                print(f"<td>{html.escape(boat_name)}</td>")
                print(f"<td><a href='{link}'>Manage Authorized</a></td>")
                print("</tr>")
            print("</table>")
        else:
            print("<p>No reservations available.</p>")

    else:
        # Show selected reservation
        cur.execute("""
            SELECT b.name, r.responsible
            FROM reservation r
            JOIN boat b ON r.country = b.country AND r.cni = b.cni
            WHERE r.start_date = %s AND r.end_date = %s
              AND r.country = %s AND r.cni = %s
        """, (start_date, end_date, boat_country, cni))

        res_info = cur.fetchone()
        if res_info:
            boat_name, responsible = res_info
            print("<div class='info'>")
            print(f"<strong>Selected Reservation:</strong> {html.escape(str(start_date))} to {html.escape(str(end_date))} | ")
            print(f"Boat: {html.escape(boat_country)} - {html.escape(cni)} ({html.escape(boat_name)}) | ")
            print(f"Responsible: {html.escape(responsible)}")
            print("</div>")

        # List authorized sailors
        sql_list_auth = """
            SELECT a.sailor, s.firstname, s.surname
            FROM authorised a
            JOIN sailor s ON a.sailor = s.email
            WHERE a.start_date = %s AND a.end_date = %s
              AND a.boat_country = %s AND a.cni = %s
            ORDER BY a.sailor
        """
        cur.execute(sql_list_auth, (start_date, end_date, boat_country, cni))
        auth_rows = cur.fetchall()

        print("<h3>Authorized Sailors</h3>")
        if auth_rows:
            print("<table>")
            print("<tr><th>Email</th><th>Name</th><th>Actions</th></tr>")
            for email, firstname, surname in auth_rows:
                print("<tr>")
                print(f"<td>{html.escape(email)}</td>")
                print(f"<td>{html.escape(firstname)} {html.escape(surname)}</td>")
                print("<td>")
                # Secure delete with POST form
                print("<form method='post' action='authorized.cgi' class='inline-form'>")
                print("<input type='hidden' name='action' value='deauthorize'/>")
                print(f"<input type='hidden' name='start_date' value='{start_date}'/>")
                print(f"<input type='hidden' name='end_date' value='{end_date}'/>")
                print(f"<input type='hidden' name='boat_country' value='{boat_country}'/>")
                print(f"<input type='hidden' name='cni' value='{cni}'/>")
                print(f"<input type='hidden' name='sailor' value='{email}'/>")
                print("<button type='submit' class='delete-btn'>Remove</button>")
                print("</form>")
                print("</td>")
                print("</tr>")
            print("</table>")
        else:
            print("<p>No sailors authorized yet.</p>")

        # Form to add authorized
        cur.execute("SELECT email, firstname, surname FROM sailor ORDER BY email")
        all_sailors = cur.fetchall()

        print("<h3>Add Authorized Sailor</h3>")
        if all_sailors:
            print("<div class='form-box'>")
            print("<form method='post' action='authorized.cgi'>")
            print("<input type='hidden' name='action' value='authorize'/>")
            print(f"<input type='hidden' name='start_date' value='{start_date}'/>")
            print(f"<input type='hidden' name='end_date' value='{end_date}'/>")
            print(f"<input type='hidden' name='boat_country' value='{boat_country}'/>")
            print(f"<input type='hidden' name='cni' value='{cni}'/>")

            print("<label>Sailor:</label>")
            print("<select name='sailor' required>")
            for email, firstname, surname in all_sailors:
                label = f"{email} ({firstname} {surname})"
                print(f"<option value='{email}'>{label}</option>")
            print("</select>")

            print("<input type='submit' value='Authorize Sailor'/>")
            print("</form>")
            print("</div>")
        else:
            print("<p class='error'>No sailors available.</p>")

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
